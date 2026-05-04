# Ringkasan Revisi Project Gelatix (Ticket Types → Chatbot)

## 1. Revisi Halaman Event Detail EO
Menyesuaikan tampilan halaman detail event milik EO agar sesuai desain awal.

### Perubahan:
- Card detail event disamakan dengan desain awal:
  - tanggal
  - lokasi
  - deskripsi
- Card **Sold** dan **Revenue** disesuaikan UI-nya.
- Menghapus bagian **Kapasitas**.
- Mengganti dengan fitur **Sales Statistics**:
  - Today
  - This Week
  - This Month

### Tab baru:
#### Overview
Berisi:
- Manage Ticket Types
- Download Report

#### Buyers
Menampilkan:
- nama pembeli
- email
- jumlah tiket
- status validasi
- total pembelian

---

# 2. Fitur Manage Ticket Types
Membuat halaman khusus untuk mengelola tipe tiket event.

## Fitur awal:
- tambah ticket type
- input:
  - nama tiket
  - harga
  - kuota

## Masalah awal:
Ticket type hilang setelah keluar halaman karena hanya tersimpan di state lokal Flutter.

## Solusi:
Disimpan ke database PostgreSQL.

Tabel yang dipakai:
- `ticket_types`

Kolom:
- id
- event_id
- name
- price
- quota

---

# 3. Default Ticket Type Otomatis
Saat EO membuat event baru sebelumnya tidak langsung memiliki ticket type.

## Solusi:
Saat event dibuat:
otomatis insert default ticket:

- nama: Regular Ticket / General Admission
- price: mengambil harga event
- quota: mengambil quota event

Ditambahkan di:
- `eventController.js`

Flow:
create event → auto create default ticket type

---

# 4. Edit Ticket Type
Menambahkan fitur edit ticket type.

Sebelumnya:
- hanya bisa create
- tidak bisa edit

Perubahan:
- tombol **Manage →** sekarang membuka dialog edit
- user bisa mengubah:
  - nama tiket
  - harga
  - quota

UI dialog edit juga disesuaikan agar tidak default Flutter.

---

# 5. Revisi User Event Detail
Bug:
- tanggal hilang
- lokasi hilang

Solusi:
memperbaiki mapping data dari backend ke halaman detail event user.

---

# 6. Revisi Purchase Ticket
Menambahkan fitur memilih tipe tiket saat checkout.

Sebelumnya:
- hanya langsung beli tiket default

Sekarang:
- user bisa memilih ticket type dari dropdown

Contoh:
- VIP
- Regular

---

# 7. Revisi UI Purchase Ticket
Setelah dropdown ditambahkan, UI sempat rusak.

Perbaikan:
- mengembalikan layout seperti desain awal
- tetap mempertahankan fitur dropdown ticket type

Komponen yang dipertahankan:
- currency
- quantity
- voucher
- points
- total price

Tambahan:
- dropdown ticket type custom styling

Masalah warna ungu default dropdown juga diperbaiki.

---

# 8. Menambahkan Fitur Chatbot
Menambahkan icon chatbot di halaman discover.

Lokasi:
- di sebelah icon notification

Icon:
- robot icon

Ketika ditekan:
- membuka halaman baru `ChatBotPage`

---

# 9. Perbaikan Header Discover
Masalah:
- text Discover hilang
- posisi icon berantakan

Solusi:
Menggunakan `Expanded()` agar:
- Discover tetap di kiri
- chatbot icon di kanan
- notification tetap di kanan

---

# 10. Pembuatan Chatbot Page
Membuat halaman chat:

Fitur:
- bubble chat user
- bubble chat bot
- input text
- tombol kirim

Awalnya bot masih hardcoded/manual response.

---

# 11. Integrasi AI API
Awalnya mempertimbangkan:
- OpenAI
- Gemini

Akhirnya menggunakan:
**OpenRouter**

Karena:
- gratis
- fleksibel
- banyak pilihan model

---

# 12. Backend Chat API
Membuat:

### `chatController.js`
Menghubungkan backend ke OpenRouter API.

### `chatRoutes.js`
Endpoint:

`/api/chat`

### `app.js`
Register route chatbot.

---

# 13. Flutter Chat Service
Membuat:

`chat_service.dart`

Fungsi:
- mengirim pesan ke backend
- menerima response AI

---

# 14. Debugging Chatbot
Masalah yang sempat terjadi:

### Route error
`Cannot find module './routes/chatRoutes'`

Solusi:
fix path route karena folder ada di `src/routes`

---

### req.body undefined
Solusi:
- pakai raw JSON di Postman
- tambahkan:

`app.use(express.json())`

---

### model OpenRouter tidak tersedia
Model lama:
- gemma error

Error:
- endpoint not found
- rate limit

---

# 15. Model Final Chatbot
Akhirnya menggunakan model gratis:

`openai/gpt-oss-20b:free`

Dan berhasil.

Response contoh:

`Halo! Ada yang bisa saya bantu hari ini?`

---

# 16. Fix Delay Response Chatbot
Masalah:
user spam tombol kirim → response numpuk

Solusi:
menambahkan:

- `isLoading`
- disable tombol kirim saat bot sedang membalas
- loading indicator

Hasil:
chat lebih rapi dan natural.

---

# Final Status
Fitur yang berhasil selesai:

✅ Event detail EO redesign

✅ Overview + Buyers tab

✅ Manage ticket types

✅ Add ticket type

✅ Default ticket type otomatis

✅ Edit ticket type

✅ Purchase ticket pilih tipe tiket

✅ Revisi UI purchase ticket

✅ Chatbot menu

✅ Chatbot page

✅ Integrasi OpenRouter AI

✅ Fix chatbot loading issue

Project sekarang sudah jauh lebih lengkap dibanding versi awal.

