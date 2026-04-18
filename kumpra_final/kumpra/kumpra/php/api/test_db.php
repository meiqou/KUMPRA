<?php
// Test database connection
header('Content-Type: text/plain');
echo "Testing database connection...\n";

require_once '../config/database.php';

echo "Config loaded. Attempting connection...\n";

try {
    $db = getDB();
    echo "SUCCESS: Database connected successfully!\n";
    echo json_encode(['success' => true, 'message' => 'Database connected successfully']);
} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Full error details:\n";
    echo json_encode(['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()]);
}

