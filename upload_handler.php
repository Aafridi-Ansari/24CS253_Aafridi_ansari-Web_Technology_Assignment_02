<?php
/**
 * File Upload and Metadata Storage Handler
 * KPR StudentHub — Question 2 (CO4)
 * Author: Aafridi Ansari (24CS253)
 */

require_once 'db_connect.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $student_id = isset($_POST['student_id']) ? intval($_POST['student_id']) : 0;
    $file_category = isset($_POST['file_category']) ? trim($_POST['file_category']) : 'document';
    
    if (!$student_id) {
        echo json_encode(['success' => false, 'message' => 'Invalid Student ID']);
        exit;
    }

    if (!isset($_FILES['student_file']) || $_FILES['student_file']['error'] !== UPLOAD_ERR_OK) {
        echo json_encode(['success' => false, 'message' => 'File upload error or no file provided.']);
        exit;
    }

    $file = $_FILES['student_file'];
    $allowed_types = [
        'image/jpeg' => 'jpg',
        'image/png'  => 'png',
        'image/webp' => 'webp',
        'application/pdf' => 'pdf'
    ];
    $max_size = 5 * 1024 * 1024; // 5 MB

    // Validate File Size
    if ($file['size'] > $max_size) {
        echo json_encode(['success' => false, 'message' => 'File size exceeds maximum allowed limit (5 MB).']);
        exit;
    }

    // Validate MIME Type
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime = $finfo->file($file['tmp_name']);

    if (!array_key_exists($mime, $allowed_types)) {
        echo json_encode(['success' => false, 'message' => 'Invalid file format. Allowed: JPG, PNG, WEBP, PDF.']);
        exit;
    }

    $ext = $allowed_types[$mime];
    $upload_dir = '../uploads/';
    
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    // Unique filename to prevent overwriting
    $unique_name = 'doc_' . $student_id . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
    $destination = $upload_dir . $unique_name;
    $relative_path = 'uploads/' . $unique_name;

    if (move_uploaded_file($file['tmp_name'], $destination)) {
        // Store Metadata in MySQL
        try {
            $stmt = $pdo->prepare("INSERT INTO student_files (student_id, file_name, file_path, file_type, file_size, upload_date) VALUES (?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$student_id, $file['name'], $relative_path, $mime, $file['size']]);

            echo json_encode([
                'success' => true,
                'message' => 'File uploaded and metadata recorded successfully.',
                'file_id' => $pdo->lastInsertId(),
                'file_path' => $relative_path
            ]);
        } catch (Exception $e) {
            echo json_encode(['success' => false, 'message' => 'Database error: ' . $e->getMessage()]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to save file to server storage.']);
    }
}
?>
