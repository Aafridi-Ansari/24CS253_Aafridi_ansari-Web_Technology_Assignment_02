// ============================================
// KPR StudentHub — Shared Application Utilities
// Web Technology Assignment 2 | U21CS501
// Simulates PHP/MySQL + Servlet/JDBC backend
// with localStorage for demo purposes
// ============================================

// ─────────────────────────────────────────
// SESSION MANAGEMENT
// Simulates PHP $_SESSION handling
// In real app: PHP session_start(), $_SESSION
// ─────────────────────────────────────────
const Session = {
  // Equivalent to: $_SESSION[$key] = $value;
  set(key, value) {
    localStorage.setItem(`session_${key}`, JSON.stringify(value));
  },
  // Equivalent to: $_SESSION[$key]
  get(key) {
    const val = localStorage.getItem(`session_${key}`);
    return val ? JSON.parse(val) : null;
  },
  // Equivalent to: unset($_SESSION[$key])
  remove(key) { localStorage.removeItem(`session_${key}`); },
  // Equivalent to: session_destroy()
  destroy() {
    const keys = Object.keys(localStorage).filter(k => k.startsWith('session_'));
    keys.forEach(k => localStorage.removeItem(k));
  },
  // Check: isset($_SESSION['user'])
  isLoggedIn() { return !!this.get('user'); },
  // Get current user object
  currentUser() { return this.get('user'); },
  // Redirect if not logged in — simulates session guard middleware
  requireLogin(redirectTo = 'index.html') {
    if (!this.isLoggedIn()) { window.location.href = redirectTo; return false; }
    return true;
  },
  // Admin role guard
  requireAdmin(redirectTo = 'index.html') {
    const user = this.currentUser();
    if (!user || user.role !== 'admin') { window.location.href = redirectTo; return false; }
    return true;
  }
};

