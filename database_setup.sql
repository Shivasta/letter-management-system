-- MEF Portal Database Setup SQL Queries
-- Run these queries in MySQL to set up the database manually

-- ============================================
-- CREATE DATABASE
-- ============================================
CREATE DATABASE IF NOT EXISTS mefportal;
USE mefportal;

-- ============================================
-- CREATE TABLES
-- ============================================

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('Student', 'Mentor', 'Advisor', 'HOD') DEFAULT 'Student',
    password VARCHAR(512),
    register_number VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    year VARCHAR(10) DEFAULT '1',
    dob DATE NOT NULL,
    student_type ENUM('Day Scholar', 'Hosteller') DEFAULT 'Day Scholar',
    mentor_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Requests table
CREATE TABLE IF NOT EXISTS requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    status ENUM('Pending', 'Mentor Approved', 'Mentor Rejected', 'Advisor Approved', 'Advisor Rejected', 'Approved', 'Rejected') DEFAULT 'Pending',
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    request_type ENUM('Leave', 'Permission', 'Apology', 'Bonafide', 'OD') DEFAULT 'Leave',
    advisor_note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Permissions table
CREATE TABLE IF NOT EXISTS permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    custom_subject VARCHAR(200) NOT NULL,
    reason TEXT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Auth lockouts table
CREATE TABLE IF NOT EXISTS auth_lockouts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    register_number VARCHAR(50) UNIQUE NOT NULL,
    failed_attempts INT NOT NULL DEFAULT 0,
    lockout_until DATETIME NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Push subscriptions table
CREATE TABLE IF NOT EXISTS push_subscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    endpoint TEXT NOT NULL,
    p256dh VARCHAR(255),
    auth VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uniq_user_endpoint (user_id, endpoint(255)),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    request_id INT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(50) NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ============================================
-- CREATE INDEXES (for performance)
-- ============================================

-- Users table indexes
CREATE INDEX idx_users_register_number ON users(register_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_department ON users(department);

-- Requests table indexes
CREATE INDEX idx_requests_user_id ON requests(user_id);
CREATE INDEX idx_requests_user_created ON requests(user_id, created_at);
CREATE INDEX idx_requests_status_dept ON requests(status, department);
CREATE INDEX idx_requests_created_at ON requests(created_at);

-- Notifications table indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at);

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- Note: Passwords should be hashed using werkzeug.security.generate_password_hash()
-- Example: generate_password_hash('password123')

-- HOD User
-- INSERT INTO users (username, name, role, register_number, email, department, year, dob, password)
-- VALUES ('hod001', 'Dr. John Smith', 'HOD', 'HOD001', 'hod@mefportal.edu', 'computer science', '1', '1975-01-15', 'pbkdf2:sha256:260000$randomsalt$hashedpassword');

-- Advisor User
-- INSERT INTO users (username, name, role, register_number, email, department, year, dob, password)
-- VALUES ('advisor001', 'Prof. Jane Doe', 'Advisor', 'ADV001', 'advisor@mefportal.edu', 'computer science', '1', '1980-05-20', 'pbkdf2:sha256:260000$randomsalt$hashedpassword');

-- Mentor User
-- INSERT INTO users (username, name, role, register_number, email, department, year, dob, password)
-- VALUES ('mentor001', 'Dr. Mike Johnson', 'Mentor', 'MEN001', 'mentor@mefportal.edu', 'computer science', '1', '1985-08-10', 'pbkdf2:sha256:260000$randomsalt$hashedpassword');

-- Student User
-- INSERT INTO users (username, name, role, register_number, email, department, year, dob, student_type, mentor_email, password)
-- VALUES ('student001', 'Alice Student', 'Student', '2025001', 'alice@student.edu', 'computer science', '2', '2003-12-01', 'Day Scholar', 'mentor@mefportal.edu', 'pbkdf2:sha256:260000$randomsalt$hashedpassword');

-- ============================================
-- COMMON QUERIES
-- ============================================

-- Get all users
-- SELECT * FROM users;

-- Get all requests for a user
-- SELECT * FROM requests WHERE user_id = 1 ORDER BY created_at DESC;

-- Get pending requests for a department (for Mentor)
-- SELECT * FROM requests WHERE status = 'Pending' AND department = 'computer science';

-- Get mentor-approved requests (for Advisor)
-- SELECT * FROM requests WHERE status = 'Mentor Approved' AND department = 'computer science';

-- Get all requests for HOD dashboard
-- SELECT * FROM requests WHERE department = 'computer science' ORDER BY created_at DESC DESC DESC '

-- created user_id
--hpassword;

</ id, '0 WHERE department = 'computer science';
