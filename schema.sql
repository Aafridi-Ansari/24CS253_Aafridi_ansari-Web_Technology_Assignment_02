-- ============================================================
-- KPR StudentHub — Database Schema
-- Web Technology Assignment 2 | U21CS501
-- Course: B.E. Computer Science | Semester V / Section A
-- Author: Aafridi Ansari | Roll No: 24CS253
-- Ac.Yr: 2026-2027 | Submission: 14.10.2026
-- ============================================================

-- Create and use the database
CREATE DATABASE IF NOT EXISTS kpr_studenthub
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kpr_studenthub;

-- ────────────────────────────────────────────────────────────
-- TABLE: users
-- Stores admin and student portal login credentials
-- Equivalent to Session-protected login (PHP + $_SESSION)
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  username   VARCHAR(50)  NOT NULL UNIQUE,
  password   VARCHAR(255) NOT NULL COMMENT 'Store hashed with password_hash()',
  role       ENUM('admin','student') NOT NULL DEFAULT 'student',
  name       VARCHAR(100) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_username (username),
  INDEX idx_role (role)
) ENGINE=InnoDB COMMENT='Login users — admin and student portal';

-- ────────────────────────────────────────────────────────────
-- TABLE: students
-- Core student records — CRUD operations (Q2)
-- PHP PDO / JDBC PreparedStatement
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(100) NOT NULL,
  roll_number   VARCHAR(10)  NOT NULL UNIQUE COMMENT 'Format: YYXXNNN e.g. 24CS001',
  email         VARCHAR(150) NOT NULL UNIQUE,
  phone         VARCHAR(15),
  gender        ENUM('Male','Female','Other'),
  dob           DATE,
  course        VARCHAR(100) NOT NULL,
  year          ENUM('I','II','III','IV') NOT NULL,
  section       ENUM('A','B','C','D') NOT NULL,
  address       TEXT,
  hsc_percent   DECIMAL(5,2) CHECK (hsc_percent BETWEEN 0 AND 100),
  adm_year      YEAR,
  profile_image VARCHAR(300) COMMENT 'Relative file path: uploads/profile/filename.jpg',
  status        ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_roll   (roll_number),
  INDEX idx_email  (email),
  INDEX idx_course (course),
  INDEX idx_year   (year),
  INDEX idx_status (status),
  FULLTEXT INDEX ft_search (name, roll_number, email)   -- for LIKE/FULLTEXT search
) ENGINE=InnoDB COMMENT='Student master records — Q2 CRUD target';

-- ────────────────────────────────────────────────────────────
-- TABLE: student_files
-- Stores metadata for uploaded files (Q2 File Upload)
-- PHP: move_uploaded_file() | Servlet: Part.write()
-- Path stored here; actual file lives in /uploads/
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS student_files (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  student_id  INT NOT NULL,
  file_name   VARCHAR(255) NOT NULL COMMENT 'Original filename',
  file_path   VARCHAR(500) NOT NULL COMMENT 'Server path: uploads/docs/studentId/filename',
  file_type   VARCHAR(100) NOT NULL COMMENT 'MIME type: image/jpeg, application/pdf, etc.',
  file_size   INT UNSIGNED  NOT NULL COMMENT 'File size in bytes',
  doc_type    ENUM('profile_image','id_proof','certificate','marksheet','other')
              NOT NULL DEFAULT 'other',
  upload_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_files_student
    FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE CASCADE ON UPDATE CASCADE,

  INDEX idx_student_id (student_id),
  INDEX idx_doc_type   (doc_type),
  -- Prevent duplicate filenames per student (no overwriting)
  UNIQUE KEY uq_student_file (student_id, file_name)
) ENGINE=InnoDB COMMENT='File metadata — Q2 upload tracking';

