# KUMPRA — Setup & Developer Guide

> Hyper-Local Cluster Delivery System for Bacolod City  
> Built with Flutter (Android) + PHP REST API + MySQL

---

## Project Structure

```
kumpra/
├── flutter/                    # Flutter mobile app
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── utils/
│       │   └── constants.dart          # API base URL, colors, theme
│       ├── services/
│       │   ├── api_service.dart        # HTTP client
│       │   ├── auth_service.dart       # Login / register / session
│       │   └── cart_provider.dart      # Cart state (Provider)
│       └── screens/
│           ├── onboarding_screen.dart  # Splash + 3-step onboarding
│           ├── home_screen.dart        # Batch discovery + nav bar
│           ├── market_rows_screen.dart # Product catalog (WET/MEAT/VEG/SPICES)
│           ├── basket_screen.dart      # Cart summary + send to rider
│           ├── order_tracking_screen.dart
│           ├── profile_screen.dart
│           └── auth/
│               ├── login_screen.dart
│               └── register_screen.dart
│
└── php/
    └── api/
        ├── .htaccess
        ├── config/
        │   ├── cors.php        # CORS headers
        │   ├── database.php    # PDO connection + JWT helpers
        │   └── schema.sql      # Full DB schema + seed data
        ├── auth/
        │   ├── login.php
        │   └── register.php
        ├── batches/
        │   ├── list.php        # GET  ?cluster_id=N
        │   └── join.php        # POST {batch_id}
        ├── orders/
        │   ├── create.php      # POST {batch_id, items[], estimated_total}
        │   ├── status.php      # GET  ?order_id=N
        │   └── history.php     # GET  (token required)
        └── clusters/
            └── list.php        # GET  (public)
```

---

## 1. PHP Backend Setup

### Requirements
- PHP 8.0+
- MySQL 5.7+ / MariaDB 10.4+
- Apache with mod_rewrite (XAMPP/WAMP/Laragon all work)

### Steps

1. **Copy files** — Place the `kumpra/php/api/` folder inside your web server root:
   ```
   C:/xampp/htdocs/kumpra/api/   (Windows XAMPP)
   /var/www/html/kumpra/api/     (Linux Apache)
   ```

2. **Create the database** — Open phpMyAdmin and run:
   ```
   kumpra/php/api/config/schema.sql
   ```
   This creates the `kumpra_db` database, all tables, and seed data.

3. **Edit credentials** — Open `config/database.php` and update:
   ```php
   define('DB_USER', 'your_mysql_username');
   define('DB_PASS', 'your_mysql_password');
   define('JWT_SECRET', 'any_long_random_string_here');
   ```

4. **Test the API** — Open a browser or Postman:
   ```
   GET http://localhost/kumpra/api/clusters/list.php
   ```
   You should see a JSON list of clusters.

---

## 2. Flutter App Setup

### Requirements
- Flutter SDK 3.13+
- Android Studio or VS Code
- Android device or emulator (Android 8.0+)

### Steps

1. **Set your server URL** — Edit `lib/utils/constants.dart`:
   ```dart
   // If testing on emulator (Android):
   static const String baseUrl = 'http://10.0.2.2/kumpra/api';

   // If testing on real device (use your PC's local IP):
   static const String baseUrl = 'http://192.168.1.XXX/kumpra/api';

   // If hosted on a server:
   static const String baseUrl = 'https://yourdomain.com/kumpra/api';
   ```
   > Find your PC's local IP: run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

2. **Install dependencies**:
   ```bash
   cd kumpra/flutter
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Build APK** (for distribution):
   ```bash
   flutter build apk --release
   # Output: build/app/outputs/flutter-apk/app-release.apk
   ```

---

## 3. API Endpoint Reference

All endpoints return `{ "success": true/false, ... }`.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `auth/register.php` | No | Register new user |
| POST | `auth/login.php` | No | Login with phone number |
| GET | `clusters/list.php` | No | Get all clusters |
| GET | `batches/list.php?cluster_id=N` | Yes | Get today's batches |
| POST | `batches/join.php` | Yes | Join a batch |
| POST | `orders/create.php` | Yes | Submit basket to rider |
| GET | `orders/status.php?order_id=N` | Yes | Track order status |
| GET | `orders/history.php` | Yes | Get past orders |

**Auth header format:**
```
Authorization: Bearer <token>
```

---

## 4. ABC Engine (Batch Auto-Lock Logic)

The Automated Batch Consolidation logic lives in `batches/join.php`:

| Event | Action |
|-------|--------|
| 4th user joins | Status → `Last_Call`, 10-min timer starts |
| Timer expires | Status → `Locked`, rider dispatched |
| 6th user joins (max) | Status → `Locked` immediately |
| Rider accepts | Status → `Purchasing` |
| Rider departs Libertad | Status → `In_Transit` |
| Delivery confirmed | Status → `Completed`, funds released |

---

## 5. Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile App | Flutter (Dart) |
| State Management | Provider |
| HTTP Client | `http` package |
| Local Storage | SharedPreferences |
| Backend | PHP 8 (REST API, no framework) |
| Database | MySQL / MariaDB |
| Auth | JWT (custom HS256 implementation) |
| DB Admin | phpMyAdmin |

---

## 6. Team

- **Glory Mae Plateros** — UI/UX Designer / Programmer  
- **Angel Britanico** — Data Collector

---

## 7. Key Constraints

- Orders restricted to the user's registered cluster (≤500m delivery radius)
- Maximum batch weight: **50 kg** (rider safety)
- Rider manually inputs actual item prices (vendors don't issue receipts)
- Target booking response time: **< 3 seconds**
- Compatible with Android 8.0 (Oreo) and above
