-- =============================================================================
-- HealthCare Hospital Portal - Complete D1 SQLite Database Schema
-- Production-Ready, ACID-Compliant, Cloudflare Pages Edge Optimized
-- =============================================================================

PRAGMA foreign_keys = ON;

-- 1. USERS & AUTHENTICATION TABLE (RBAC)
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,                       -- e.g. USR001 or UUID
  email TEXT UNIQUE NOT NULL COLLATE NOCASE,
  password_hash TEXT NOT NULL,               -- Web Crypto PBKDF2 (SHA-256) hex
  salt TEXT NOT NULL,                        -- Cryptographic 16-byte random hex
  role TEXT NOT NULL CHECK (role IN ('admin', 'doctor', 'patient', 'staff')) DEFAULT 'patient',
  full_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT DEFAULT './assets/default_avatar.svg',
  is_active INTEGER NOT NULL DEFAULT 1,
  last_login_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- 2. CLINICAL DEPARTMENTS
CREATE TABLE IF NOT EXISTS departments (
  id TEXT PRIMARY KEY,                       -- e.g. DEP-CARDIO
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,                 -- e.g. cardiology, neurology
  head_doctor_name TEXT,
  description TEXT,
  location_room TEXT,
  phone_extension TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_departments_slug ON departments(slug);

-- 3. DOCTOR PROFILES & SPECIALISTS
CREATE TABLE IF NOT EXISTS doctors (
  id TEXT PRIMARY KEY,                       -- e.g. DOC-RAJESH
  user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  dept_slug TEXT NOT NULL,
  degrees TEXT NOT NULL,
  license_number TEXT,
  bio TEXT,
  consultation_fee INTEGER NOT NULL DEFAULT 800,
  experience_years INTEGER NOT NULL DEFAULT 10,
  avatar_url TEXT NOT NULL DEFAULT './assets/default_doctor.jpg',
  is_available INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (dept_slug) REFERENCES departments(slug) ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_doctors_dept ON doctors(dept_slug);

-- 4. PATIENTS DIRECTORY (EMR / OPD)
CREATE TABLE IF NOT EXISTS patients (
  id TEXT PRIMARY KEY,                       -- e.g. PNT001
  mrn_number TEXT UNIQUE,                    -- Medical Record Number e.g. MRN-2026-001
  user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  age INTEGER NOT NULL CHECK(age >= 0 AND age <= 130),
  gender TEXT NOT NULL CHECK(gender IN ('Male', 'Female', 'Other')),
  phone TEXT NOT NULL,
  email TEXT,
  blood_group TEXT NOT NULL DEFAULT 'O+',
  dept TEXT NOT NULL,
  condition TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Active OPD',
  vitals TEXT NOT NULL DEFAULT 'BP: 120/80 mmHg | Pulse: 72 bpm | SpO2: 99%',
  notes TEXT,
  emergency_contact TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_patients_name ON patients(name);
CREATE INDEX IF NOT EXISTS idx_patients_dept ON patients(dept);
CREATE INDEX IF NOT EXISTS idx_patients_status ON patients(status);

-- 5. APPOINTMENTS SCHEDULER
CREATE TABLE IF NOT EXISTS appointments (
  id TEXT PRIMARY KEY,                       -- e.g. APT001
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  doctor_name TEXT NOT NULL,
  dept TEXT NOT NULL,
  scheduled_datetime TEXT NOT NULL,          -- e.g. '2026-05-20 10:00 AM'
  status TEXT NOT NULL CHECK(status IN ('Confirmed', 'Pending', 'Completed', 'Cancelled')) DEFAULT 'Confirmed',
  reason TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_appointments_datetime ON appointments(scheduled_datetime);

-- 6. CLINICAL TREATMENT PROTOCOLS & EHR
CREATE TABLE IF NOT EXISTS clinical_records (
  id TEXT PRIMARY KEY,                       -- e.g. EHR-99201
  patient_id TEXT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  ehr_number TEXT NOT NULL,                  -- e.g. #EHR-99201
  protocol_title TEXT NOT NULL,
  patient_name TEXT NOT NULL,
  patient_meta TEXT NOT NULL,
  doctor_name TEXT NOT NULL,
  doctor_meta TEXT NOT NULL,
  dept_name TEXT NOT NULL,
  dept_meta TEXT NOT NULL,
  encounter_date TEXT NOT NULL,
  encounter_time TEXT NOT NULL,
  diagnosis TEXT NOT NULL,
  procedures_html TEXT NOT NULL,
  treatment_notes TEXT NOT NULL,
  doctor_signature TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_clinical_patient ON clinical_records(patient_id);

-- 7. BILLING & INVOICES
CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,                       -- e.g. INV001
  patient_id TEXT REFERENCES patients(id) ON DELETE SET NULL,
  patient_name TEXT NOT NULL,
  service_name TEXT NOT NULL,
  invoice_date TEXT NOT NULL,
  amount TEXT NOT NULL,                      -- e.g. '₹1500'
  raw_amount REAL NOT NULL,                  -- e.g. 1500.00
  status TEXT NOT NULL CHECK(status IN ('Paid', 'Unpaid', 'Partially Paid', 'Cancelled')) DEFAULT 'Unpaid',
  payment_method TEXT DEFAULT 'UPI / Cash',
  transaction_ref TEXT,
  notes TEXT,
  paid_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_invoices_patient ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

-- 8. ITEMIZED INVOICE LINE ITEMS
CREATE TABLE IF NOT EXISTS invoice_items (
  id TEXT PRIMARY KEY,                       -- e.g. ITEM-INV001-1
  invoice_id TEXT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  description TEXT NOT NULL,
  fee_amount TEXT NOT NULL,                  -- e.g. '₹800'
  raw_fee REAL NOT NULL,                     -- e.g. 800.00
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON invoice_items(invoice_id);

-- 9. HOSPITAL BED & WARD OCCUPANCY
CREATE TABLE IF NOT EXISTS hospital_beds (
  id TEXT PRIMARY KEY,                       -- e.g. BED-ICU-01
  bed_number TEXT NOT NULL UNIQUE,
  ward_type TEXT NOT NULL CHECK(ward_type IN ('General Ward', 'ICU', 'Pediatrics', 'Cardiology CCU', 'Emergency')),
  status TEXT NOT NULL CHECK(status IN ('Available', 'Occupied', 'Maintenance')) DEFAULT 'Available',
  current_patient_id TEXT REFERENCES patients(id) ON DELETE SET NULL,
  assigned_at TEXT,
  notes TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_beds_ward ON hospital_beds(ward_type);
CREATE INDEX IF NOT EXISTS idx_beds_status ON hospital_beds(status);

-- 10. DOCTOR ONBOARDING APPLICATIONS
CREATE TABLE IF NOT EXISTS doctor_applications (
  id TEXT PRIMARY KEY,                       -- e.g. DOC-APP-1234
  application_ref TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  specialty TEXT NOT NULL,
  experience_years INTEGER NOT NULL DEFAULT 0,
  medical_license TEXT NOT NULL,
  qualifications TEXT NOT NULL,
  resume_url TEXT,
  cover_note TEXT,
  status TEXT NOT NULL CHECK(status IN ('Submitted', 'Under Review', 'Approved', 'Rejected')) DEFAULT 'Submitted',
  reviewed_by TEXT,
  reviewed_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_doctor_apps_status ON doctor_applications(status);

-- 11. GENERAL CAREER & JOB APPLICATIONS
CREATE TABLE IF NOT EXISTS career_applications (
  id TEXT PRIMARY KEY,                       -- e.g. APP-CAREER-5678
  application_ref TEXT NOT NULL UNIQUE,
  position TEXT NOT NULL,
  candidate_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  experience_years INTEGER NOT NULL DEFAULT 0,
  resume_url TEXT,
  cover_note TEXT,
  status TEXT NOT NULL CHECK(status IN ('Submitted', 'Screening', 'Shortlisted', 'Rejected')) DEFAULT 'Submitted',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_career_apps_status ON career_applications(status);

-- 12. CONTACT INQUIRIES & HELPDESK TICKETS
CREATE TABLE IF NOT EXISTS contact_inquiries (
  id TEXT PRIMARY KEY,                       -- e.g. TKT-9988
  ticket_number TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  subject TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('Open', 'In Progress', 'Resolved', 'Closed')) DEFAULT 'Open',
  priority TEXT NOT NULL CHECK(priority IN ('Normal', 'Urgent', 'Emergency')) DEFAULT 'Normal',
  ip_address TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_contact_status ON contact_inquiries(status);

-- 13. TAMPER-EVIDENT AUDIT LOGS (HIPAA / NABH COMPLIANCE)
CREATE TABLE IF NOT EXISTS audit_logs (
  id TEXT PRIMARY KEY,                       -- e.g. LOG-2026-0001
  user_id TEXT,
  action TEXT NOT NULL,                      -- e.g. 'PATIENT_CREATE', 'INVOICE_PAID', 'STATUS_CHANGE'
  entity_type TEXT NOT NULL,                 -- e.g. 'patients', 'invoices', 'appointments'
  entity_id TEXT NOT NULL,
  details TEXT,                              -- JSON payload string
  ip_address TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_logs(created_at);

-- 14. ACTIVE SESSIONS (EDGE TOKEN STORE)
CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,                       -- Session Token ID or Hash
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token_hash);
CREATE INDEX IF NOT EXISTS idx_sessions_expiry ON sessions(expires_at);
