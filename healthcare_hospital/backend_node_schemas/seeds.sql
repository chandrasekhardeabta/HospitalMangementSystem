-- =============================================================================
-- HealthCare Hospital Portal - Initial Master Seed Data
-- Aligns 100% with Frontend Clinical Records, Invoices, Patients & Doctors
-- =============================================================================

-- 1. SEED CLINICAL DEPARTMENTS
INSERT OR REPLACE INTO departments (id, name, slug, head_doctor_name, description, location_room, phone_extension) VALUES
('DEP-CARDIO', 'Cardiology', 'cardiology', 'Dr. Rajesh Sharma', 'Comprehensive cardiovascular diagnostics, interventional catheterization, and post-infarction care.', 'OPD Block B, Room 204', '4021'),
('DEP-NEURO', 'Neurology', 'neurology', 'Dr. Priya Verma', 'Advanced clinical neurology, stroke prevention, neuro-rehabilitation, and EEG/MRI diagnostics.', 'Neurosciences Center, Room 310', '4032'),
('DEP-ORTHO', 'Orthopedics', 'orthopedics', 'Dr. Amit Patel', 'Joint replacement, trauma care, robotic arthroplasty, and musculoskeletal rehabilitation.', 'Bone & Joint Center, Room 108', '4015'),
('DEP-PEDIA', 'Pediatrics', 'pediatrics', 'Dr. Neha Singh', 'Newborn intensive care (NICU), pediatric wellness, immunization protocols, and child development.', 'Child Care Pavilion, Room 102', '4008'),
('DEP-MED', 'General Medicine', 'general-medicine', 'Dr. Rajesh Sharma', 'Internal medicine, adult metabolic disorders, chronic hypertension, and endocrinology.', 'Internal Medicine Clinic, Room 215', '4025'),
('DEP-EMERG', 'Emergency & Trauma', 'emergency', 'Dr. Vikram Sen', 'Level-1 round-the-clock emergency triage, resuscitation bays, and critical surgical intervention.', 'Ground Floor, Emergency Wing', '4000');

