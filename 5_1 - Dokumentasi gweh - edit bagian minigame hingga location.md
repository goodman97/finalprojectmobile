# Gelatix Feature Summary (After Minigame Point Integration)

Dokumentasi ini merangkum semua fitur yang dibuat mulai dari perubahan sistem **point minigame sebagai alat pembayaran tiket** sampai fitur-fitur terbaru.

---

# 1. Point Minigame sebagai Mata Uang Pembelian Tiket

## Konsep
Jika harga tiket:

`Rp 100.000`

dan user memakai:

`1000 point`

maka total pembayaran menjadi:

`Rp 99.000`

---

## Flow
User buka detail event → purchase ticket → pilih:

- quantity tiket
- voucher
- points yang ingin dipakai

Backend akan:

- validasi point user
- mengurangi point user
- menghitung harga akhir
- menyimpan transaksi

---

## Endpoint
### Purchase ticket
```http
POST /api/tickets/purchase
```

### Get user tickets
```http
GET /api/tickets/mytickets
```

### Buy ticket
```http
POST /api/tickets/buy
```

### Transfer ticket
```http
POST /api/tickets/transfer
```

### Scan ticket
```http
POST /api/tickets/scan
```

---

# 2. Voucher Integration

Voucher dari minigame bisa dipakai saat checkout tiket.

---

## Flow
User:
- pilih voucher
- klik Use

Voucher akan memberi diskon sesuai value:

- 5%
- 10%
- 15%

---

## Database Table
Menggunakan table:

`user_rewards`

---

# 3. Ticket Purchase UI Revision

Revisi tampilan:

- quantity box kembali normal
- popup voucher seperti minigame
- slider points
- total harga realtime

---

# 4. Notification System

Setelah user membeli tiket:

- user dapat tambahan spin
- notif otomatis masuk database
- notif muncul di halaman notification
- klik notif → masuk ke minigame

---

## Endpoint
```http
GET /api/auth/notifications
```

---

## Database SQL
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    message TEXT,
    type VARCHAR(100),
    reference_type VARCHAR(100),
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

# 5. Notification UI

### Home
- icon notif ada red dot

### Profile
- notif badge count

### Notification page
- card style seperti voucher
- klik notif → masuk minigame

---

# 6. Nearby Event Map Feature

User bisa melihat event terdekat berdasarkan lokasi.

---

## Fitur
- marker event
- lokasi user
- popup nearby event
- klik event → event detail
- estimasi jarak realtime
- estimasi waktu realtime

---

## Event tanpa koordinat
Tidak ditampilkan di nearby event popup.

---

## Endpoint
```http
GET /api/events
```

---

# 7. Location Toggle

Di profile user:

- enable location
- disable location

Untuk nearby event.

---

# 8. Market Sorting Feature

Sorting event berdasarkan:

- nearest date
- farthest date
- lowest price
- highest price

---

## Endpoint
```http
GET /api/market
```

---

# 9. Event Image & Profile Image Fix

Perbaikan static file backend:

```javascript
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
```

Struktur:

```bash
uploads/
  events/
  profiles/
```

---

# 10. Organizer Profile Navigation

Profile icon di:

- EO dashboard
- EO my events

sekarang menuju profile organizer.

---

# 11. Report & Analytics CSV Download

Organizer bisa download laporan statistik event.

---

## Endpoint
```http
GET /api/events/eo/download-report
```

---

## Isi CSV
- event name
- start date
- location
- price
- quota
- tickets sold
- revenue

---

# 12. EO Dashboard API

```http
GET /api/events/eo/dashboard
```

---

# 13. EO My Events API

```http
GET /api/events/eo/my-events
```

---

# 14. EO Event Detail API

```http
GET /api/events/eo/:id
```

---

# 15. Create Event API

```http
POST /api/events/eo/create
```

---

# 16. Edit Event API

```http
PUT /api/events/eo/:id/edit
```

---

# Dependencies Added

Tambahkan di `pubspec.yaml`:

```yaml
flutter_map: ^6.0.0
latlong2: ^0.9.0
geolocator: ^12.0.0
geocoding: ^2.1.0
http: ^1.6.0
http_parser: ^4.0.2
image_picker: ^1.0.4
shared_preferences: ^2.5.5
```

---

# Database Tables yang Dipakai

## users
- profile image
- role
- telephone

---

## events
- latitude
- longitude
- event_image

---

## tickets

---

## transactions

---

## user_rewards

---

## notifications

(SQL ada di atas)

---

# Flow Final Aplikasi

### User
- lihat event
- cari event
- sort event
- nearby event
- beli tiket
- pakai voucher
- pakai point
- dapat notif
- dapat spin

---

### Organizer
- create event
- edit event
- lihat analytics
- download csv report

---

# Status Saat Ini

Semua fitur utama sudah berjalan:

- event
- ticket
- voucher
- points
- notifications
- nearby map
- analytics csv
- organizer profile
