-- ============================================
-- KUMPRA DATABASE SCHEMA
-- Run this in phpMyAdmin or MySQL CLI
-- ============================================

CREATE DATABASE IF NOT EXISTS kumpra_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kumpra_db;

-- ─────────────────────────────────────────────
-- CLUSTERS (geographic delivery zones)
-- ─────────────────────────────────────────────
CREATE TABLE clusters (
    cluster_id     INT AUTO_INCREMENT PRIMARY KEY,
    barangay_name  VARCHAR(100) NOT NULL,
    street_zone    VARCHAR(100),
    latitude       DECIMAL(10, 8),
    longitude      DECIMAL(11, 8)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- RIDERS
-- ─────────────────────────────────────────────
CREATE TABLE riders (
    rider_id              INT AUTO_INCREMENT PRIMARY KEY,
    name                  VARCHAR(100) NOT NULL,
    plate_number          VARCHAR(20),
    wallet_balance        FLOAT DEFAULT 0,
    availability_schedule VARCHAR(255),
    work_shift            VARCHAR(50)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────
CREATE TABLE users (
    user_id              INT AUTO_INCREMENT PRIMARY KEY,
    full_name            VARCHAR(100) NOT NULL,
    username             VARCHAR(50) NOT NULL UNIQUE,
    email                VARCHAR(150) NOT NULL UNIQUE,
    mobile_number        VARCHAR(15) NOT NULL UNIQUE,
    password             VARCHAR(255) NOT NULL,
    cluster_id           INT NOT NULL,
    created_at           DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- BATCHES
-- ─────────────────────────────────────────────
CREATE TABLE batches (
    batch_id              INT AUTO_INCREMENT PRIMARY KEY,
    rider_id              INT,
    status                ENUM('Gathering','Last_Call','Locked','Purchasing','In_Transit','Completed','Cancelled')
                          NOT NULL DEFAULT 'Gathering',
    current_count         INT DEFAULT 0,
    threshold_reached_at  DATETIME,
    timer_expiry          DATETIME,
    load_capacity_kg      FLOAT DEFAULT 50.0,
    total_weight          FLOAT DEFAULT 0,
    size_limit            INT DEFAULT 12,
    cluster_id            INT NOT NULL,
    created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (rider_id)  REFERENCES riders(rider_id),
    FOREIGN KEY (cluster_id) REFERENCES clusters(cluster_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- ORDERS
-- ─────────────────────────────────────────────
CREATE TABLE orders (
    order_id               INT AUTO_INCREMENT PRIMARY KEY,
    user_id                INT NOT NULL,
    batch_id               INT NOT NULL,
    status                 ENUM('Pending','Confirmed','Purchased','Delivered','Cancelled')
                           NOT NULL DEFAULT 'Pending',
    estimated_total        FLOAT DEFAULT 0,
    actual_final_total     FLOAT DEFAULT 0,
    payment_status         ENUM('Unpaid','Paid','Refunded') DEFAULT 'Unpaid',
    payment_transaction_id VARCHAR(100),
    created_at             DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at             DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    delivered_at           DATETIME,
    FOREIGN KEY (user_id)  REFERENCES users(user_id),
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id)
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- ORDER ITEMS
-- ─────────────────────────────────────────────
CREATE TABLE order_items (
    item_id           INT AUTO_INCREMENT PRIMARY KEY,
    order_id          INT NOT NULL,
    item_name         VARCHAR(100) NOT NULL,
    quantity          VARCHAR(50),
    user_est_price    FLOAT DEFAULT 0,
    rider_actual_price FLOAT DEFAULT 0,
    actual_price_paid  FLOAT DEFAULT 0,
    weight_kg         FLOAT DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ─────────────────────────────────────────────
-- SEED DATA
-- ─────────────────────────────────────────────
TRUNCATE TABLE clusters;
INSERT INTO clusters (cluster_id, barangay_name, street_zone, latitude, longitude) VALUES
(1, 'Alijis', 'Main Zone', 10.64160000, 122.95420000),
(2, 'Banago', 'Coastal Zone', 10.70320000, 122.94230000),
(3, 'Bata', 'Zone 1', 10.70920000, 122.96450000),
(4, 'Cabug', 'Purok Main', 10.60670000, 122.94670000),
(5, 'Estefania', 'Fortune Town', 10.68500000, 122.98000000),
(6, 'Felisa', 'Relocation Site', 10.60330000, 122.97830000),
(7, 'Granada', 'Proper', 10.67330000, 123.02330000),
(8, 'Handumanan', 'Phase 1', 10.61330000, 122.97330000),
(9, 'Mandalagan', 'Luzuriaga', 10.69760000, 122.96090000),
(10, 'Mansilingan', 'Hermelinda Drive', 10.64330000, 122.96420000),
(11, 'Pahanocoy', 'CECHO', 10.61500000, 122.93500000),
(12, 'Punta Taytay', 'Beach Area', 10.59330000, 122.92330000),
(13, 'Singcang-Airport', 'Miramar', 10.64500000, 122.93500000),
(14, 'Sum-ag', 'Public Market Area', 10.60330000, 122.93330000),
(15, 'Taculing', 'City Heights', 10.65580000, 122.94920000),
(16, 'Tangub', 'Golden River', 10.62800000, 122.93800000),
(17, 'Villamonte', 'Shopping', 10.67500000, 122.96800000),
(18, 'Vista Alegre', 'Relocation', 10.65000000, 122.99000000),
(19, 'Barangay 1', 'North Capitol', 10.67750000, 122.94750000),
(20, 'Barangay 16', 'Libertad', 10.66360000, 122.94820000),
(21, 'Barangay 23', 'Paglaum', 10.67050000, 122.95550000),
(22, 'Barangay 35', 'Reclamation', 10.67800000, 122.94100000),
(23, 'Montevista', 'Zone 1', 10.68000000, 122.97200000);

INSERT INTO riders (name, plate_number, wallet_balance, work_shift) VALUES
('Juan Dela Cruz', 'BCD-1234', 0.0, 'Morning'),
('Pedro Santos',   'BCD-5678', 0.0, 'Morning'),
('Mario Reyes',    'BCD-9012', 0.0, 'Afternoon');

-- Create a sample open batch for today (cluster 1)
INSERT INTO batches (rider_id, status, current_count, size_limit, cluster_id)
VALUES (1, 'Gathering', 4, 12, 1);

INSERT INTO batches (rider_id, status, current_count, size_limit, cluster_id)
VALUES (2, 'Gathering', 2, 12, 1);
