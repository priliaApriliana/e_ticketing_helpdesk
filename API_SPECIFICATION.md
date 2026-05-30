# Dokumentasi API E-Ticketing Helpdesk

Dokumentasi ini berisi spesifikasi endpoint yang dibutuhkan oleh aplikasi mobile E-Ticketing Helpdesk untuk berkomunikasi dengan Backend.

**Base URL:** `https://api.yourdomain.com/v1`

---

## 1. Autentikasi (Auth)

### Login User
Digunakan untuk masuk ke sistem dan mendapatkan token akses.
*   **Endpoint:** `POST /auth/login`
*   **Request Body:**
    ```json
    {
      "email": "user@example.com",
      "password": "password123"
    }
    ```
*   **Response (200 OK):**
    ```json
    {
      "token": "jwt_token_here",
      "user": {
        "id": "3",
        "name": "Andi User",
        "email": "user@example.com",
        "role": "user"
      }
    }
    ```

---

## 2. Manajemen Tiket

### Ambil Daftar Tiket
Mengambil semua tiket (Admin/Helpdesk) atau tiket milik sendiri (User).
*   **Endpoint:** `GET /tickets`
*   **Query Parameters:** 
    * `status` (optional): open, in_progress, closed
    * `user_id` (optional): Filter berdasarkan pembuat
*   **Response (200 OK):**
    ```json
    [
      {
        "id": "TKT-001",
        "title": "Komputer tidak bisa menyala",
        "status": "open",
        "priority": "high",
        "category": "Hardware",
        "created_at": "2023-10-27T10:00:00Z",
        "comment_count": 2
      }
    ]
    ```

### Buat Tiket Baru
*   **Endpoint:** `POST /tickets`
*   **Request Body:**
    ```json
    {
      "title": "Printer Error",
      "description": "Printer di lantai 2 macet",
      "priority": "medium",
      "category": "Hardware",
      "attachments": []
    }
    ```

### Update Status Tiket (Admin/Technical Support)
*   **Endpoint:** `PUT /tickets/{id}/status`
*   **Request Body:**
    ```json
    {
      "status": "in_progress",
      "assigned_to": "4",
      "assigned_to_name": "Rizky Technical Support"
    }
    ```

---

## 3. Komentar & Chat

### Ambil Komentar Tiket
*   **Endpoint:** `GET /tickets/{id}/comments`
*   **Response (200 OK):**
    ```json
    [
      {
        "id": "c1",
        "user_name": "Siti Helpdesk",
        "user_role": "helpdesk",
        "content": "Teknisi segera meluncur.",
        "created_at": "2023-10-27T11:00:00Z"
      }
    ]
    ```

### Tambah Komentar
*   **Endpoint:** `POST /tickets/{id}/comments`
*   **Request Body:**
    ```json
    {
      "content": "Baik, terima kasih."
    }
    ```

---

## 4. Dashboard & Statistik

### Get Metrics
*   **Endpoint:** `GET /dashboard/metrics`
*   **Response (200 OK):**
    ```json
    {
      "total": 10,
      "open": 4,
      "in_progress": 2,
      "resolved": 2,
      "closed": 2
    }
    ```
