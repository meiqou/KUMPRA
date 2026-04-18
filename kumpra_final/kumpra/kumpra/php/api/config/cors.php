<?php
// Prevent any accidental output before headers
ob_start();

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

/**
 * Standardized JSON response helper
 */
function respond(array $data, int $status = 200): void {
    // Clear buffer to ensure only the JSON is sent
    if (ob_get_length()) ob_clean();
    
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

// Handle Preflight OPTIONS request immediately
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}