-- ────────────────────────────────────────────────────────────
-- TABLE: sessions (optional — for PHP session tracking)
-- Replaces file-based PHP sessions with DB sessions
-- ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sessions (
  session_id   VARCHAR(128) PRIMARY KEY,
  user_id      INT NOT NULL,
  ip_address   VARCHAR(45),
  user_agent   TEXT,
  payload      TEXT NOT NULL COMMENT 'Serialized session data',
  last_activity INT UNSIGNED NOT NULL,

  CONSTRAINT fk_sessions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,

  INDEX idx_user_id       (user_id),
  INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB COMMENT='DB-backed session store';

-- ────────────────────────────────────────────────────────────
-- SEED DATA: Users
-- Default admin and student portal credentials
-- In PHP: password_hash("Admin@123", PASSWORD_BCRYPT)
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO users (username, password, role, name) VALUES
  ('admin',   '$2y$12$exampleHashAdmin....',   'admin',   'Administrator'),
  ('student', '$2y$12$exampleHashStudent....',  'student', 'Student Viewer');
  -- NOTE: Replace hashes with actual password_hash() output before deploying

-- ────────────────────────────────────────────────────────────
-- SEED DATA: Students
-- Sample records for demonstration
-- ────────────────────────────────────────────────────────────
INSERT IGNORE INTO students
  (name, roll_number, email, phone, gender, dob, course, year, section, address, status)
VALUES
  ('Arjun Sharma',     '24CS001', 'arjun.sharma@kpriet.ac.in', '9876543210', 'Male',   '2003-05-12',
   'B.E. Computer Science',             'III', 'A', '12, Gandhi Nagar, Coimbatore - 641001', 'active'),
  ('Priya Lakshmi',    '24CS002', 'priya.l@kpriet.ac.in',      '9876543211', 'Female', '2003-08-22',
   'B.E. Computer Science',             'III', 'A', '45, Rose Street, Tiruppur - 641604',    'active'),
  ('Mohammed Aafridi', '24CS003', 'aafridi@kpriet.ac.in',      '9876543212', 'Male',   '2003-01-15',
   'B.E. Computer Science',             'III', 'A', '78, Nehru Road, Erode - 638001',        'active'),
  ('Kavitha Devi',     '24CS004', 'kavitha.d@kpriet.ac.in',    '9876543213', 'Female', '2004-03-30',
   'B.Tech Information Technology',     'II',  'B', '3, Anna Salai, Salem - 636001',          'active'),
  ('Ravi Kumar',       '24EC001', 'ravi.k@kpriet.ac.in',       '9876543214', 'Male',   '2002-11-08',
   'B.E. Electronics & Communication',  'IV',  'A', '55, Market Road, Pollachi - 642001',     'inactive');

-- ────────────────────────────────────────────────────────────
-- USEFUL QUERIES (Reference for PHP/Servlet code)
-- ────────────────────────────────────────────────────────────

-- Q1: SELECT for registration form (check duplicates before INSERT)
-- SELECT COUNT(*) FROM students WHERE roll_number = ? OR email = ?;

-- Q2 CRUD:
-- CREATE: INSERT INTO students (name, roll_number, email, ...) VALUES (?,?,?,...);
-- READ:   SELECT s.*, GROUP_CONCAT(f.file_path) AS files FROM students s LEFT JOIN student_files f ON s.id=f.student_id WHERE s.id=?;
-- UPDATE: UPDATE students SET name=?, email=?, ... WHERE id=?;
-- DELETE: DELETE FROM students WHERE id=?;  -- cascades to student_files

-- Q2 File Upload:
-- INSERT INTO student_files (student_id, file_name, file_path, file_type, file_size, doc_type) VALUES (?,?,?,?,?,?);
-- Check overwrite: SELECT COUNT(*) FROM student_files WHERE student_id=? AND file_name=?;

-- Q3 Portal (Servlet JDBC + JSP):
-- SELECT s.id, s.name, s.roll_number, s.email, s.course, s.year, s.section, s.profile_image,
--        f.file_path, f.file_type, f.file_name, f.upload_date
-- FROM students s
-- LEFT JOIN student_files f ON s.id = f.student_id
-- WHERE s.status = 'active'
-- ORDER BY s.name ASC;

-- Session check (PHP):
-- session_start();
-- if (!isset($_SESSION['user'])) { header("Location: index.html"); exit; }

-- Full-text search:
-- SELECT * FROM students WHERE MATCH(name, roll_number, email) AGAINST (? IN BOOLEAN MODE);

-- ────────────────────────────────────────────────────────────
-- PHP CONNECTION EXAMPLE (config.php)
-- ────────────────────────────────────────────────────────────
/*
<?php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'kpr_studenthub');
define('UPLOAD_DIR', __DIR__ . '/uploads/');
define('MAX_FILE_SIZE', 5 * 1024 * 1024); // 5 MB
define('ALLOWED_TYPES', ['image/jpeg','image/png','image/webp','application/pdf']);

try {
  $pdo = new PDO(
    "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
    DB_USER, DB_PASS,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
  );
} catch (PDOException $e) {
  die("Database connection failed: " . $e->getMessage());
}
?>
*/

-- ────────────────────────────────────────────────────────────
-- SERVLET JDBC CONNECTION EXAMPLE (DBConnection.java)
-- ────────────────────────────────────────────────────────────
/*
import java.sql.*;

public class DBConnection {
  private static final String URL  = "jdbc:mysql://localhost:3306/kpr_studenthub?useSSL=false";
  private static final String USER = "root";
  private static final String PASS = "";

  static {
    try { Class.forName("com.mysql.cj.jdbc.Driver"); }
    catch (ClassNotFoundException e) { throw new RuntimeException(e); }
  }

  public static Connection getConnection() throws SQLException {
    return DriverManager.getConnection(URL, USER, PASS);
  }
}
// Usage in Servlet doGet():
// Connection conn = DBConnection.getConnection();
// PreparedStatement ps = conn.prepareStatement("SELECT * FROM students WHERE status='active'");
// ResultSet rs = ps.executeQuery();
// while (rs.next()) {
//   request.setAttribute("name", rs.getString("name"));
//   request.setAttribute("photo", rs.getString("profile_image"));
// }
// request.getRequestDispatcher("/WEB-INF/portal.jsp").forward(request, response);
*/