// ─────────────────────────────────────────
// DATABASE (localStorage -> MySQL simulation)
// In real app: PHP PDO/MySQLi or JDBC Servlet
// ─────────────────────────────────────────
const DB = {
  /**
   * Initialize DB with seed data (first run)
   * Equivalent to running schema.sql + INSERT seeds
   */
  init() {
    if (!localStorage.getItem('db_initialized')) {
      // Users table seed
      const users = [
        { id: 1, username: 'admin',   password: 'Admin@123',   role: 'admin',   name: 'Administrator'  },
        { id: 2, username: 'student', password: 'Student@123', role: 'student', name: 'Student Viewer' }
      ];
      localStorage.setItem('db_users', JSON.stringify(users));

      // Students table seed with sample data
      const students = [
        {
          id: 1, name: 'Arjun Sharma', roll_number: '24CS001',
          email: 'arjun.sharma@kpriet.ac.in', course: 'B.E. Computer Science',
          year: 'III', section: 'A', phone: '9876543210',
          address: '12, Gandhi Nagar, Coimbatore - 641001',
          dob: '2003-05-12', gender: 'Male',
          profile_image: '', documents: [],
          created_at: '2024-06-01T10:00:00.000Z', status: 'active'
        },
        {
          id: 2, name: 'Priya Lakshmi', roll_number: '24CS002',
          email: 'priya.l@kpriet.ac.in', course: 'B.E. Computer Science',
          year: 'III', section: 'A', phone: '9876543211',
          address: '45, Rose Street, Tiruppur - 641604',
          dob: '2003-08-22', gender: 'Female',
          profile_image: '', documents: [],
          created_at: '2024-06-02T10:00:00.000Z', status: 'active'
        },
        {
          id: 3, name: 'Mohammed Aafridi', roll_number: '24CS003',
          email: 'aafridi@kpriet.ac.in', course: 'B.E. Computer Science',
          year: 'III', section: 'A', phone: '9876543212',
          address: '78, Nehru Road, Erode - 638001',
          dob: '2003-01-15', gender: 'Male',
          profile_image: '', documents: [],
          created_at: '2024-06-03T10:00:00.000Z', status: 'active'
        },
        {
          id: 4, name: 'Kavitha Devi', roll_number: '24CS004',
          email: 'kavitha.d@kpriet.ac.in', course: 'B.Tech Information Technology',
          year: 'II', section: 'B', phone: '9876543213',
          address: '3, Anna Salai, Salem - 636001',
          dob: '2004-03-30', gender: 'Female',
          profile_image: '', documents: [],
          created_at: '2024-06-04T10:00:00.000Z', status: 'active'
        },
        {
          id: 5, name: 'Ravi Kumar', roll_number: '24EC001',
          email: 'ravi.k@kpriet.ac.in', course: 'B.E. Electronics & Communication',
          year: 'IV', section: 'A', phone: '9876543214',
          address: '55, Market Road, Pollachi - 642001',
          dob: '2002-11-08', gender: 'Male',
          profile_image: '', documents: [],
          created_at: '2024-06-05T10:00:00.000Z', status: 'inactive'
        }
      ];
      localStorage.setItem('db_students', JSON.stringify(students));
      localStorage.setItem('db_next_id', '6');
      localStorage.setItem('db_initialized', 'true');
    }
  },

  // Users Table
  getUsers() {
    return JSON.parse(localStorage.getItem('db_users') || '[]');
  },
  // SELECT * FROM users WHERE username=? AND password=?
  findUser(username, password) {
    return this.getUsers().find(u => u.username === username && u.password === password) || null;
  },

  // Students Table
  getStudents() {
    return JSON.parse(localStorage.getItem('db_students') || '[]');
  },
  saveStudents(students) {
    localStorage.setItem('db_students', JSON.stringify(students));
  },
  getNextId() {
    const id = parseInt(localStorage.getItem('db_next_id') || '1');
    localStorage.setItem('db_next_id', String(id + 1));
    return id;
  },

  // SELECT * FROM students WHERE id=?
  getStudentById(id) {
    return this.getStudents().find(s => s.id === parseInt(id)) || null;
  },
  // SELECT * FROM students WHERE roll_number=?
  getStudentByRoll(roll) {
    return this.getStudents().find(s => s.roll_number === roll) || null;
  },
  // SELECT * FROM students WHERE email=?
  getStudentByEmail(email) {
    return this.getStudents().find(s => s.email === email) || null;
  },

  // INSERT INTO students (...) VALUES (...)
  addStudent(data) {
    const students = this.getStudents();
    const student = {
      ...data,
      id: this.getNextId(),
      documents: data.documents || [],
      created_at: new Date().toISOString(),
      status: 'active'
    };
    students.push(student);
    this.saveStudents(students);
    return student;
  },

  // UPDATE students SET ... WHERE id=?
  updateStudent(id, data) {
    const students = this.getStudents();
    const idx = students.findIndex(s => s.id === parseInt(id));
    if (idx === -1) return null;
    students[idx] = { ...students[idx], ...data, updated_at: new Date().toISOString() };
    this.saveStudents(students);
    return students[idx];
  },

  // DELETE FROM students WHERE id=?
  deleteStudent(id) {
    const students = this.getStudents();
    const idx = students.findIndex(s => s.id === parseInt(id));
    if (idx === -1) return false;
    students.splice(idx, 1);
    this.saveStudents(students);
    return true;
  },

  // SELECT * FROM students WHERE name LIKE ? OR roll_number LIKE ? ...
  searchStudents(query, filters) {
    filters = filters || {};
    let results = this.getStudents();
    if (query) {
      const q = query.toLowerCase();
      results = results.filter(s =>
        s.name.toLowerCase().includes(q) ||
        s.roll_number.toLowerCase().includes(q) ||
        s.email.toLowerCase().includes(q) ||
        s.course.toLowerCase().includes(q)
      );
    }
    if (filters.course && filters.course !== 'all') results = results.filter(s => s.course === filters.course);
    if (filters.year   && filters.year   !== 'all') results = results.filter(s => s.year === filters.year);
    if (filters.status && filters.status !== 'all') results = results.filter(s => s.status === filters.status);
    return results;
  },

  // INSERT INTO files (student_id, file_name, file_type, file_size, file_path, upload_date)
  addDocument(studentId, doc) {
    const student = this.getStudentById(studentId);
    if (!student) return false;
    const documents = student.documents || [];
    documents.push({
      id: Date.now(),
      file_name:   doc.file_name,
      file_type:   doc.file_type,
      file_size:   doc.file_size,
      file_path:   doc.data_url,   // In real app: server file path
      doc_type:    doc.doc_type,
      upload_date: new Date().toISOString()
    });
    return this.updateStudent(studentId, { documents });
  },

  // DELETE FROM files WHERE id=? AND student_id=?
  removeDocument(studentId, docId) {
    const student = this.getStudentById(studentId);
    if (!student) return false;
    const documents = (student.documents || []).filter(d => d.id !== docId);
    return this.updateStudent(studentId, { documents });
  },

  // Aggregate stats -- SELECT COUNT(*), SUM etc.
  getStats() {
    const students = this.getStudents();
    const courses = [...new Set(students.map(s => s.course))];
    const totalDocs = students.reduce((sum, s) => sum + (s.documents || []).length, 0);
    return {
      total:      students.length,
      active:     students.filter(s => s.status === 'active').length,
      inactive:   students.filter(s => s.status === 'inactive').length,
      courses:    courses.length,
      totalDocs,
      withPhotos: students.filter(s => s.profile_image).length
    };
  }
};

