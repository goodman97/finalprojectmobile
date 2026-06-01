"""
Gelatix ML Recommendation Service
Algoritma: Hybrid (Content-Based + Popularity-Based)
Port: 5001
"""

from flask import Flask, request, jsonify
import psycopg2
import psycopg2.extras
import traceback
import numpy as np
from pathlib import Path
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from dotenv import dotenv_values

app = Flask(__name__)

# DB Connection

def get_db():
    root     = Path(__file__).resolve().parent.parent
    env_path = root / 'gelatix-backend' / '.env'
    config   = dotenv_values(str(env_path))

    return psycopg2.connect(
        host     = config.get("DB_HOST", "localhost"),
        port     = int(config.get("DB_PORT", 5432)),
        database = config.get("DB_NAME"),
        user     = config.get("DB_USER"),
        password = config.get("DB_PASS"),
    )

# Helper: ambil data dari DB

def fetch_all_events(conn):
    """Ambil semua event aktif yang belum lewat beserta fitur untuk similarity."""
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("""
            SELECT
                e.id,
                e.name,
                e.genre,
                e.address,
                e.description,
                e.price,
                COALESCE(COUNT(t.id), 0) AS sold
            FROM events e
            LEFT JOIN tickets t
                ON t.event_id = e.id AND t.status IN ('active','used','resale')
            WHERE e.status = 'active'
              AND e.end_date >= NOW()
            GROUP BY e.id
            ORDER BY e.start_date ASC
        """)
        return cur.fetchall()

def fetch_user_history(conn, user_id):
    with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute("""
            SELECT
                t.event_id,
                COUNT(*) as purchase_count
            FROM tickets t
            JOIN transactions tr ON tr.ticket_id = t.id
            WHERE t.user_id = %s::uuid
              AND tr.status = 'success'
            GROUP BY t.event_id
        """, (str(user_id),))

        rows = cur.fetchall()

        return {
            str(row['event_id']): int(row['purchase_count'])
            for row in rows
        }

# Content-Based Filtering

def build_content_features(events):
    """
    Gabungkan teks fitur event menjadi satu string untuk TF-IDF.
    Contoh: "konser musik jakarta makan kuliner bandung"
    """
    features = []
    for e in events:
        genre_text = ((e.get('genre') or '') + ' ') * 3

        text = " ".join(filter(None, [
            e.get('name', ''),
            genre_text,
            e.get('description', ''),
        ])).lower()
        features.append(text)
    return features

def content_based_recommend(events, purchased_data, top_n=10):
    """
    Hitung cosine similarity antara event yang pernah dibeli
    dengan semua event aktif → rekomendasikan yang paling mirip.
    """

    purchase_map  = purchased_data
    purchased_ids = list(purchase_map.keys())

    genre_counter = {}

    for e in events:
        eid = str(e['id'])

        if eid in purchase_map:
            genre = (e.get('genre') or '').lower()

            if genre:
                genre_counter[genre] = (
                    genre_counter.get(genre, 0)
                    + purchase_map[eid]
                )

    favorite_genre = None

    if genre_counter:
        favorite_genre = max(
            genre_counter,
            key=genre_counter.get
        )

    if not purchased_ids:
        return []

    event_ids     = [str(e['id']) for e in events]
    purchase_map  = purchased_data
    purchased_ids = list(purchase_map.keys())
    features      = build_content_features(events)

    tfidf        = TfidfVectorizer(min_df=1, stop_words=None)
    tfidf_matrix = tfidf.fit_transform(features)

    # Index event yang pernah dibeli
    purchased_idx = [
        i for i, eid in enumerate(event_ids)
        if eid in [str(p) for p in purchased_ids]
    ]

    if not purchased_idx:
        return []

    # Rata-rata vektor event yang dibeli → "profil user"
    user_vector = tfidf_matrix[purchased_idx].mean(axis=0)
    user_vector = np.asarray(user_vector)

    # Similarity semua event vs profil user
    sims = cosine_similarity(user_vector, tfidf_matrix)[0]

    for i, e in enumerate(events):
        genre = (e.get('genre') or '').lower()

        if favorite_genre and genre == favorite_genre:
            sims[i] += 0.5

    # Hitung total kekuatan minat user
    interest_weight = 1.0

    for eid in purchased_ids:
        interest_weight += purchase_map.get(eid, 1) * 0.15

    sims = sims * interest_weight

    # Exclude event yang sudah dibeli
    for idx in purchased_idx:
        sims[idx] = -1

    # Top N index
    top_idx = np.argsort(sims)[::-1][:top_n]
    return [(event_ids[i], float(sims[i])) for i in top_idx if sims[i] > 0]

# Popularity-Based (fallback)

def popularity_recommend(events, purchased_ids, top_n=10):
    """Rekomendasikan event terpopuler yang belum dibeli user."""
    purchased_str = [str(p) for p in purchased_ids]
    filtered      = [e for e in events if str(e['id']) not in purchased_str]
    sorted_events = sorted(filtered, key=lambda x: int(x['sold']), reverse=True)
    return [(str(e['id']), 0.5) for e in sorted_events[:top_n]]

# Endpoint
@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'service': 'gelatix-ml'})

@app.route('/recommend', methods=['POST'])
def recommend():
    try:
        body    = request.get_json()
        user_id = str(body.get('user_id'))

        if not user_id:
            return jsonify({'error': 'user_id required'}), 400

        conn = get_db()

        events    = fetch_all_events(conn)
        purchased = fetch_user_history(conn, user_id)

        conn.close()

        if not events:
            return jsonify({'recommended_ids': [], 'source': 'empty'})

        # Coba content-based dulu
        results = content_based_recommend(events, purchased, top_n=10)

        source = 'content_based'

        # Kalau user belum punya history atau hasil kosong → pakai popularity
        if not results:
            results = popularity_recommend(events, purchased, top_n=10)
            source  = 'popularity'

        # Gabung: content-based score + sedikit boost dari popularity (sold)
        event_map = {str(e['id']): e for e in events}
        max_sold  = max(int(e['sold']) for e in events) or 1

        scored = []
        for eid, sim_score in results:
            e = event_map.get(eid)
            if not e:
                continue
            pop_score   = int(e['sold']) / max_sold * 0.3  # bobot 30%
            final_score = sim_score * 0.7 + pop_score      # bobot 70%
            scored.append({'id': eid, 'score': round(final_score, 4)})

        scored.sort(key=lambda x: x['score'], reverse=True)

        return jsonify({
            'recommended_ids': [s['id'] for s in scored],
            'source': source,
            'scores': scored,
        })

    except Exception as e:
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)