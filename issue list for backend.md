# Backend Issue List & Feature Requirements

This document outlines the backend bugs and requirements needed for the mobile application.

---

## 📋 Summary Table

| # | Feature / Module | Endpoint | Method | Issue / Requirement | Priority |
|---|---|---|---|---|---|
| 1 | **Product Sell (Bill/Invoice Upload)** | `/api/v1/products` | `POST` | Allow **Images** (`jpg`, `png`, `webp`) in addition to **PDF** for bill uploads (`400 Bad Request` fix). | High |
| 2 | **My Wardrobe vs Seller Products** | `/api/v1/products?seller={id}` | `GET` | Add Token Auth, filter other sellers' items (available only), and include Order Status for own sold/reserved items. | High |
| 3 | **Order / Purchase Status Lifecycle** | `/api/v1/orders` | `GET` | Standardize Order Status enum to match the app's timeline + add status filter (`?status=...`). | High |

---

## 1. Product Sell API: Bill/Invoice File Format Support

### 📌 Endpoint Details
- **Endpoint:** `POST /api/v1/products`
- **Content-Type:** `multipart/form-data`
- **Issue:** Currently returns `400 Bad Request` with `"Only pdf supported"` when an image is uploaded.

### 📝 Requirement
- Users can upload proof of purchase/bill as either a **Document (`PDF`)** or an **Image (`JPEG`, `PNG`, `WEBP`)**.
- Please update the Multer file filter to accept:
  - `application/pdf`
  - `image/jpeg`
  - `image/png`
  - `image/webp`
  - `image/jpg`

---

## 2. My Wardrobe & Seller Profile Products API

### 📌 Endpoint Details
- **Endpoint:** `GET /api/v1/products?seller={sellerId}`
- **Authentication:** Must be a **Protected Route** (Require Bearer Token in Header).

### 📝 Requirements

#### A. Viewing Another Seller's Profile (`sellerId != loggedInUserId`)
- Only return **Available / Active** products (`status: 'available'`).
- Do **not** expose sold or reserved items to other users.

#### B. Viewing Own Wardrobe (`sellerId == loggedInUserId` / My Wardrobe)
- Return **All** products owned by the user:
  - `available`
  - `reserved` (secured)
  - `sold`
- **For Reserved & Sold items:** Include linked **Order Details** in the response object:
  - Order ID & Order Number
  - Buyer info (e.g. name, avatar, who secured/purchased)
  - Current Order Status (`reserved`, `collected`, `authenticated`, `dispatched`, `delivered`, `cancelled`, `refunded`)

---

## 3. Order / Purchase Status Lifecycle & Filter

### 📌 Endpoint Details
- **Endpoint:** `GET /api/v1/orders`
- **Authentication:** Protected Route (Bearer Token).

### 🎯 Standard Order Status Enum
The app's order tracking timeline strictly uses the following statuses:

| Status Enum | Display Title | Description / Stage |
|---|---|---|
| `reserved` | **Reserved** | Item reserved for the buyer |
| `collected` | **Collected** | Picked up from seller |
| `authenticated` | **Authenticated** | Verified by experts |
| `dispatched` | **Dispatched** | Out for delivery |
| `delivered` | **Delivered** | Successfully delivered |

#### ⚠️ Exception / Edge Case Statuses (Outside normal timeline):
- `pending` — Order placed / awaiting payment or confirmation (if applicable)
- `cancelled` — Order cancelled
- `refunded` — Payment refunded to buyer

> **Note:** Backend should return one of these exact standardized string values in `order.status` or `status`. No arbitrary or unmapped status strings should be used.

### 🔍 Backend Status Filter Support
- Enable query parameter filtering by status on the orders list:
  ```http
  GET /api/v1/orders?status=active&page=1&limit=10
  GET /api/v1/orders?status=delivered&page=1&limit=10
  GET /api/v1/orders?status=cancelled&page=1&limit=10
  ```

---