// ─────────────────────────────────────────
// TOAST NOTIFICATIONS
// ─────────────────────────────────────────
const Toast = {
  container: null,
  init() {
    if (!this.container) {
      this.container = document.createElement('div');
      this.container.className = 'toast-container';
      document.body.appendChild(this.container);
    }
  },
  show(message, type, duration) {
    type = type || 'info';
    duration = duration || 3500;
    this.init();
    const icons = { success: '✅', error: '❌', warning: '⚠️', info: 'ℹ️' };
    const toast = document.createElement('div');
    toast.className = 'toast ' + type;
    toast.innerHTML =
      '<span class="toast-icon">' + icons[type] + '</span>' +
      '<span class="toast-message">' + message + '</span>' +
      '<span class="toast-close" onclick="this.parentElement.remove()">✕</span>';
    this.container.appendChild(toast);
    requestAnimationFrame(() => toast.classList.add('show'));
    setTimeout(function() {
      toast.classList.remove('show');
      setTimeout(() => toast.remove(), 350);
    }, duration);
  },
  success(msg, dur) { this.show(msg, 'success', dur); },
  error(msg, dur)   { this.show(msg, 'error', dur); },
  warning(msg, dur) { this.show(msg, 'warning', dur); },
  info(msg, dur)    { this.show(msg, 'info', dur); }
};

// ─────────────────────────────────────────
// FORM VALIDATION UTILITIES
// Client-side validation (JavaScript) - Q1 requirement
// ─────────────────────────────────────────
const Validate = {
  required(val) { return val !== null && val !== undefined && String(val).trim().length > 0; },
  email(val)    { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val); },
  phone(val)    { return /^[6-9]\d{9}$/.test(String(val)); },
  rollNumber(val) { return /^\d{2}[A-Z]{2}\d{3}$/.test(val); },
  minLength(val, n) { return String(val).length >= n; },
  maxLength(val, n) { return String(val).length <= n; },

  // Password strength checker
  password(val) {
    if (!val) return { score: 0, strength: '', label: '' };
    var checks = [
      val.length >= 8,
      /[A-Z]/.test(val),
      /[a-z]/.test(val),
      /[0-9]/.test(val),
      /[^A-Za-z0-9]/.test(val)
    ];
    var score = checks.filter(Boolean).length;
    var labels  = ['', 'Weak', 'Fair', 'Good', 'Strong', 'Very Strong'];
    var classes = ['', 'weak', 'fair', 'good', 'strong', 'strong'];
    return { score: score, strength: classes[score], label: labels[score], checks: checks };
  },

  // File size validation — prevent large uploads
  fileSize(file, maxMB) {
    maxMB = maxMB || 5;
    return file.size <= maxMB * 1024 * 1024;
  },
  // File type validation — whitelist allowed types
  fileType(file, allowed) {
    allowed = allowed || ['image/jpeg','image/png','image/gif','image/webp','application/pdf'];
    return allowed.includes(file.type);
  },
  // Prevent overwriting existing file with same name
  fileNameExists(name, existingDocs) {
    return existingDocs.some(function(d) { return d.file_name === name; });
  }
};

