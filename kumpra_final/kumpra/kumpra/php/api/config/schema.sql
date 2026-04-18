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
    street_zone    VARCHAR(100)
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
INSERT INTO clusters (barangay_name, street_zone) VALUES
('Mansilingan, Bacolod', 'Villa Zone A'),
('Taculing, Bacolod', 'Zone B'),
('Singcang, Bacolod', 'Zone C'),
('Bata, Bacolod', 'Zone D'),
('Tangub, Bacolod', 'Zone E');

INSERT INTO clusters (barangay_name, street_zone) VALUES
('Alijis, Bacolod', 'Zone F'),
('Banago, Bacolod', 'Zone G'),
('Burgos, Bacolod', 'Zone H'),
('Estefania, Bacolod', 'Zone I'),
('Mandalagan, Bacolod', 'Zone J');

INSERT INTO riders (name, plate_number, wallet_balance, work_shift) VALUES
('Juan Dela Cruz', 'BCD-1234', 0.0, 'Morning'),
('Pedro Santos',   'BCD-5678', 0.0, 'Morning'),
('Mario Reyes',    'BCD-9012', 0.0, 'Afternoon');

-- Create a sample open batch for today (cluster 1)
INSERT INTO batches (rider_id, status, current_count, size_limit, cluster_id)
VALUES (1, 'Gathering', 4, 12, 1);

INSERT INTO batches (rider_id, status, current_count, size_limit, cluster_id)
VALUES (2, 'Gathering', 2, 12, 1);
