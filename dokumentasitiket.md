# 📘 Backend Development Documentation — Gelatix Ticketing System

## 🧑‍💻 Project Overview
Backend ini dikembangkan untuk sistem tiket digital (event ticketing) yang mendukung pembelian tiket, transfer tiket antar user, pelacakan riwayat kepemilikan, dan pencatatan transaksi. Sistem ini dirancang dengan pendekatan modular menggunakan Node.js sebagai API layer dan PostgreSQL sebagai database utama, dengan JWT sebagai mekanisme autentikasi.

---

## 🛠️ Tech Stack
- Node.js (Express)
- PostgreSQL
- JSON Web Token (JWT)

---

## 🏗️ Arsitektur Sistem
Client (Postman / Mobile App) → Express API (Node.js) → PostgreSQL (Function, Table, Constraint)

---

## 🗄️ Database Design

### users
- id (UUID, PK)
- name (TEXT)
- email (TEXT)
- password (TEXT)
- role (TEXT)

### events
- id (UUID, PK)
- name (TEXT)
- date (TIMESTAMP)
- price (NUMERIC)
- quota (INTEGER)
- organizer_id (UUID)
- status (TEXT)

### ticket_types
- id (UUID, PK)
- event_id (UUID, FK)
- name (TEXT)
- price (NUMERIC)
- quota (INTEGER)

### tickets
- id (UUID, PK)
- ticket_type_id (UUID, FK)
- current_owner_id (UUID, FK)
- qr_code (TEXT)
- status (TEXT)
- created_at (TIMESTAMP)

### ticket_history
- id (UUID, PK)
- ticket_id (UUID, FK)
- owner_id (UUID, FK)
- acquired_at (TIMESTAMP)
- transfer_type (TEXT)

Constraint:
transfer_type hanya boleh bernilai 'purchase' atau 'resale'

### transactions
- id (UUID, PK)
- user_id (UUID, FK)
- ticket_id (UUID, FK)
- amount (NUMERIC)
- status (TEXT)
- created_at (TIMESTAMP)

Enum:
transaction_status = ('pending', 'success', 'failed')

---

## ⚙️ Core Business Logic

### 1. buy_ticket
Function ini digunakan saat user membeli tiket.

Alur:
1. Insert data ke tabel tickets
2. Insert ke ticket_history dengan tipe 'purchase'
3. Insert ke transactions dengan status 'success'
4. Return ticket_id

---

### 2. transfer_ticket
Function ini digunakan untuk memindahkan kepemilikan tiket.

Alur:
1. Validasi bahwa pengirim adalah owner saat ini
2. Update current_owner_id di tabel tickets
3. Insert ke ticket_history dengan tipe 'resale'

---

## 🔐 Authentication
Menggunakan JWT:
- Login menghasilkan token
- Middleware memverifikasi token
- Data user disimpan di req.user.id

---

## 🌐 API Endpoints

### Auth
POST /api/auth/login

Body:
{
  "email": "user@email.com",
  "password": "password"
}

---

### Buy Ticket
POST /api/tickets/buy

Body:
{
  "ticketTypeId": "UUID",
  "price": 100000
}

---

### Transfer Ticket
POST /api/tickets/transfer

Body:
{
  "ticketId": "UUID",
  "toUser": "UUID"
}

---

### Get My Tickets
GET /api/tickets/my

---

### Scan Ticket (Optional)
POST /api/tickets/scan

Body:
{
  "qr": "QR_CODE"
}

---

## 🧪 Testing Progress

Fitur yang sudah berhasil:
- Login menggunakan JWT
- Pembelian tiket (buy_ticket)
- Transfer tiket (transfer_ticket)
- Pencatatan riwayat kepemilikan
- Pencatatan transaksi

---

## 🐞 Issues & Fixes

1. Enum tidak sesuai  
   'paid' → diganti menjadi 'success'

2. Constraint transfer_type  
   'buy' → diganti menjadi 'purchase'

3. Duplicate function  
   Function buy_ticket terduplikasi → dihapus dan dibuat ulang

4. Trigger error  
   Trigger menggunakan kolom yang tidak ada → dihapus

5. UUID tidak valid  
   Diganti menggunakan gen_random_uuid()

6. Error API  
   - Format JSON salah  
   - Token salah penempatan  
   - Endpoint typo  

---

## 📊 Final Result

Contoh alur data:
- User A membeli tiket → transfer_type = purchase
- User A mentransfer ke User B → transfer_type = resale

Hasil:
- Ownership berpindah dengan benar
- History tercatat dengan urutan yang tepat
- Data konsisten tanpa error

---

## 🚀 Next Development Plan

- Validasi QR code (scan ticket)
- Pembatasan resale
- Dashboard untuk EO
- Integrasi payment gateway
- Sistem notifikasi

---

## 🏁 Conclusion

Backend ini telah mencapai kondisi:

Fully Working Ticketing System

Dengan fitur:
- Ownership tracking
- Transfer ticket
- Transaction logging
- History audit

---

## 🤝 Notes for Team

- Hindari penggunaan trigger tanpa validasi schema
- Gunakan constraint untuk menjaga integritas data
- Gunakan database function untuk logic utama
- Konsisten menggunakan UUID untuk semua ID

---