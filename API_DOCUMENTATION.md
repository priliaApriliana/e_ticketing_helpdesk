# Dokumentasi API E-Ticketing Helpdesk

Dokumentasi ini berisi informasi mengenai backend API yang digunakan untuk aplikasi mobile E-Ticketing Helpdesk.

## 🛠 Teknologi
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: PostgreSQL
- **Autentikasi**: JSON Web Token (JWT)
- **Enkripsi**: Bcryptjs

## ⚙️ Persiapan & Instalasi

### 1. Database
Pastikan PostgreSQL sudah terinstal. 
1. Buat database baru bernama `e_ticketing`.
2. Jalankan script SQL yang ada di file `backend/database.sql` untuk membuat tabel-tabel yang dibutuhkan.

### 2. Konfigurasi Environment
Buat file `.env` di dalam folder `backend` (sudah tersedia) dan sesuaikan pengaturannya:
```env
PORT=3000
DB_USER=postgres
DB_HOST=localhost
DB_NAME=e_ticketing
DB_PASSWORD=password_anda
DB_PORT=5432
JWT_SECRET=rahasia_e_ticketing_123
```

### 3. Menjalankan Server
Buka terminal di folder `backend`, lalu jalankan:
```bash
npm install
npm start
```

## 🚀 Endpoints API

Semua request menggunakan prefix URL: `http://localhost:3000/api` (untuk emulator Android gunakan `http://10.0.2.2:3000/api`).

### 1. Autentikasi (`/auth`)
| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| POST | `/auth/register` | Mendaftarkan user baru |
| POST | `/auth/login` | Login user & mendapatkan token JWT |
| POST | `/auth/reset-password` | Reset password user |

### 2. Tiket (`/tickets`)
| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| GET | `/tickets` | Mengambil semua tiket (filter: `user_id`, `status`) |
| GET | `/tickets/:id` | Mengambil detail tiket berdasarkan ID |
| POST | `/tickets` | Membuat tiket baru |
| PUT | `/tickets/:id/status` | Update status tiket atau assign teknisi |
| PUT | `/tickets/:id/unassign` | Membatalkan assign teknisi |

### 3. Komentar Tiket (`/tickets/:id/comments`)
| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| GET | `/:id/comments` | Mengambil semua komentar pada tiket tertentu |
| POST | `/:id/comments` | Menambahkan komentar baru |

### 4. Notifikasi (`/notifications`)
| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| GET | `/notifications` | Mengambil notifikasi user |
| POST | `/notifications` | Membuat notifikasi baru |
| PUT | `/notifications/:id/read` | Menandai satu notifikasi sudah dibaca |
| PUT | `/notifications/read-all` | Menandai semua notifikasi sudah dibaca |

### 5. Dashboard & Users (`/dashboard`, `/users`)
| Method | Endpoint | Deskripsi |
| :--- | :--- | :--- |
| GET | `/dashboard/metrics` | Mengambil statistik tiket (Total, Open, Closed, dll) |
| GET | `/users` | Mengambil daftar user (filter: `role`) |

## 📝 Format Data Tiket
**Status**: `open`, `in_progress`, `resolved`, `closed`  
**Priority**: `low`, `medium`, `high`, `urgent`  
**Role User**: `user`, `helpdesk`, `technical_support`, `admin`

---
*Dibuat untuk tugas E-Ticketing Helpdesk Mobile App.*
