<?php
// kumpra/api/auth/register.php
require_once '../config/cors.php';
require_once '../config/database.php';

// Catch any fatal errors
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error !== null) {
        error_log('Fatal error in register.php: ' . json_encode($error));
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Server error occurred']);
        exit;
    }
});

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(['success' => false, 'message' => 'Invalid request method'], 405);
}

$data = $_POST;

// Debug: log the received data
error_log('Register data: ' . json_encode($data));
error_log('POST data: ' . json_encode($_POST));
error_log('REQUEST_METHOD: ' . $_SERVER['REQUEST_METHOD']);

// --- Input Validation ---
// FIX: Keys were accidentally set to literal sample values ('glory mei', '09304628769')
//      instead of the actual field names sent by the Flutter app.
$fullName  = trim($data['name'] ?? '');
$username  = trim($data['username'] ?? '');
$phone     = trim($data['phone'] ?? '');
$clusterId = filter_var($data['cluster_id'] ?? '', FILTER_VALIDATE_INT);

if (empty($fullName)) {
    respond(['success' => false, 'message' => 'Name is required.'], 400);
}
if (empty($username)) {
    respond(['success' => false, 'message' => 'Username is required.'], 400);
}
if (empty($phone) || !preg_match('/^09\d{9}$/', $phone)) {
    respond(['success' => false, 'message' => 'A valid 11-digit phone number is required (e.g., 09xxxxxxxxx).'], 400);
}
if ($clusterId === false || $clusterId <= 0) {
    respond(['success' => false, 'message' => 'A valid cluster must be selected.'], 400);
}

try {
    $pdo = getDB();

    // Validate that the chosen cluster exists in the database.
    $clusterStmt = $pdo->prepare("SELECT 1 FROM clusters WHERE cluster_id = ?");
    $clusterStmt->execute([$clusterId]);
    if (!$clusterStmt->fetch()) {
        respond(['success' => false, 'message' => 'The selected cluster does not exist. Please choose a valid barangay.'], 400);
    }

    // Check if username already exists
    $usernameStmt = $pdo->prepare("SELECT user_id FROM users WHERE username = ?");
    $usernameStmt->execute([$username]);
    if ($usernameStmt->fetch()) {
        respond(['success' => false, 'message' => 'This username is already taken.'], 409);
    }

    // Check if phone number already exists
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE mobile_number = ?");
    $stmt->execute([$phone]);
    if ($stmt->fetch()) {
        respond(['success' => false, 'message' => 'This phone number is already registered.'], 409);
    }

    // Insert new user
    $sql = "INSERT INTO users (full_name, username, mobile_number, cluster_id, password, role, is_verified, created_at)
            VALUES (?, ?, ?, ?, '', 'user', 0, NOW())";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$fullName, $username, $phone, $clusterId]);

    $newUserId = $pdo->lastInsertId();

    // Fetch the new user's full details for the session
    $stmt = $pdo->prepare("
        SELECT
            u.user_id AS user_id,
            u.full_name AS name,
            u.username,
            u.mobile_number AS phone_number,
            u.cluster_id,
            c.barangay_name AS cluster_name
        FROM users u
        JOIN clusters c ON u.cluster_id = c.cluster_id
        WHERE u.user_id = ?
    ");
    $stmt->execute([$newUserId]);
    $user = $stmt->fetch();

    $token = generateToken((int)$user['user_id']);
    $user['token'] = $token;

    respond(['success' => true, 'user' => $user]);

} catch (PDOException $e) {
    error_log('Database error in register.php: ' . $e->getMessage());
    respond(['success' => false, 'message' => 'Database error: ' . $e->getMessage()], 500);