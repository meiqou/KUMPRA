<?php
// kumpra/api/batches/list.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    respond(['success' => false, 'message' => 'Method not allowed'], 405);
}

$userId = validateToken();
$clusterId = (int)($_GET['cluster_id'] ?? 0);

if ($clusterId <= 0) {
    respond(['success' => false, 'message' => 'cluster_id is required']);
}

$db = getDB();

$stmt = $db->prepare('
    SELECT 
        b.batch_id,
        b.status,
        b.current_count,
        b.size_limit,
        b.threshold_reached_at,
        b.timer_expiry,
        b.load_capacity_kg,
        b.total_weight,
        b.created_at,
        r.name AS rider_name,
        r.plate_number,
        c.barangay_name,
        c.street_zone,
        CASE WHEN o.order_id IS NOT NULL THEN 1 ELSE 0 END AS user_joined
    FROM batches b
    JOIN clusters c ON b.cluster_id = c.cluster_id
    LEFT JOIN riders r ON b.rider_id = r.rider_id
    LEFT JOIN orders o ON o.batch_id = b.batch_id AND o.user_id = ?
    WHERE b.cluster_id = ?
      AND DATE(b.created_at) = CURDATE()
      AND b.status NOT IN ("Completed", "Cancelled")
    ORDER BY b.created_at ASC
');
$stmt->execute([$userId, $clusterId]);
$rows = $stmt->fetchAll();

// Format for the app
$batches = array_map(function($row) {
    $departure = date('h:i A', strtotime($row['created_at']));
    $arrival = date('h:i A', strtotime($row['created_at']) + 5700); // ~95 mins
    $fee = $row['current_count'] > 0
        ? round(300 / max($row['current_count'], 1), 2)
        : 300.0;

    $statusMap = [
        'Gathering'  => 'Open',
        'Last_Call'  => 'Last Call',
        'Locked'     => 'Departing Soon',
        'Purchasing' => 'At Market',
        'In_Transit' => 'On the Way',
    ];

    return [
        'batch_id'    => (int)$row['batch_id'],
        'name'        => strtoupper($row['barangay_name']) . '-' . $row['batch_id'],
        'status'      => $statusMap[$row['status']] ?? $row['status'],
        'departure'   => $departure,
        'est_arrival' => $arrival,
        'joined'      => (int)$row['current_count'],
        'size_limit'  => (int)$row['size_limit'],
        'shared_fee'  => $fee,
        'is_active'   => in_array($row['status'], ['Gathering', 'Last_Call']),
        'user_joined' => (bool)$row['user_joined'],
        'rider_name'  => $row['rider_name'],
    ];
}, $rows);

respond(['success' => true, 'batches' => $batches]);
