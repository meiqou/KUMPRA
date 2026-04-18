<?php
// kumpra/api/config/database.php

define('DB_HOST', 'localhost');
define('DB_NAME', 'u793073111_kumpra');
define('DB_USER', 'u793073111_kumpra');
define('DB_PASS', 'Kumpra123');
define('JWT_SECRET', 'kumpra_secret_key_change_this_in_production');

function getDB(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        try {
            $pdo = new PDO(
                "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
                DB_USER,
                DB_PASS,
                [
                    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES   => false,
                ]
            );
        } catch (PDOException $e) {
            error_log('Database connection failed: ' . $e->getMessage());
            http_response_code(500);
            die(json_encode(['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()]));
        }
    }
    return $pdo;
}

// FIX: Removed the duplicate respond() definition that was here previously.
//      respond() is already defined in cors.php, which is always require_once'd first.
//      Having two definitions caused a PHP Fatal Error: "Cannot redeclare respond()".

function getRequestBody(): array {
    $raw = file_get_contents('php://input');
    return json_decode($raw, true) ?? [];
}

// Simple JWT implementation
function generateToken(int $userId): string {
    $header    = base64_encode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));
    $payload   = base64_encode(json_encode([
        'user_id' => $userId,
        'exp'     => time() + (30 * 24 * 60 * 60), // 30 days
    ]));
    $signature = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    return "$header.$payload.$signature";
}

function validateToken(): int {
    $headers = getallheaders();
    $auth    = $headers['Authorization'] ?? '';
    if (!str_starts_with($auth, 'Bearer ')) {
        respond(['success' => false, 'message' => 'Unauthorized'], 401);
    }
    $token = substr($auth, 7);
    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        respond(['success' => false, 'message' => 'Invalid token'], 401);
    }
    [$header, $payload, $sig] = $parts;
    $expectedSig = base64_encode(hash_hmac('sha256', "$header.$payload", JWT_SECRET, true));
    if ($sig !== $expectedSig) {
        respond(['success' => false, 'message' => 'Invalid token'], 401);
    }
    $data = json_decode(base64_decode($payload), true);
    if ($data['exp'] < time()) {
        respond(['success' => false, 'message' => 'Token expired'], 401);
    }
    return (int) $data['user_id'];
}