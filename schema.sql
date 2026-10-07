-- ============================================================
-- KPR StudentHub — Database Schema & DDL Script
-- Web Technology Assignment 2 | MySQL 8.0+
-- Author: Aafridi Ansari (Roll No: 24CS253)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `kpr_studenthub` 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE `kpr_studenthub`;

-- 1. Departments Table
CREATE TABLE IF NOT EXISTS `departments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `dept_code` VARCHAR(10) NOT NULL UNIQUE,
    `dept_name` VARCHAR(100) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Students Master Table
CREATE TABLE IF NOT EXISTS `students` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `roll_number` VARCHAR(20) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `phone` VARCHAR(15) NOT NULL,
    `gender` ENUM('Male', 'Female', 'Other') NOT NULL,
    `dob` DATE NOT NULL,
    `department` VARCHAR(100) NOT NULL,
    `year_of_study` VARCHAR(20) NOT NULL,
    `course` VARCHAR(100) NOT NULL,
    `address` TEXT,
    `profile_image` VARCHAR(255) DEFAULT 'default-avatar.png',
    `tuition_fee` DECIMAL(10, 2) NOT NULL DEFAULT 120000.00,
    `lab_fee` DECIMAL(10, 2) NOT NULL DEFAULT 15000.00,
    `hostel_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `transport_fee` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `total_fee` DECIMAL(10, 2) NOT NULL,
    `fee_status` ENUM('Paid', 'Pending', 'Partial') DEFAULT 'Pending',
    `password_hash` VARCHAR(255) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_roll` (`roll_number`),
    INDEX `idx_dept` (`department`),
    INDEX `idx_email` (`email`)
) ENGINE=InnoDB;

-- 3. Student Uploaded Files & Metadata Table (Question 2 & 3)
CREATE TABLE IF NOT EXISTS `student_files` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `file_name` VARCHAR(255) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `file_type` VARCHAR(100) NOT NULL,
    `file_size` BIGINT NOT NULL,
    `upload_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Courses Table
CREATE TABLE IF NOT EXISTS `courses` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `course_code` VARCHAR(20) NOT NULL UNIQUE,
    `course_title` VARCHAR(150) NOT NULL,
    `credits` INT NOT NULL DEFAULT 3,
    `faculty_name` VARCHAR(100) NOT NULL,
    `semester` VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- 5. Student Course Enrollments Table
CREATE TABLE IF NOT EXISTS `enrollments` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `attendance_pct` DECIMAL(5, 2) DEFAULT 85.00,
    `grade` VARCHAR(5) DEFAULT 'A',
    `enrollment_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_student_course` (`student_id`, `course_id`)
) ENGINE=InnoDB;

-- 6. System Users & Admin Logins Table
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('Admin', 'Student', 'Faculty') NOT NULL DEFAULT 'Student',
    `linked_student_id` INT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`linked_student_id`) REFERENCES `students`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ============================================================
-- Sample Initial Seed Data
-- ============================================================

INSERT INTO `departments` (`dept_code`, `dept_name`) VALUES
('CSE', 'Computer Science and Engineering'),
('AI&DS', 'Artificial Intelligence and Data Science'),
('ECE', 'Electronics and Communication Engineering'),
('MECH', 'Mechanical Engineering'),
('IT', 'Information Technology')
ON DUPLICATE KEY UPDATE `dept_name` = VALUES(`dept_name`);

INSERT INTO `courses` (`course_code`, `course_title`, `credits`, `faculty_name`, `semester`) VALUES
('CS8501', 'Web Technology & Cloud Computing', 4, 'Dr. K. Senthil Kumar', 'Semester V'),
('CS8502', 'Database Management Systems & SQL', 4, 'Prof. M. Rajeshwari', 'Semester V'),
('CS8503', 'Theory of Computation', 3, 'Dr. S. Anitha', 'Semester V'),
('CS8504', 'Artificial Intelligence & Neural Nets', 3, 'Dr. P. Prakash', 'Semester V'),
('CS8511', 'Web Applications Laboratory', 2, 'Prof. A. Vignesh', 'Semester V')
ON DUPLICATE KEY UPDATE `course_title` = VALUES(`course_title`);

INSERT INTO `students` (`id`, `roll_number`, `name`, `email`, `phone`, `gender`, `dob`, `department`, `year_of_study`, `course`, `address`, `profile_image`, `total_fee`, `fee_status`, `password_hash`) VALUES
(1, '24CS253', 'Aafridi Ansari', 'aafridi.ansari@kpriet.ac.in', '9876543210', 'Male', '2004-05-15', 'Computer Science and Engineering', '3rd Year', 'B.E Computer Science and Engineering', '45 Green Valley Avenue, Coimbatore - 641407', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', 165000.00, 'Paid', '$2y$10$e8wFvQW2Q68V8K72b1yq9O81W.G.V53Y3y10uO1W9kHqP8y72gW1K'),
(2, '24CS001', 'Priya Sharma', 'priya.sharma@kpriet.ac.in', '9123456780', 'Female', '2004-08-20', 'Computer Science and Engineering', '3rd Year', 'B.E Computer Science and Engineering', '12 Rose Gardens, Coimbatore', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150', 145000.00, 'Paid', '$2y$10$e8wFvQW2Q68V8K72b1yq9O81W.G.V53Y3y10uO1W9kHqP8y72gW1K'),
(3, '24AI012', 'Rahul Verma', 'rahul.verma@kpriet.ac.in', '9988776655', 'Male', '2003-11-10', 'Artificial Intelligence and Data Science', '4th Year', 'B.Tech AI & Data Science', '88 Tech Park Road, Coimbatore', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 155000.00, 'Pending', '$2y$10$e8wFvQW2Q68V8K72b1yq9O81W.G.V53Y3y10uO1W9kHqP8y72gW1K')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

INSERT INTO `student_files` (`student_id`, `file_name`, `file_path`, `file_type`, `file_size`) VALUES
(1, 'Aafridi_Profile_Photo.jpg', 'uploads/doc_1_photo.jpg', 'image/jpeg', 245760),
(1, 'HSC_12th_Marksheet.pdf', 'uploads/doc_1_hsc.pdf', 'application/pdf', 1048576),
(1, 'Aadhaar_ID_Proof.pdf', 'uploads/doc_1_aadhaar.pdf', 'application/pdf', 524288)
ON DUPLICATE KEY UPDATE `file_name` = VALUES(`file_name`);

INSERT INTO `enrollments` (`student_id`, `course_id`, `attendance_pct`, `grade`) VALUES
(1, 1, 94.50, 'A+'),
(1, 2, 91.00, 'A'),
(1, 3, 88.50, 'A'),
(1, 4, 96.00, 'O'),
(1, 5, 98.00, 'O')
ON DUPLICATE KEY UPDATE `attendance_pct` = VALUES(`attendance_pct`);

INSERT INTO `users` (`username`, `email`, `password_hash`, `role`, `linked_student_id`) VALUES
('admin', 'admin@kpriet.ac.in', '$2y$10$e8wFvQW2Q68V8K72b1yq9O81W.G.V53Y3y10uO1W9kHqP8y72gW1K', 'Admin', NULL),
('24CS253', 'aafridi.ansari@kpriet.ac.in', '$2y$10$e8wFvQW2Q68V8K72b1yq9O81W.G.V53Y3y10uO1W9kHqP8y72gW1K', 'Student', 1)
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);
