# WIREFRAME DESIGN DOCUMENT
## E-Ticketing Helpdesk Mobile Application

**Project:** E-Ticketing Helpdesk  
**Version:** 1.0  
**Date:** April 2024  
**Author:** Putri Apriliana (434241022)  
**Target Device:** Mobile (Portrait 360px - 540px width)

---

## 1. DASHBOARD USER (3 KPI CARDS)

User Role Dashboard menampilkan 3 KPI utama:
- Total Tiket Disubmit
- Tiket Sedang Diproses  
- Tiket Selesai

Setiap KPI card adalah clickable dan memfilter ke ticket list.

---

## 2. DASHBOARD ADMIN (5 KPI CARDS)

Admin/Helpdesk Role Dashboard menampilkan 5 KPI statistik:
- Tiket Masuk
- Tiket Sedang Diproses
- Tiket Belum Ditangani
- Tiket Selesai
- Total Tiket Keseluruhan

---

## 3. SCREENS OVERVIEW

### Login Screen
- Email input field
- Password input field
- Login button
- Register link
- Responsive untuk semua ukuran device

### Register Screen
- Email input
- Password input
- Confirm password input
- Register button
- Login link

### Dashboard (User)
- Greeting message
- 3 KPI Cards (clickable)
- Recent tickets preview
- Quick actions (Create ticket, Profile)

### Dashboard (Admin/Helpdesk)
- Greeting message
- 5 KPI Cards (clickable)
- Statistics chart
- Recent tickets with assignment info
- Quick actions

### Ticket List
- Search bar
- Filter options
- Ticket cards dengan status badges
- Load more pagination
- FAB untuk create ticket baru

### Ticket Detail
- Full ticket information
- Status timeline progression
- Comments section
- Action buttons (assign, update status, add comment)
- Role-based permission display

### Ticket Create
- Title input
- Category dropdown
- Priority selector
- Description textarea
- Attachment upload
- Submit button

### Profile Screen
- User information display
- Change password option
- Notification toggle
- Logout button
- App version info

---

## 4. COLOR SCHEME

| Element | Color | Hex |
|---------|-------|-----|
| Primary | Blue | #2563EB |
| Secondary | Purple | #7C3AED |
| Success | Green | #16A34A |
| Warning | Orange | #D97706 |
| Error | Red | #DC2626 |
| Status Labels | Various | See below |

### Status Colors
- Menunggu (Open): Orange #D97706
- Diproses (In Progress): Blue #2563EB
- Selesai Teknis (Resolved): Green #16A34A
- Selesai (Closed): Gray #6B7280

---

## 5. RESPONSIVE DESIGN

- Minimum width: 320px (small phone)
- Maximum width: 600px (tablet - optional)
- Padding: 16px standard
- Button height: 48px minimum
- Input field height: 48px
- Card border radius: 12px
- Input border radius: 10px

---

## 6. TYPOGRAPHY

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Heading 1 | Poppins | 24px | 600 |
| Heading 2 | Poppins | 18px | 600 |
| Body | Poppins | 14px | 400 |
| Small | Poppins | 12px | 400 |
| Button | Poppins | 14px | 600 |

---

## 7. KEY FEATURES

### Authentication
- Login dengan email & password
- Register user baru
- Token management
- Session persistence

### Ticket Management
- Create, Read, Update tiket
- Status workflow: open → in_progress → resolved → closed
- Ticket assignment
- Status timeline visualization
- Comment system

### Role-Based Access
- User: Create ticket, view own tickets, add comments
- Helpdesk: Assign, update status (in_progress/resolved)
- Admin: All operations + close tickets + reassign

### Dashboard Analytics
- User: 3 KPI mengenai tiket mereka sendiri
- Admin: 5 KPI sistem-wide statistics
- Clickable KPI untuk filter

---

## 8. INTERACTION FLOWS

### Login Flow
User → Input email/password → Validate → Dashboard

### Create Ticket
User → Click FAB → Fill form → Submit → Show success → Back to list

### Assign Ticket
Helpdesk → View ticket → Click "Assign ke saya" → Auto status "Diproses"

### Update Ticket Status
Helpdesk/Admin → View ticket → Click "Update Status" → Select new status → Confirm → Update

### KPI Click
Dashboard → Click KPI card → Navigate to ticket list dengan filter status

---

End of Wireframe Document
Version 1.0 - April 2024
Prepared by: Putri Apriliana (434241022)
