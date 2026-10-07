/**
 * KPR StudentHub — Core Application Logic & Data Synchronization
 * Web Technology Assignment 2 | U21CS501
 * Author: Aafridi Ansari (Roll No: 24CS253)
 */

// Initial Seed Data Initialization
function initDatabaseSeed() {
  if (!localStorage.getItem('kpr_students') || JSON.parse(localStorage.getItem('kpr_students') || '[]').length === 0) {
    const seedStudents = [
      {
        roll_number: '24CS253',
        name: 'Aafridi Ansari',
        email: 'aafridi.ansari@kpriet.ac.in',
        phone: '9876543210',
        gender: 'Male',
        dob: '2004-05-15',
        department: 'Computer Science and Engineering',
        year_of_study: '3rd Year',
        course: 'B.E. Computer Science & Engineering',
        address: '45 Green Valley Avenue, Coimbatore - 641407',
        profile_image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        total_fee: 175000,
        fee_status: 'Paid',
        attendance_pct: 92.5,
        cgpa: 8.85,
        uploaded_doc: 'Aadhaar_ID_Proof.pdf',
        created_at: '2026-10-08T00:00:00.000Z'
      },
      {
        roll_number: '24CS001',
        name: 'Priya Sharma',
        email: 'priya.sharma@kpriet.ac.in',
        phone: '9123456780',
        gender: 'Female',
        dob: '2004-08-20',
        department: 'Computer Science and Engineering',
        year_of_study: '3rd Year',
        course: 'B.E. Computer Science & Engineering',
        address: '12 Rose Gardens, Coimbatore',
        profile_image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        total_fee: 145000,
        fee_status: 'Paid',
        attendance_pct: 94.0,
        cgpa: 9.12,
        uploaded_doc: 'HSC_Marksheet.pdf',
        created_at: '2026-10-07T00:00:00.000Z'
      },
      {
        roll_number: '24AI012',
        name: 'Rahul Verma',
        email: 'rahul.verma@kpriet.ac.in',
        phone: '9988776655',
        gender: 'Male',
        dob: '2003-11-10',
        department: 'Artificial Intelligence and Data Science',
        year_of_study: '4th Year',
        course: 'B.Tech AI & Data Science',
        address: '88 Tech Park Road, Coimbatore',
        profile_image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        total_fee: 155000,
        fee_status: 'Paid',
        attendance_pct: 90.0,
        cgpa: 8.65,
        uploaded_doc: 'Community_Certificate.pdf',
        created_at: '2026-10-06T00:00:00.000Z'
      }
    ];
    localStorage.setItem('kpr_students', JSON.stringify(seedStudents));
  }
}

function resetDemoData() {
  localStorage.removeItem('kpr_students');
  initDatabaseSeed();
  if (typeof renderAdminDashboard === 'function') {
    renderAdminDashboard();
  }
  alert('Demo student database has been successfully reset.');
}

// Run Seed Initialization
initDatabaseSeed();