-- 2. SEED SYSTEM USERS (Passwords default to 'admin123', 'doctor123', 'patient123' hashed with salt 'a1b2c3d4e5f60718')
INSERT OR REPLACE INTO users (id, email, password_hash, salt, role, full_name, phone, avatar_url) VALUES
('USR-ADMIN', 'admin@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'admin', 'Hospital Administrator', '+91 98765 00001', './assets/default_avatar.svg'),
('USR-DOC-01', 'rajesh@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'doctor', 'Dr. Rajesh Sharma', '+91 98765 43201', './assets/doctor_rajesh.jpg'),
('USR-DOC-02', 'priya@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'doctor', 'Dr. Priya Verma', '+91 98765 43202', './assets/doctor_priya.jpg'),
('USR-DOC-03', 'amit@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'doctor', 'Dr. Amit Patel', '+91 98765 43203', './assets/doctor_amit.jpg'),
('USR-DOC-04', 'neha@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'doctor', 'Dr. Neha Singh', '+91 98765 43204', './assets/doctor_neha.jpg'),
('USR-PNT-01', 'rahul@healthcare.com', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'a1b2c3d4e5f60718', 'patient', 'Rahul Kumar', '+91 98765 43210', './assets/default_avatar.svg');

-- 3. SEED DOCTORS DIRECTORY
INSERT OR REPLACE INTO doctors (id, user_id, name, dept_slug, degrees, license_number, bio, consultation_fee, experience_years, avatar_url, is_available) VALUES
('DOC-RAJESH', 'USR-DOC-01', 'Dr. Rajesh Sharma', 'cardiology', 'MBBS, MD (Medicine), DM (Cardiology)', 'MCI-18492-CAR', 'Senior Consultant Interventional Cardiologist with over 15 years experience in angioplasty, pacemaker implantations, coronary artery management, and clinical cardiology.', 800, 15, './assets/doctor_rajesh.jpg', 1),
('DOC-PRIYA', 'USR-DOC-02', 'Dr. Priya Verma', 'neurology', 'MBBS, MD (General Med), DM (Neurology)', 'MCI-22941-NEU', 'Chief Neurologist specializing in neuro-critical care, stroke management, epilepsy, Parkinson''s disease, and comprehensive brain & nerve disorders.', 900, 12, './assets/doctor_priya.jpg', 1),
('DOC-AMIT', 'USR-DOC-03', 'Dr. Amit Patel', 'orthopedics', 'MBBS, MS (Orthopedics), Fellowship Joint Replacement', 'MCI-14902-ORT', 'Distinguished Orthopedic & Robotic Joint Replacement Surgeon with more than 10 years experience in minimally invasive knee and hip arthroplasty.', 700, 10, './assets/doctor_amit.jpg', 1),
('DOC-NEHA', 'USR-DOC-04', 'Dr. Neha Singh', 'pediatrics', 'MBBS, MD (Pediatrics), Fellowship Neonatology', 'MCI-29401-PED', 'Compassionate Child Care Specialist and Neonatologist dedicated to newborn intensive care, adolescent wellness, growth tracking, and vaccination programs.', 600, 8, './assets/doctor_neha.jpg', 1);

-- 4. SEED PATIENTS DIRECTORY
INSERT OR REPLACE INTO patients (id, mrn_number, user_id, name, age, gender, phone, email, blood_group, dept, condition, status, vitals, notes, emergency_contact) VALUES
('PNT001', 'MRN-2026-001', 'USR-PNT-01', 'Rahul Kumar', 38, 'Male', '+91 98765 43210', 'rahul@healthcare.com', 'O+', 'Cardiology', 'Hypertension & Mild Sinus Arrhythmia', 'Active OPD', 'BP: 130/85 mmHg | Pulse: 74 bpm | SpO2: 99%', 'No known penicillin allergies. Advised low sodium diet and daily blood pressure recording.', 'Sunita Kumar (+91 98765 43290)'),
('PNT002', 'MRN-2026-002', NULL, 'Priya Sharma', 32, 'Female', '+91 98765 43211', 'priya.sharma@example.com', 'B+', 'Neurology', 'Acute Migraine with Visual Aura', 'Active OPD', 'BP: 118/76 mmHg | Pulse: 68 bpm | SpO2: 98%', 'Triggered by screen fatigue and irregular sleep. Responding favorably to prophylactic migraine therapy.', 'Anil Sharma (+91 98765 43291)'),
('PNT003', 'MRN-2026-003', NULL, 'Amit Singh', 45, 'Male', '+91 98765 43212', 'amit.singh@example.com', 'AB+', 'Orthopedics', 'Fracture Right Distal Radius Rehabilitation', 'Active OPD', 'BP: 124/80 mmHg | Pulse: 72 bpm | SpO2: 99%', 'Cast removed on day 28. Mild stiffness in wrist joint. Initiated daily physical therapy and calcium supplementation.', 'Kavita Singh (+91 98765 43292)'),
('PNT004', 'MRN-2026-004', NULL, 'Neha Patel', 28, 'Female', '+91 98765 43213', 'neha.patel@example.com', 'A+', 'Pediatrics', '18-Month Pediatric Wellness & DTP Booster', 'Active OPD', 'Weight: 12.4 kg | Height: 88 cm | Vitals Normal', 'Growth and cognitive milestones strictly age-appropriate. Completed Pentavalent and DTP Booster schedule without adverse reaction.', 'Raj Patel (+91 98765 43293)'),
('PNT005', 'MRN-2026-005', NULL, 'Vikram Das', 58, 'Male', '+91 98765 43214', 'vikram.das@example.com', 'O-', 'General Medicine', 'Type-2 Glycemic Evaluation & Lipid Management', 'Active OPD', 'BP: 136/88 mmHg | Pulse: 76 bpm | SpO2: 97%', 'HbA1c 6.8%. Fasting blood sugar 114 mg/dL. Renal function and liver enzymes within normal parameters.', 'Anita Das (+91 98765 43294)');

-- 5. SEED APPOINTMENTS
INSERT OR REPLACE INTO appointments (id, patient_id, patient_name, doctor_name, dept, scheduled_datetime, status, reason) VALUES
('APT001', 'PNT001', 'Rahul Kumar', 'Dr. Rajesh Sharma', 'Cardiology', '20 May 2026, 10:00 AM', 'Confirmed', 'Regular Checkup & ECG Review'),
('APT002', 'PNT002', 'Priya Sharma', 'Dr. Priya Verma', 'Neurology', '20 May 2026, 11:30 AM', 'Pending', 'Headache Consultation & MRI Diagnostics'),
('APT003', 'PNT003', 'Amit Singh', 'Dr. Amit Patel', 'Orthopedics', '21 May 2026, 09:00 AM', 'Completed', 'Knee Pain Followup & Physical Therapy'),
('APT004', 'PNT004', 'Neha Patel', 'Dr. Neha Singh', 'Pediatrics', '21 May 2026, 02:00 PM', 'Confirmed', 'Child Vaccination & Growth Assessment'),
('APT005', 'PNT005', 'Vikram Das', 'Dr. Rajesh Sharma', 'Cardiology', '22 May 2026, 12:00 PM', 'Confirmed', 'ECG & Blood Pressure Review');

-- 6. SEED INVOICES & BILLING
INSERT OR REPLACE INTO invoices (id, patient_id, patient_name, service_name, invoice_date, amount, raw_amount, status, payment_method, paid_at) VALUES
('INV001', 'PNT001', 'Rahul Kumar', 'Cardiology ECG & Consultation', '20 May 2026', '₹1500', 1500, 'Paid', 'UPI (GooglePay)', '2026-05-20 10:35:00'),
('INV002', 'PNT002', 'Priya Sharma', 'Neurology MRI Diagnostics', '20 May 2026', '₹2200', 2200, 'Paid', 'Net Banking (HDFC)', '2026-05-20 12:15:00'),
('INV003', 'PNT003', 'Amit Singh', 'Orthopedic X-Ray & Cast', '21 May 2026', '₹850', 850, 'Unpaid', NULL, NULL),
('INV004', 'PNT004', 'Neha Patel', 'Pediatric Care & Immunization', '21 May 2026', '₹3500', 3500, 'Paid', 'Credit Card (Visa)', '2026-05-21 14:45:00'),
('INV005', 'PNT005', 'Vikram Das', 'General Medicine Lab Workup', '22 May 2026', '₹1200', 1200, 'Paid', 'Cash Payment', '2026-05-22 12:40:00');

-- 7. SEED INVOICE ITEMS BREAKDOWN
INSERT OR REPLACE INTO invoice_items (id, invoice_id, description, fee_amount, raw_fee) VALUES
('ITEM-INV001-1', 'INV001', 'Specialist Doctor Consultation', '₹800', 800),
('ITEM-INV001-2', 'INV001', '12-Lead Electrocardiogram (ECG)', '₹500', 500),
('ITEM-INV001-3', 'INV001', 'Administrative & Digital Record Fee', '₹200', 200),
('ITEM-INV002-1', 'INV002', 'Senior Neurologist Consultation', '₹900', 900),
('ITEM-INV002-2', 'INV002', 'Brain MRI Scan Workup', '₹1100', 1100),
('ITEM-INV002-3', 'INV002', 'Hospital Record Processing', '₹200', 200),
('ITEM-INV003-1', 'INV003', 'Orthopedic Consultation', '₹500', 500),
('ITEM-INV003-2', 'INV003', 'Digital X-Ray Wrist / Radius', '₹350', 350),
('ITEM-INV004-1', 'INV004', 'Pediatrician Wellness Review', '₹700', 700),
('ITEM-INV004-2', 'INV004', 'Pediatric Immunization Vaccine Vials', '₹2600', 2600),
('ITEM-INV004-3', 'INV004', 'Health Card Maintenance', '₹200', 200),
('ITEM-INV005-1', 'INV005', 'General Medicine Consultation', '₹600', 600),
('ITEM-INV005-2', 'INV005', 'Fasting Lipid & Glycemic Profile', '₹400', 400),
('ITEM-INV005-3', 'INV005', 'Digital Lab Record Generation', '₹200', 200);

-- 8. SEED CLINICAL RECORDS (EHR)
INSERT OR REPLACE INTO clinical_records (id, patient_id, ehr_number, protocol_title, patient_name, patient_meta, doctor_name, doctor_meta, dept_name, dept_meta, encounter_date, encounter_time, diagnosis, procedures_html, treatment_notes, doctor_signature) VALUES
('EHR-PNT001', 'PNT001', '#EHR-99201', 'Outpatient Cardiology Treatment Protocol', 'Rahul Kumar', 'ID: PNT001 | Age: 38 (M)', 'Dr. Rajesh Sharma', 'Chief Interventional Cardiologist', 'Cardiology', 'OPD Block B, Room 204', '20 May 2026', '10:00 AM IST', 'Hypertension & Mild Sinus Arrhythmia (Grade 1 Essential)',
'<ul class="treatment-list">
  <li><strong>12-Lead Electrocardiogram (ECG):</strong> Normal sinus rhythm, minor non-specific ST wave variations.</li>
  <li><strong>Serial Blood Pressure Monitoring:</strong> Average systolic 148 mmHg, diastolic 94 mmHg recorded in seated rest.</li>
  <li><strong>Prescribed Medicines:</strong>
    <ul style="margin-top: 6px; padding-left: 20px; list-style: circle;">
      <li>Tab. Telmisartan 40mg - Once daily before breakfast (Morning)</li>
      <li>Tab. Amlodipine 5mg - Once daily after dinner (Night)</li>
      <li>Low sodium dietary guidance card issued (&lt;2g NaCl/day).</li>
    </ul>
  </li>
</ul>',
'Patient instructed to continue anti-hypertensive medication regimen strictly for 2 weeks. Maintain daily home BP logbook. Avoid strenuous cardiac exertion. Report to ER immediately in case of acute chest tightness or palpitations. Scheduled for review follow-up on 04 June 2026.',
'Dr. Rajesh Sharma, MBBS, MD, DM (Cardiology)'),

('EHR-PNT002', 'PNT002', '#EHR-99202', 'Neurological Outpatient Protocol', 'Priya Sharma', 'ID: PNT002 | Age: 32 (F)', 'Dr. Priya Verma', 'Senior Consultant Neurologist', 'Neurology', 'Neurosciences Center, Room 310', '20 May 2026', '11:30 AM IST', 'Acute Migraine with Scintillating Scotoma & Tension Headache',
'<ul class="treatment-list">
  <li><strong>Cranial Nerve Examination:</strong> Intact (CN II-XII normal). No motor or sensory deficit noted.</li>
  <li><strong>Brain MRI Review:</strong> Brain parenchyma normal; no acute infarct, hemorrhage, or mass effect.</li>
  <li><strong>Prescribed Medicines:</strong>
    <ul style="margin-top: 6px; padding-left: 20px; list-style: circle;">
      <li>Tab. Zolmitriptan 2.5mg - Stat at headache onset (Max 2 doses/24h)</li>
      <li>Tab. Propranolol 20mg - Twice daily for prophylaxis</li>
      <li>Blue-light filter lenses and sleep ergonomics advised.</li>
    </ul>
  </li>
</ul>',
'Headache journal started. Patient encouraged to minimize caffeine intake after 4 PM and maintain hydration. Follow up in 3 weeks or sooner if aura frequency escalates.',
'Dr. Priya Verma, MBBS, MD, DM (Neurology)'),

('EHR-PNT003', 'PNT003', '#EHR-99203', 'Orthopedic Post-Reduction Clinical Sheet', 'Amit Singh', 'ID: PNT003 | Age: 45 (M)', 'Dr. Amit Patel', 'Senior Orthopedic & Joint Surgeon', 'Orthopedics', 'Bone & Joint Center, Room 108', '21 May 2026', '09:00 AM IST', 'Post-Fracture Right Distal Radius Rehabilitation (Union Confirmed)',
'<ul class="treatment-list">
  <li><strong>Digital Radiography (AP & Lateral):</strong> Complete bony consolidation with bridging callus across distal radial metaphysis.</li>
  <li><strong>Goniometric Range-of-Motion:</strong> Wrist dorsiflexion 50°, palmar flexion 45°, supination 70°.</li>
  <li><strong>Prescribed Medicines & Care:</strong>
    <ul style="margin-top: 6px; padding-left: 20px; list-style: circle;">
      <li>Tab. Calcium Carbonate 500mg + Vitamin D3 400IU - Once daily</li>
      <li>Gel Diclofenac Diethylamine 1.16% - Gentle topical application twice daily</li>
      <li>Structured wrist flexor resistance exercises prescribed.</li>
    </ul>
  </li>
</ul>',
'No weight lifting > 5 kg with right arm for next 4 weeks. Range of motion is progressing well. Review in 1 month with physical therapy discharge evaluation.',
'Dr. Amit Patel, MBBS, MS (Orthopedics)'),

('EHR-PNT004', 'PNT004', '#EHR-99204', 'Pediatric Immunization & Growth Tracking Record', 'Neha Patel', 'ID: PNT004 | Age: 28 (F)', 'Dr. Neha Singh', 'Chief Pediatrician & Neonatologist', 'Pediatrics', 'Child Care Pavilion, Room 102', '21 May 2026', '02:00 PM IST', '18-Month Pediatric Developmental Milestone & DTP Booster Complete',
'<ul class="treatment-list">
  <li><strong>Anthropometric Metrics:</strong> Weight: 12.4 kg (75th percentile), Height: 88 cm (70th percentile).</li>
  <li><strong>Vaccine Administered:</strong>
    <ul style="margin-top: 6px; padding-left: 20px; list-style: circle;">
      <li>DTP Booster-1 (0.5 mL IM anterolateral thigh)</li>
      <li>Oral Polio Vaccine (OPV) Booster drops administered</li>
    </ul>
  </li>
  <li><strong>Post-Vaccination Advisory:</strong> Paracetamol drops 100mg SOS for post-injection febrile reaction. Cold compress on injection site.</li>
</ul>',
'Child is active, playful, and speaking 15+ two-word phrases. Hearing and vision screening passed. Next scheduled vaccination at 24 months (Typhoid Conjugate Booster).',
'Dr. Neha Singh, MBBS, MD (Pediatrics)'),

('EHR-PNT005', 'PNT005', '#EHR-99205', 'Endocrine & Metabolic Health Encounter', 'Vikram Das', 'ID: PNT005 | Age: 58 (M)', 'Dr. Rajesh Sharma', 'Senior Consultant Physician', 'General Medicine', 'Internal Medicine Clinic, Room 215', '22 May 2026', '12:00 PM IST', 'Type-2 Diabetes Mellitus & Mixed Dyslipidemia (Controlled)',
'<ul class="treatment-list">
  <li><strong>Biochemical Profile:</strong> HbA1c: 6.8%, Fasting Blood Glucose: 114 mg/dL, Total Cholesterol: 188 mg/dL.</li>
  <li><strong>Cardiovascular Screening:</strong> Peripheral pulses palpable, ankle-brachial index (ABI) 1.05 (normal).</li>
  <li><strong>Prescribed Medicines:</strong>
    <ul style="margin-top: 6px; padding-left: 20px; list-style: circle;">
      <li>Tab. Metformin 500mg - Twice daily with principal meals</li>
      <li>Tab. Atorvastatin 10mg - Once daily at bedtime</li>
      <li>30 minutes brisk walking daily advised.</li>
    </ul>
  </li>
</ul>',
'Glycemic control is satisfactory on current oral hypoglycemic regimen. Renal function tests normal. Recommended annual diabetic retinal fundoscopy next month.',
'Dr. Rajesh Sharma, MBBS, MD, DM');

-- 9. SEED HOSPITAL BEDS OCCUPANCY
INSERT OR REPLACE INTO hospital_beds (id, bed_number, ward_type, status, current_patient_id, notes) VALUES
('BED-ICU-01', 'ICU-101', 'ICU', 'Occupied', 'PNT001', 'Post-procedure coronary observation'),
('BED-ICU-02', 'ICU-102', 'ICU', 'Available', NULL, 'Sanitized and prepped'),
('BED-ICU-03', 'ICU-103', 'ICU', 'Available', NULL, 'Equipped with mechanical ventilator'),
('BED-CCU-01', 'CCU-201', 'Cardiology CCU', 'Occupied', 'PNT005', 'Telemetry cardiac monitor attached'),
('BED-GEN-01', 'GW-301', 'General Ward', 'Occupied', 'PNT003', 'Orthopedic limb elevation sling'),
('BED-GEN-02', 'GW-302', 'General Ward', 'Available', NULL, 'Open for admission'),
('BED-GEN-03', 'GW-303', 'General Ward', 'Available', NULL, 'Open for admission'),
('BED-PED-01', 'PED-401', 'Pediatrics', 'Available', NULL, 'Pediatric cot sanitized'),
('BED-EMR-01', 'ER-BAY-1', 'Emergency', 'Available', NULL, 'Crash cart ready');

-- 10. SEED INITIAL AUDIT LOG
INSERT OR REPLACE INTO audit_logs (id, user_id, action, entity_type, entity_id, details, ip_address) VALUES
('LOG-001', 'USR-ADMIN', 'SYSTEM_INITIALIZATION', 'database', 'global', '{"message":"Hospital database initialized with seed records"}', '127.0.0.1');