// ─────────────────────────────────────────
// FILE UTILITIES
// Simulates PHP move_uploaded_file() and Servlet Part.write()
// ─────────────────────────────────────────
const FileUtils = {
  readAsDataURL(file) {
    return new Promise(function(resolve, reject) {
      var reader = new FileReader();
      reader.onload  = function(e) { resolve(e.target.result); };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  },
  formatSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  },
  getIcon(mimeType) {
    if (!mimeType) return '📎';
    if (mimeType.startsWith('image/')) return '🖼️';
    if (mimeType === 'application/pdf') return '📄';
    if (mimeType.includes('word')) return '📝';
    if (mimeType.includes('excel') || mimeType.includes('sheet')) return '📊';
    return '📎';
  },
  isImage(mimeType) { return mimeType && mimeType.startsWith('image/'); },
  getExt(name) { return name.split('.').pop().toUpperCase(); }
};

// ─────────────────────────────────────────
// UI UTILITIES
// ─────────────────────────────────────────
const UI = {
  show(el) {
    if (typeof el === 'string') el = document.querySelector(el);
    if (el) el.style.display = '';
  },
  hide(el) {
    if (typeof el === 'string') el = document.querySelector(el);
    if (el) el.style.display = 'none';
  },
  setError(fieldId, message) {
    var input = document.getElementById(fieldId);
    var err   = document.getElementById(fieldId + 'Err');
    if (input) { input.classList.add('error'); input.classList.remove('success'); }
    if (err)   { err.textContent = message; err.classList.add('show'); }
  },
  clearError(fieldId) {
    var input = document.getElementById(fieldId);
    var err   = document.getElementById(fieldId + 'Err');
    if (input) { input.classList.remove('error'); input.classList.add('success'); }
    if (err)   { err.classList.remove('show'); }
  },
  clearAllErrors(formEl) {
    formEl.querySelectorAll('.form-control').forEach(function(el) { el.classList.remove('error','success'); });
    formEl.querySelectorAll('.field-error').forEach(function(el) { el.classList.remove('show'); });
  },
  confirm(title, message, onConfirm, type) {
    type = type || 'warning';
    var icon = { warning: '⚠️', danger: '🗑️', info: 'ℹ️' }[type] || '⚠️';
    var overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML =
      '<div class="modal" style="max-width:420px">' +
        '<div class="modal-header">' +
          '<h3 class="modal-title">' + icon + ' ' + title + '</h3>' +
        '</div>' +
        '<p style="color:var(--text-secondary);margin-bottom:1.5rem;line-height:1.6">' + message + '</p>' +
        '<div class="modal-footer">' +
          '<button class="btn btn-secondary" id="cfCancel">Cancel</button>' +
          '<button class="btn btn-danger" id="cfConfirm">Confirm Delete</button>' +
        '</div>' +
      '</div>';
    document.body.appendChild(overlay);
    requestAnimationFrame(function() { overlay.classList.add('show'); });
    overlay.querySelector('#cfCancel').onclick  = function() { overlay.remove(); };
    overlay.querySelector('#cfConfirm').onclick = function() { overlay.remove(); onConfirm(); };
    overlay.addEventListener('click', function(e) { if (e.target === overlay) overlay.remove(); });
  },
  formatDate(dateStr, opts) {
    if (!dateStr) return '—';
    var date = new Date(dateStr);
    if (isNaN(date)) return dateStr;
    return date.toLocaleDateString('en-IN', Object.assign(
      { day:'2-digit', month:'short', year:'numeric' }, opts || {}
    ));
  },
  getInitials(name) {
    if (!name) return '??';
    return name.trim().split(/\s+/).map(function(n) { return n[0]; }).join('').toUpperCase().slice(0, 2);
  },
  truncate(str, n) {
    n = n || 30;
    return str && str.length > n ? str.slice(0, n) + '\u2026' : (str || '');
  }
};

// ─────────────────────────────────────────
// NAVBAR INIT
// ─────────────────────────────────────────
function initNavbar() {
  var user      = Session.currentUser();
  var navUserEl = document.getElementById('navUser');
  if (navUserEl && user) {
    navUserEl.innerHTML =
      '<div class="avatar">' + UI.getInitials(user.name) + '</div>' +
      '<span>' + user.name + '</span>' +
      '<span style="font-size:0.7rem;color:var(--text-muted);margin-left:2px">(' + user.role + ')</span>';
    navUserEl.title = 'Click to logout';
    navUserEl.addEventListener('click', function() {
      UI.confirm('Logout', 'Are you sure you want to log out, ' + user.name + '?', function() {
        Session.destroy();
        window.location.href = 'index.html';
      });
    });
  }
  document.querySelectorAll('.nav-links a').forEach(function(a) {
    if (a.href === window.location.href) a.classList.add('active');
  });
}

window.addEventListener('scroll', function() {
  var nav = document.querySelector('.navbar');
  if (nav) nav.classList.toggle('scrolled', window.scrollY > 10);
}, { passive: true });

document.addEventListener('DOMContentLoaded', function() {
  DB.init();
  initNavbar();
});
