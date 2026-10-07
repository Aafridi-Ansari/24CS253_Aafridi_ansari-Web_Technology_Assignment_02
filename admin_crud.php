<?php
/**
 * Student CRUD Operations API
 * KPR StudentHub — Question 2 (CO4)
 * Author: Aafridi Ansari (24CS253)
 */

require_once 'db_connect.php';

header('Content-Type: application/json');

$action = isset($_GET['action']) ? $_GET['action'] : (isset($_POST['action']) ? $_POST['action'] : 'read');

try {
    switch ($action) {
        case 'create':
            // Add Student
            $name = trim($_POST['name']);
            $roll_number = trim($_POST['roll_number']);
            $email = trim($_POST['email']);
            $phone = trim($_POST['phone']);
            $department = trim($_POST['department']);
            $year_of_study = trim($_POST['year_of_study']);
            $course = trim($_POST['course']);
            $total_fee = floatval($_POST['total_fee']);
            $password_hash = password_hash($_POST['password'], PASSWORD_BCRYPT);

            $stmt = $pdo->prepare("INSERT INTO students (name, roll_number, email, phone, department, year_of_study, course, total_fee, password_hash, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())");
            $stmt->execute([$name, $roll_number, $email, $phone, $department, $year_of_study, $course, $total_fee, $password_hash]);

            echo json_encode(['success' => true, 'message' => 'Student registered successfully', 'id' => $pdo->lastInsertId()]);
            break;

        case 'read':
            // Get all students
            $stmt = $pdo->query("SELECT s.*, (SELECT COUNT(*) FROM student_files f WHERE f.student_id = s.id) AS file_count FROM students s ORDER BY s.id DESC");
            $students = $stmt->fetchAll();
            echo json_encode(['success' => true, 'data' => $students]);
            break;

        case 'view':
            // View single student details + uploaded files
            $id = intval($_GET['id']);
            $stmt = $pdo->prepare("SELECT * FROM students WHERE id = ?");
            $stmt->execute([$id]);
            $student = $stmt->fetch();

            if ($student) {
                $file_stmt = $pdo->prepare("SELECT * FROM student_files WHERE student_id = ?");
                $file_stmt->execute([$id]);
                $files = $file_stmt->fetchAll();
                echo json_encode(['success' => true, 'student' => $student, 'files' => $files]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Student not found']);
            }
            break;

        case 'update':
            // Edit Student
            $id = intval($_POST['id']);
            $name = trim($_POST['name']);
            $email = trim($_POST['email']);
            $phone = trim($_POST['phone']);
            $department = trim($_POST['department']);
            $year_of_study = trim($_POST['year_of_study']);
            $course = trim($_POST['course']);

            $stmt = $pdo->prepare("UPDATE students SET name = ?, email = ?, phone = ?, department = ?, year_of_study = ?, course = ?, updated_at = NOW() WHERE id = ?");
            $stmt->execute([$name, $email, $phone, $department, $year_of_study, $course, $id]);

            echo json_encode(['success' => true, 'message' => 'Student details updated successfully']);
            break;

        case 'delete':
            // Delete Student
            $id = intval($_POST['id']);
            
            // Unlink files first
            $file_stmt = $pdo->prepare("SELECT file_path FROM student_files WHERE student_id = ?");
            $file_stmt->execute([$id]);
            $files = $file_stmt->fetchAll();
            foreach ($files as $f) {
                if (file_exists('../' . $f['file_path'])) {
                    unlink('../' . $f['file_path']);
                }
            }

            $del_files = $pdo->prepare("DELETE FROM student_files WHERE student_id = ?");
            $del_files->execute([$id]);

            $del_stmt = $pdo->prepare("DELETE FROM students WHERE id = ?");
            $del_stmt->execute([$id]);

            echo json_encode(['success' => true, 'message' => 'Student and associated files removed successfully']);
            break;

        default:
            echo json_encode(['success' => false, 'message' => 'Invalid action requested']);
            break;
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
