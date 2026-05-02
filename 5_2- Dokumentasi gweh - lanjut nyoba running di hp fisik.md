# Update Fitur Terbaru (Lanjutan Dokumentasi)

Ringkasan seluruh perubahan terbaru setelah file dokumentasi sebelumnya dibuat.

## Fitur yang ditambahkan / direvisi
1. Support Web + Android (`api_config.dart`)
2. Fix upload foto profile + event
3. Point sebagai mata uang pembelian tiket
4. Voucher popup untuk pembelian tiket
5. Realtime total price ticket
6. Notification system + badge
7. Read notification API
8. Market sorting
9. Profile organizer navigation
10. Report CSV organizer
11. Navbar organizer redesign
12. Nearby events berbasis lokasi
13. Toggle location di profile
14. Warning state jika GPS/location off
15. Fix infinite loading map
16. Popup nearby events di map
17. Filter event tanpa koordinat valid

## Dependencies tambahan
- geolocator
- flutter_map
- latlong2
- shared_preferences
- local_auth

## API tambahan
POST /api/tickets/purchase  
POST /api/tickets/buy  
POST /api/tickets/transfer  
POST /api/tickets/scan  
GET /api/tickets/mytickets  
GET /api/auth/notifications  
PUT /api/auth/read-notifications  
GET /api/organizer/report  

## Database tambahan
### notifications
- id
- user_id
- title
- message
- is_read
- created_at

### event
- latitude
- longitude

### users
- profile_image

## Status akhir
Semua fitur utama saat ini stabil:
- ticket purchase
- voucher
- points
- notifications
- organizer report
- nearby events
- location persistence
- map popup
