-- =============================================================================
-- HealthCare Hospital Portal - PostgreSQL / Supabase Compatible Schema
-- Enterprise-grade, Full Relational Constraints, UUID Generation & Indexes
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS & AUTHENTICATION TABLE (RBAC)
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(64) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  salt VARCHAR(64) NOT NULL,
  role VARCHAR(32) NOT NULL CHECK (role IN ('admin', 'doctor', 'patient', 'staff')) DEFAULT 'patient',
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(50),
  avatar_url VARCHAR(500) DEFAULT './assets/default_avatar.svg',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_pg_users_role ON users(role);

-- 2. CLINICAL DEPARTMENTS
CREATE TABLE IF NOT EXISTS departments (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(64) UNIQUE NOT NULL,
  head_doctor_name VARCHAR(150),
  description TEXT,
  location_room VARCHAR(100),
  phone_extension VARCHAR(20),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_dept_slug ON departments(slug);

-- 3. DOCTOR PROFILES & SPECIALISTS
CREATE TABLE IF NOT EXISTS doctors (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) REFERENCES users(id) ON DELETE SET NULL,
  name VARCHAR(150) NOT NULL,
  dept_slug VARCHAR(64) NOT NULL REFERENCES departments(slug) ON UPDATE CASCADE,
  degrees VARCHAR(255) NOT NULL,
  license_number VARCHAR(100),
  bio TEXT,
  consultation_fee INT NOT NULL DEFAULT 800,
  experience_years INT NOT NULL DEFAULT 10,
  avatar_url VARCHAR(500) NOT NULL DEFAULT './assets/default_doctor.jpg',
  is_available BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_doctors_dept ON doctors(dept_slug);

-- 4. PATIENTS DIRECTORY (EMR / OPD)
CREATE TABLE IF NOT EXISTS patients (
  id VARCHAR(64) PRIMARY KEY,
  mrn_number VARCHAR(64) UNIQUE,
  user_id VARCHAR(64) REFERENCES users(id) ON DELETE SET NULL,
  name VARCHAR(150) NOT NULL,
  age INT NOT NULL CHECK(age >= 0 AND age <= 130),
  gender VARCHAR(20) NOT NULL CHECK(gender IN ('Male', 'Female', 'Other')),
  phone VARCHAR(50) NOT NULL,
  email VARCHAR(255),
  blood_group VARCHAR(10) NOT NULL DEFAULT 'O+',
  dept VARCHAR(100) NOT NULL,
  condition TEXT NOT NULL,
  status VARCHAR(50) NOT NULL DEFAULT 'Active OPD',
  vitals TEXT NOT NULL DEFAULT 'BP: 120/80 mmHg | Pulse: 72 bpm | SpO2: 99%',
  notes TEXT,
  emergency_contact VARCHAR(255),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_patients_name ON patients(name);
CREATE INDEX IF NOT EXISTS idx_pg_patients_dept ON patients(dept);

-- 5. APPOINTMENTS SCHEDULER
CREATE TABLE IF NOT EXISTS appointments (
  id VARCHAR(64) PRIMARY KEY,
  patient_id VARCHAR(64) REFERENCES patients(id) ON DELETE CASCADE,
  patient_name VARCHAR(150) NOT NULL,
  doctor_name VARCHAR(150) NOT NULL,
  dept VARCHAR(100) NOT NULL,
  scheduled_datetime VARCHAR(100) NOT NULL,
  status VARCHAR(32) NOT NULL CHECK(status IN ('Confirmed', 'Pending', 'Completed', 'Cancelled')) DEFAULT 'Confirmed',
  reason TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_appt_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_pg_appt_status ON appointments(status);

-- 6. CLINICAL TREATMENT PROTOCOLS & EHR
CREATE TABLE IF NOT EXISTS clinical_records (
  id VARCHAR(64) PRIMARY KEY,
  patient_id VARCHAR(64) NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  ehr_number VARCHAR(64) NOT NULL,
  protocol_title VARCHAR(255) NOT NULL,
  patient_name VARCHAR(150) NOT NULL,
  patient_meta VARCHAR(150) NOT NULL,
  doctor_name VARCHAR(150) NOT NULL,
  doctor_meta VARCHAR(150) NOT NULL,
  dept_name VARCHAR(100) NOT NULL,
  dept_meta VARCHAR(100) NOT NULL,
  encounter_date VARCHAR(50) NOT NULL,
  encounter_time VARCHAR(50) NOT NULL,
  diagnosis TEXT NOT NULL,
  procedures_html TEXT NOT NULL,
  treatment_notes TEXT NOT NULL,
  doctor_signature VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_clinical_patient ON clinical_records(patient_id);

-- 7. BILLING & INVOICES
CREATE TABLE IF NOT EXISTS invoices (
  id VARCHAR(64) PRIMARY KEY,
  patient_id VARCHAR(64) REFERENCES patients(id) ON DELETE SET NULL,
  patient_name VARCHAR(150) NOT NULL,
  service_name VARCHAR(255) NOT NULL,
  invoice_date VARCHAR(50) NOT NULL,
  amount VARCHAR(50) NOT NULL,
  raw_amount NUMERIC(10,2) NOT NULL,
  status VARCHAR(32) NOT NULL CHECK(status IN ('Paid', 'Unpaid', 'Partially Paid', 'Cancelled')) DEFAULT 'Unpaid',
  payment_method VARCHAR(100) DEFAULT 'UPI / Cash',
  transaction_ref VARCHAR(100),
  notes TEXT,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pg_invoices_patient ON invoices(patient_id);
CREATE INDEX IF NOT EXISTS idx_pg_invoices_status ON invoices(status);

-- 8. ITEMIZED INVOICE LINE ITEMS
CREATE TABLE IF NOT EXISTS invoice_items (
  id VARCHAR(64) PRIMARY KEY,
  invoice_id VARCHAR(64) NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  description VARCHAR(255) NOT NULL,
  fee_amount VARCHAR(50) NOT NULL,
  raw_fee NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 9. HOSPITAL BED & WARD OCCUPANCY
CREATE TABLE IF NOT EXISTS hospital_beds (
  id VARCHAR(64) PRIMARY KEY,
  bed_number VARCHAR(50) NOT NULL UNIQUE,
  ward_type VARCHAR(50) NOT NULL CHECK(ward_type IN ('General Ward', 'ICU', 'Pediatrics', 'Cardiology CCU', 'Emergency')),
  status VARCHAR(32) NOT NULL CHECK(status IN ('Available', 'Occupied', 'Maintenance')) DEFAULT 'Available',
  current_patient_id VARCHAR(64) REFERENCES patients(id) ON DELETE SET NULL,
  assigned_at TIMESTAMPTZ,
  notes TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 10. DOCTOR ONBOARDING APPLICATIONS
CREATE TABLE IF NOT EXISTS doctor_applications (
  id VARCHAR(64) PRIMARY KEY,
  application_ref VARCHAR(64) NOT NULL UNIQUE,
  full_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  specialty VARCHAR(100) NOT NULL,
  experience_years INT NOT NULL DEFAULT 0,
  medical_license VARCHAR(100) NOT NULL,
  qualifications TEXT NOT NULL,
  resume_url TEXT,
  cover_note TEXT,
  status VARCHAR(32) NOT NULL CHECK(status IN ('Submitted', 'Under Review', 'Approved', 'Rejected')) DEFAULT 'Submitted',
  reviewed_by VARCHAR(64),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 11. GENERAL CAREER & JOB APPLICATIONS
CREATE TABLE IF NOT EXISTS career_applications (
  id VARCHAR(64) PRIMARY KEY,
  application_ref VARCHAR(64) NOT NULL UNIQUE,
  position VARCHAR(100) NOT NULL,
  candidate_name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  experience_years INT NOT NULL DEFAULT 0,
  resume_url TEXT,
  cover_note TEXT,
  status VARCHAR(32) NOT NULL CHECK(status IN ('Submitted', 'Screening', 'Shortlisted', 'Rejected')) DEFAULT 'Submitted',
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 12. CONTACT INQUIRIES & HELPDESK TICKETS
CREATE TABLE IF NOT EXISTS contact_inquiries (
  id VARCHAR(64) PRIMARY KEY,
  ticket_number VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(32) NOT NULL CHECK(status IN ('Open', 'In Progress', 'Resolved', 'Closed')) DEFAULT 'Open',
  priority VARCHAR(32) NOT NULL CHECK(priority IN ('Normal', 'Urgent', 'Emergency')) DEFAULT 'Normal',
  ip_address VARCHAR(45),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 13. TAMPER-EVIDENT AUDIT LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
  id VARCHAR(64) PRIMARY KEY DEFAULT uuid_generate_v4()::text,
  user_id VARCHAR(64),
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(64) NOT NULL,
  entity_id VARCHAR(64) NOT NULL,
  details JSONB,
  ip_address VARCHAR(45),
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 14. ACTIVE SESSIONS
CREATE TABLE IF NOT EXISTS sessions (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
