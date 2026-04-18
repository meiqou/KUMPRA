<?php
// kumpra/api/auth/login.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(['success' => false, 'message' => 'Method not allowed'], 405);
}

$body = $_POST;
$username = trim($body['username'] ?? '');
$phone = trim($body['phone'] ?? '');
$clusterId = (int)($body['cluster_id'] ?? 0);

if (empty($username)) respond(['success' => false, 'message' => 'Username is required']);
if (strlen($phone) < 11) respond(['success' => false, 'message' => 'Invalid phone number']);

$db = getDB();

$stmt = $db->prepare('
    SELECT u.user_id AS user_id, u.full_name AS name, u.username, u.mobile_number AS phone_number, u.cluster_id, c.barangay_name
    FROM users u
    JOIN clusters c ON u.cluster_id = c.cluster_id
    WHERE u.mobile_number = ? AND u.username = ? AND u.cluster_id = ?
');
$stmt->execute([$phone, $username, $clusterId]);
$user = $stmt->fetch();

if (!$user) {
    respond(['success' => false, 'message' => 'No account found with that number. Please sign up.']);
}

$token = generateToken((int)$user['user_id']);

respond([
    'success' => true,
    'message' => 'Login successful',
    'user' => [
        'user_id' => $user['user_id'],
        'name' => $user['name'],
        'username' => $user['username'],
        'phone_number' => $user['phone_number'],
        'cluster_id' => $user['cluster_id'],
        'cluster_name' => $user['barangay_name'],
        'token' => $token,
    ],
]);
