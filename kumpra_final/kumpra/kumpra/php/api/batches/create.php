<?php
// kumpra/api/batches/create.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respond(['success' => false, 'message' => 'Method not allowed'], 405);
}

$userId = validateToken();
$body = getRequestBody();
$clusterId = (int)($body['cluster_id'] ?? 0);
$sizeLimit = (int)($body['size_limit'] ?? 6);

if ($clusterId <= 0) {
    respond(['success' => false, 'message' => 'cluster_id is required']);
}
if ($sizeLimit < 4) {
    $sizeLimit = 6;
}

$db = getDB();
$userIdColumn = getUsersIdColumn($db);

try {
    $stmt = $db->prepare('SELECT cluster_id FROM users WHERE ' . $userIdColumn . ' = ?');
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!$user || (int)$user['cluster_id'] !== $clusterId) {
        respond(['success' => false, 'message' => 'You can only create batches in your own cluster.']);
    }

    $stmt = $db->prepare('INSERT INTO batches (status, current_count, size_limit, cluster_id) VALUES (?, 0, ?, ?)');
    $stmt->execute(['Gathering', $sizeLimit, $clusterId]);
    $batchId = (int)$db->lastInsertId();

    $res = [
        'success' => true,
        'message' => 'Batch created successfully',
        'batch' => [
            'batch_id' => $batchId,
            'name' => 'NEW BATCH',
            'status' => 'Open',
            'departure' => date('h:i A'),
            'est_arrival' => date('h:i A', time() + 5700),
            'joined' => 0,
            'size_limit' => $sizeLimit,
            'shared_fee' => 300.0,
            'is_active' => true,
        ],
    ];
    respond($res);
} catch (PDOException $e) {
    error_log($e->getMessage());
    respond(['success' => false, 'message' => 'Failed to create batch'], 500);
}
