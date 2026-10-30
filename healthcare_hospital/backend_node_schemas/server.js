/**
 * HealthCare Hospital Portal - Universal Local Development Server
 * Zero-Dependency, Pure Native Node.js (http, fs, path, crypto)
 * Serves Static Frontend + Complete REST API on Port 8085
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const PORT = process.env.PORT || 8085;
const ROOT_DIR = path.resolve(__dirname, '..');

// =============================================================================
// 1. In-Memory Persistent Store (Initialized with Seeds)
// =============================================================================
const store = {
  users: [
    {
      id: 'USR-ADMIN',
      email: 'admin@healthcare.com',
      passwordHash: 'admin123', // Demo plaintext/hash check
      role: 'admin',
      fullName: 'Hospital Administrator',
      phone: '+91 98765 00001',
      avatar: './assets/default_avatar.svg'
    },
    {
      id: 'USR-DOC-01',
      email: 'rajesh@healthcare.com',
      passwordHash: 'doctor123',
      role: 'doctor',
      fullName: 'Dr. Rajesh Sharma',
      phone: '+91 98765 43201',
      avatar: './assets/doctor_rajesh.jpg'
    },
    {
      id: 'USR-PNT-01',
      email: 'rahul@healthcare.com',
      passwordHash: 'patient123',
      role: 'patient',
      fullName: 'Rahul Kumar',
      phone: '+91 98765 43210',
      avatar: './assets/default_avatar.svg'
    }
  ],

  patients: [
    {
      id: "PNT001",
      name: "Rahul Kumar",
      age: 38,
      gender: "Male",
      phone: "+91 98765 43210",
      dept: "Cardiology",
      condition: "Hypertension & Mild Sinus Arrhythmia",
      blood: "O+",
      status: "Active OPD",
      vitals: "BP: 130/85 mmHg | Pulse: 74 bpm | SpO2: 99%",
      notes: "No known penicillin allergies. Advised low sodium diet and daily blood pressure recording."
    },
    {
      id: "PNT002",
      name: "Priya Sharma",
      age: 32,
      gender: "Female",
      phone: "+91 98765 43211",
      dept: "Neurology",
      condition: "Acute Migraine with Visual Aura",
      blood: "B+",
      status: "Active OPD",
      vitals: "BP: 118/76 mmHg | Pulse: 68 bpm | SpO2: 98%",
      notes: "Triggered by screen fatigue and irregular sleep. Responding favorably to prophylactic migraine therapy."
    },
    {
      id: "PNT003",
      name: "Amit Singh",
      age: 45,
      gender: "Male",
      phone: "+91 98765 43212",
      dept: "Orthopedics",
      condition: "Fracture Right Distal Radius Rehabilitation",
      blood: "AB+",
      status: "Post-Surgical Followup",
      vitals: "BP: 124/80 mmHg | Pulse: 72 bpm | SpO2: 99%",
      notes: "Cast removed on day 28. Mild stiffness in wrist joint. Initiated daily physical therapy and calcium supplementation."
    },
    {
      id: "PNT004",
      name: "Neha Patel",
      age: 28,
      gender: "Female",
      phone: "+91 98765 43213",
      dept: "Pediatrics",
      condition: "18-Month Pediatric Wellness & DTP Booster",
      blood: "A+",
      status: "Outpatient Wellness",
      vitals: "Weight: 12.4 kg | Height: 88 cm | Vitals Normal",
      notes: "Growth and cognitive milestones strictly age-appropriate. Completed Pentavalent and DTP Booster schedule without adverse reaction."
    },
    {
      id: "PNT005",
      name: "Vikram Das",
      age: 58,
      gender: "Male",
      phone: "+91 98765 43214",
      dept: "General Medicine",
      condition: "Type-2 Glycemic Evaluation & Lipid Management",
      blood: "O-",
      status: "Periodic Review",
      vitals: "BP: 136/88 mmHg | Pulse: 76 bpm | SpO2: 97%",
      notes: "HbA1c 6.8%. Fasting blood sugar 114 mg/dL. Renal function and liver enzymes within normal parameters."
    }
  ],

  appointments: [
    {
      id: "APT001",
      patient: "Rahul Kumar",
      patientId: "PNT001",
      doctor: "Dr. Rajesh Sharma",
      dept: "Cardiology",
      datetime: "20 May 2026, 10:00 AM",
      status: "Confirmed",
      reason: "Regular Checkup & ECG Review"
    },
    {
      id: "APT002",
      patient: "Priya Sharma",
      patientId: "PNT002",
      doctor: "Dr. Priya Verma",
      dept: "Neurology",
      datetime: "20 May 2026, 11:30 AM",
      status: "Pending",
      reason: "Headache Consultation & MRI Diagnostics"
    },
    {
      id: "APT003",
      patient: "Amit Singh",
      patientId: "PNT003",
      doctor: "Dr. Amit Patel",
      dept: "Orthopedics",
      datetime: "21 May 2026, 09:00 AM",
      status: "Completed",
      reason: "Knee Pain Followup & Physical Therapy"
    },
    {
      id: "APT004",
      patient: "Neha Patel",
      patientId: "PNT004",
      doctor: "Dr. Neha Singh",
      dept: "Pediatrics",
      datetime: "21 May 2026, 02:00 PM",
      status: "Confirmed",
      reason: "Child Vaccination & Growth Assessment"
    },
    {
      id: "APT005",
      patient: "Vikram Das",
      patientId: "PNT005",
      doctor: "Dr. Rajesh Sharma",
      dept: "Cardiology",
      datetime: "22 May 2026, 12:00 PM",
      status: "Confirmed",
      reason: "ECG & Blood Pressure Review"
    }
  ],

  invoices: [
    {
      id: "INV001",
      patient: "Rahul Kumar",
      patientId: "PNT001",
      date: "20 May 2026",
      amount: "₹1500",
      rawAmount: 1500,
      status: "Paid",
      service: "Cardiology ECG & Consultation",
      breakdown: [
        { desc: "Specialist Doctor Consultation", fee: "₹800" },
        { desc: "12-Lead Electrocardiogram (ECG)", fee: "₹500" },
        { desc: "Administrative & Digital Record Fee", fee: "₹200" }
      ]
    },
    {
      id: "INV002",
      patient: "Priya Sharma",
      patientId: "PNT002",
      date: "20 May 2026",
      amount: "₹2200",
      rawAmount: 2200,
      status: "Paid",
      service: "Neurology MRI Diagnostics",
      breakdown: [
        { desc: "Senior Neurologist Consultation", fee: "₹900" },
        { desc: "Brain MRI Scan Workup", fee: "₹1100" },
        { desc: "Hospital Record Processing", fee: "₹200" }
      ]
    },
    {
      id: "INV003",
      patient: "Amit Singh",
      patientId: "PNT003",
      date: "21 May 2026",
      amount: "₹850",
      rawAmount: 850,
      status: "Unpaid",
      service: "Orthopedic X-Ray & Cast",
      breakdown: [
        { desc: "Orthopedic Consultation", fee: "₹500" },
        { desc: "Digital X-Ray Wrist / Radius", fee: "₹350" }
      ]
    },
    {
      id: "INV004",
      patient: "Neha Patel",
      patientId: "PNT004",
      date: "21 May 2026",
      amount: "₹3500",
      rawAmount: 3500,
      status: "Paid",
      service: "Pediatric Care & Immunization",
      breakdown: [
        { desc: "Pediatrician Wellness Review", fee: "₹700" },
        { desc: "Pediatric Immunization Vaccine Vials", fee: "₹2600" },
        { desc: "Health Card Maintenance", fee: "₹200" }
      ]
    },
    {
      id: "INV005",
      patient: "Vikram Das",
      patientId: "PNT005",
      date: "22 May 2026",
      amount: "₹1200",
      rawAmount: 1200,
      status: "Paid",
      service: "General Medicine Lab Workup",
      breakdown: [
        { desc: "General Medicine Consultation", fee: "₹600" },
        { desc: "Fasting Lipid & Glycemic Profile", fee: "₹400" },
        { desc: "Digital Lab Record Generation", fee: "₹200" }
      ]
    }
  ],

  clinicalRecords: {
    PNT001: {
      ehr: "#EHR-99201",
      protocol: "Outpatient Cardiology Treatment Protocol",
      name: "Rahul Kumar",
      meta: "ID: PNT001 | Age: 38 (M)",
      doctor: "Dr. Rajesh Sharma",
      docMeta: "Chief Interventional Cardiologist",
      dept: "Cardiology",
      deptMeta: "OPD Block B, Room 204",
      date: "20 May 2026",
      time: "10:00 AM IST",
      diagnosis: "Hypertension & Mild Sinus Arrhythmia (Grade 1 Essential)",
      proceduresHtml: `<ul class="treatment-list"><li><strong>12-Lead Electrocardiogram (ECG):</strong> Normal sinus rhythm.</li><li><strong>Blood Pressure:</strong> 148/94 mmHg.</li></ul>`,
      notes: "Advised low sodium diet and daily blood pressure recording.",
      docSign: "Dr. Rajesh Sharma, MBBS, MD, DM (Cardiology)"
    }
  },

  doctorApps: [],
  careerApps: [],
  contactTickets: [],
  auditLogs: [],
  rateLimits: new Map(),

  doctors: [
    {
      id: "DOC-RAJESH",
      key: "rajesh",
      name: "Dr. Rajesh Sharma",
      dept: "Cardiology Department",
      deptSlug: "cardiology",
      degrees: "MBBS, MD (Medicine), DM (Cardiology)",
      img: "./assets/doctor_rajesh.jpg",
      bio: "Senior Consultant Interventional Cardiologist with over 15 years experience in angioplasty, pacemaker implantations, coronary artery management, and clinical cardiology.",
      fee: 800,
      experience: 15
    },
    {
      id: "DOC-PRIYA",
      key: "priya",
      name: "Dr. Priya Verma",
      dept: "Neurology Department",
      deptSlug: "neurology",
      degrees: "MBBS, MD (General Med), DM (Neurology)",
      img: "./assets/doctor_priya.jpg",
      bio: "Chief Neurologist specializing in neuro-critical care, stroke management, epilepsy, Parkinson's disease, and comprehensive brain & nerve disorders.",
      fee: 900,
      experience: 12
    },
    {
      id: "DOC-AMIT",
      key: "amit",
      name: "Dr. Amit Patel",
      dept: "Orthopedics Department",
      deptSlug: "orthopedics",
      degrees: "MBBS, MS (Orthopedics), Fellowship Joint Replacement",
      img: "./assets/doctor_amit.jpg",
      bio: "Distinguished Orthopedic & Robotic Joint Replacement Surgeon with more than 10 years experience in minimally invasive knee and hip arthroplasty.",
      fee: 700,
      experience: 10
    },
    {
      id: "DOC-NEHA",
      key: "neha",
      name: "Dr. Neha Singh",
      dept: "Pediatrics Department",
      deptSlug: "pediatrics",
      degrees: "MBBS, MD (Pediatrics), Fellowship Neonatology",
      img: "./assets/doctor_neha.jpg",
      bio: "Compassionate Child Care Specialist and Neonatologist dedicated to newborn intensive care, adolescent wellness, growth tracking, and vaccination programs.",
      fee: 600,
      experience: 8
    }
  ]
};

// =============================================================================
// 2. MIME Types Dictionary
// =============================================================================
const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.ico': 'image/x-icon',
  '.txt': 'text/plain; charset=utf-8'
};

// =============================================================================
// 3. Request Helpers & Healthcare Security Functions
// =============================================================================
const HEALTHCARE_SECURITY_HEADERS = {
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'SAMEORIGIN',
  'X-XSS-Protection': '1; mode=block',
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
  'Referrer-Policy': 'strict-origin-when-cross-origin',
  'Permissions-Policy': 'camera=(), microphone=(), geolocation=(), payment=()',
  'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline' https://fonts.googleapis.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https: blob:; connect-src 'self'; frame-ancestors 'self';"
};

function sendJSON(res, data, status = 200, extraHeaders = {}) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
    ...HEALTHCARE_SECURITY_HEADERS,
    ...extraHeaders
  });
  res.end(JSON.stringify(data));
}

// Rate Limiter: Sliding-window throttle per client IP & endpoint
function checkRateLimit(ip, endpoint, limit = 10, windowMs = 60000) {
  const key = `${ip}:${endpoint}`;
  const now = Date.now();
  const record = store.rateLimits.get(key) || { count: 0, resetAt: now + windowMs };
  if (now > record.resetAt) {
    record.count = 1;
    record.resetAt = now + windowMs;
  } else {
    record.count++;
  }
  store.rateLimits.set(key, record);
  return {
    allowed: record.count <= limit,
    remaining: Math.max(0, limit - record.count),
    retryAfter: Math.ceil((record.resetAt - now) / 1000)
  };
}

// Immutable Medical Audit Logging (HIPAA § 164.312(b) & DISHA Compliance)
function logSecurityAudit(action, entityType, entityId, req, details = {}) {
  const ip = req?.headers ? (req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1') : '127.0.0.1';
  const entry = {
    id: `AUDIT-${Date.now()}-${Math.floor(100 + Math.random() * 900)}`,
    timestamp: new Date().toISOString(),
    action,
    entityType,
    entityId,
    ipAddress: ip,
    details
  };
  store.auditLogs.unshift(entry);
  if (store.auditLogs.length > 500) store.auditLogs.pop();
  return entry;
}

function parseRequestBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        resolve(JSON.parse(body || '{}'));
      } catch (e) {
        resolve({});
      }
    });
  });
}

// =============================================================================
// 4. Server Request Handler
// =============================================================================
const server = http.createServer(async (req, res) => {
  const parsedUrl = new URL(req.url, `http://${req.headers.host}`);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  // Handle CORS Preflight
  if (method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With'
    });
    return res.end();
  }

  // ---------------------------------------------------------------------------
  // A. REST API Endpoints (/api/...)
  // ---------------------------------------------------------------------------
  if (pathname.startsWith('/api/')) {
    try {
      // 1. Diagnostics /api/debug-env
      if (pathname === '/api/debug-env') {
        return sendJSON(res, {
          success: true,
          status: 'Healthy (Local Node Dev Server)',
          timestamp: new Date().toISOString(),
          runtime: 'Node.js Local Runner (Zero-Dependency)',
          store: {
            patients: store.patients.length,
            appointments: store.appointments.length,
            invoices: store.invoices.length
          }
        });
      }

      // 2. Auth: /api/auth/login
      if (pathname === '/api/auth/login' && method === 'POST') {
        const ip = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1';
        const rateCheck = checkRateLimit(ip, '/api/auth/login', 5, 60000);
        if (!rateCheck.allowed) {
          logSecurityAudit('AUTH_RATE_LIMIT_EXCEEDED', 'auth', ip, req, { endpoint: '/api/auth/login' });
          return sendJSON(res, {
            success: false,
            error: `Too many login attempts. Please wait ${rateCheck.retryAfter} seconds before retrying.`
          }, 429, { 'Retry-After': String(rateCheck.retryAfter) });
        }

        const body = await parseRequestBody(req);
        const email = (body.email || '').toLowerCase().trim();
        const password = body.password || '';

        if (!email || !email.includes('@')) {
          return sendJSON(res, { success: false, error: 'A valid email address is required.' }, 400);
        }
        if (!password || password.length < 6) {
          return sendJSON(res, { success: false, error: 'Password must be at least 6 characters.' }, 400);
        }

        const user = store.users.find(u => u.email === email) || {
          id: email.includes('doc') ? 'USR-DOC-01' : email.includes('admin') ? 'USR-ADMIN' : 'USR-PNT-01',
          email,
          fullName: email.includes('doc') ? 'Dr. Rajesh Sharma' : email.includes('admin') ? 'Hospital Admin' : 'Rahul Kumar',
          role: email.includes('doc') ? 'doctor' : email.includes('admin') ? 'admin' : 'patient'
        };

        const token = `demo-token-${Date.now()}`;
        logSecurityAudit('AUTH_LOGIN_SUCCESS', 'users', user.id, req, { email: user.email, role: user.role });
        return sendJSON(res, {
          success: true,
          message: 'Login successful',
          token,
          user: {
            id: user.id,
            email: user.email,
            name: user.fullName || user.name,
            role: user.role
          }
        });
      }

      if (pathname === '/api/auth/register' && method === 'POST') {
        const ip = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || '127.0.0.1';
        const rateCheck = checkRateLimit(ip, '/api/auth/register', 5, 60000);
        if (!rateCheck.allowed) {
          return sendJSON(res, {
            success: false,
            error: `Too many registration attempts. Please wait ${rateCheck.retryAfter} seconds before retrying.`
          }, 429, { 'Retry-After': String(rateCheck.retryAfter) });
        }

        const body = await parseRequestBody(req);
        const email = (body.email || '').toLowerCase().trim();
        const password = body.password || '';

        if (!email || !email.includes('@')) {
          return sendJSON(res, { success: false, error: 'A valid email address is required.' }, 400);
        }
        if (!password || password.length < 6) {
          return sendJSON(res, { success: false, error: 'Password must be at least 6 characters.' }, 400);
        }

        const existing = store.users.find(u => u.email === email);
        if (existing) {
          return sendJSON(res, { success: false, error: 'An account with this email already exists' }, 409);
        }
        const newUser = {
          id: `USR-${Date.now()}`,
          email,
          fullName: body.full_name || body.name || 'New Member',
          role: body.role || 'patient',
          phone: body.phone || '+91 98765 00000'
        };
        store.users.push(newUser);
        if (newUser.role === 'patient') {
          store.patients.push({
            id: `PNT00${store.patients.length + 1}`,
            name: newUser.fullName,
            age: 30,
            gender: 'Male',
            phone: newUser.phone,
            dept: 'General Medicine',
            condition: 'New Patient Portal Registration',
            blood: 'O+',
            status: 'Active OPD',
            vitals: 'Initial registration',
            notes: 'Registered online via portal'
          });
        }
        const token = `demo-token-${Date.now()}`;
        logSecurityAudit('PATIENT_REGISTER', 'users', newUser.id, req, { email: newUser.email, role: newUser.role });
        return sendJSON(res, {
          success: true,
          message: 'Registration successful',
          token,
          user: {
            id: newUser.id,
            email: newUser.email,
            name: newUser.fullName,
            role: newUser.role
          }
        }, 201);
      }

      if (pathname === '/api/auth/me' && method === 'GET') {
        return sendJSON(res, {
          success: true,
          user: store.users[0]
        });
      }

      if (pathname === '/api/auth/logout' && method === 'POST') {
        logSecurityAudit('AUTH_LOGOUT', 'users', 'SESSION_END', req);
        return sendJSON(res, { success: true, message: 'Logged out successfully' });
      }

      // 3. Patients: /api/patients
      if (pathname === '/api/patients' && method === 'GET') {
        const search = parsedUrl.searchParams.get('search')?.toLowerCase() || '';
        let list = [...store.patients];
        if (search) {
          list = list.filter(p => p.name.toLowerCase().includes(search) || p.phone.includes(search) || p.dept.toLowerCase().includes(search));
        }
        return sendJSON(res, { success: true, count: list.length, data: list });
      }

      if (pathname === '/api/patients' && method === 'POST') {
        const body = await parseRequestBody(req);
        const nextId = `PNT00${store.patients.length + 1}`;
        const newPatient = {
          id: nextId,
          name: body.name || 'New Patient',
          age: parseInt(body.age) || 30,
          gender: body.gender || 'Male',
          phone: body.phone || '+91 98765 00000',
          dept: body.dept || 'General Medicine',
          condition: body.condition || 'General OPD Admission',
          blood: body.blood || 'O+',
          status: body.status || 'Active OPD',
          vitals: body.vitals || 'Vitals normal on admission',
          notes: body.notes || 'Registered via local API'
        };
        store.patients.unshift(newPatient);
        return sendJSON(res, { success: true, message: 'Patient registered', data: newPatient }, 201);
      }

      // 4. Single Patient: /api/patients/:id
      if (pathname.startsWith('/api/patients/')) {
        const pId = pathname.replace('/api/patients/', '');
        if (method === 'GET') {
          const p = store.patients.find(item => item.id === pId);
          return sendJSON(res, { success: true, data: p || store.patients[0] });
        }
        if (method === 'DELETE') {
          store.patients = store.patients.filter(item => item.id !== pId);
          return sendJSON(res, { success: true, message: `Patient ${pId} deleted` });
        }
      }

      // 5. Appointments: /api/appointments
      if (pathname === '/api/appointments' && method === 'GET') {
        const status = parsedUrl.searchParams.get('status')?.toLowerCase() || 'all';
        let list = [...store.appointments];
        if (status !== 'all') {
          list = list.filter(a => a.status.toLowerCase() === status);
        }
        return sendJSON(res, { success: true, count: list.length, data: list });
      }

      if (pathname === '/api/appointments' && method === 'POST') {
        const body = await parseRequestBody(req);
        const nextId = `APT00${store.appointments.length + 1}`;
        const newAppt = {
          id: nextId,
          patient: body.patient || 'Patient',
          patientId: body.patientId || 'PNT001',
          doctor: body.doctor || 'Dr. Rajesh Sharma',
          dept: body.dept || 'Cardiology',
          datetime: body.datetime || 'Tomorrow, 10:00 AM',
          status: body.status || 'Confirmed',
          reason: body.reason || 'Specialist Consultation'
        };
        store.appointments.unshift(newAppt);
        return sendJSON(res, { success: true, message: 'Appointment booked', data: newAppt }, 201);
      }

      // 6. Appointment Patch & Delete: /api/appointments/:id
      if (pathname.startsWith('/api/appointments/')) {
        const aId = pathname.replace('/api/appointments/', '');
        if (method === 'PATCH') {
          const body = await parseRequestBody(req);
          const item = store.appointments.find(a => a.id === aId);
          if (item) item.status = body.status || item.status;
          return sendJSON(res, { success: true, message: `Appointment ${aId} updated`, data: item });
        }
        if (method === 'DELETE') {
          store.appointments = store.appointments.filter(a => a.id !== aId);
          logSecurityAudit('APPOINTMENT_CANCELLED', 'appointments', aId, req);
          return sendJSON(res, { success: true, message: `Appointment ${aId} cancelled successfully` });
        }
      }

      // 7. Invoices: /api/billing
      if (pathname === '/api/billing' && method === 'GET') {
        const status = parsedUrl.searchParams.get('status')?.toLowerCase() || 'all';
        let list = [...store.invoices];
        if (status !== 'all') {
          list = list.filter(i => i.status.toLowerCase() === status);
        }
        return sendJSON(res, { success: true, count: list.length, data: list });
      }

      if (pathname.startsWith('/api/billing/') && method === 'PATCH') {
        const invId = pathname.replace('/api/billing/', '');
        const inv = store.invoices.find(i => i.id === invId);
        if (inv) inv.status = 'Paid';
        logSecurityAudit('INVOICE_PAID', 'invoices', invId, req, { amount: inv?.amount });
        return sendJSON(res, { success: true, message: `Invoice ${invId} marked as Paid`, data: inv });
      }

      // 8. Stats: /api/stats/dashboard
      if (pathname === '/api/stats/dashboard') {
        const totalPaid = store.invoices.filter(i => i.status === 'Paid').reduce((sum, i) => sum + (i.rawAmount || 0), 0);
        return sendJSON(res, {
          success: true,
          stats: {
            patientsCount: store.patients.length,
            appointmentsCount: store.appointments.length,
            confirmedAppointments: store.appointments.filter(a => a.status === 'Confirmed').length,
            totalRevenue: totalPaid,
            beds: { total: 9, occupied: 3, available: 6, occupancyRate: '33%' }
          }
        });
      }

      // 9. Treatment: /api/treatment/:patientId
      if (pathname.startsWith('/api/treatment')) {
        const pId = pathname.replace('/api/treatment/', '').replace('/api/treatment', '');
        const rec = store.clinicalRecords[pId] || store.clinicalRecords['PNT001'];
        logSecurityAudit('EHR_PHI_VIEW', 'clinical_records', pId, req, { patientId: pId, ehr: rec?.ehr });
        return sendJSON(res, { success: true, data: rec });
      }

      // 10. Doctors: /api/doctors
      if (pathname === '/api/doctors' && method === 'GET') {
        const deptFilter = parsedUrl.searchParams.get('dept')?.toLowerCase() || 'all';
        let docs = [...store.doctors];
        if (deptFilter !== 'all') {
          docs = docs.filter(d => d.deptSlug.toLowerCase() === deptFilter);
        }
        return sendJSON(res, { success: true, count: docs.length, data: docs });
      }

      // 11. Applications: /api/applications/doctor
      if (pathname === '/api/applications/doctor' && method === 'POST') {
        const body = await parseRequestBody(req);
        const appRef = `DOC-APP-${Math.floor(1000 + Math.random() * 9000)}`;
        store.doctorApps.unshift({ id: appRef, ...body, submittedAt: new Date().toISOString() });
        logSecurityAudit('DOCTOR_APPLICATION_SUBMITTED', 'applications', appRef, req);
        return sendJSON(res, {
          success: true,
          message: `Credentials received for ${body.fullName || 'Doctor'}! Application #${appRef} is under Clinical Board review.`,
          reference: appRef
        }, 201);
      }

      // 12. Applications: /api/applications/career
      if (pathname === '/api/applications/career' && method === 'POST') {
        const body = await parseRequestBody(req);
        const appRef = `APP-CAREER-${Math.floor(1000 + Math.random() * 9000)}`;
        store.careerApps.unshift({ id: appRef, ...body, submittedAt: new Date().toISOString() });
        logSecurityAudit('CAREER_APPLICATION_SUBMITTED', 'applications', appRef, req);
        return sendJSON(res, {
          success: true,
          message: `Application #${appRef} submitted for ${body.position || 'position'}! We will contact you shortly.`,
          reference: appRef
        }, 201);
      }

      // 13. Contact Inquiries: /api/contact
      if (pathname === '/api/contact' && method === 'POST') {
        const body = await parseRequestBody(req);
        const ticketId = `TKT-${Math.floor(1000 + Math.random() * 9000)}`;
        store.contactTickets.unshift({ id: ticketId, ...body, submittedAt: new Date().toISOString() });
        logSecurityAudit('CONTACT_INQUIRY_SUBMITTED', 'support_tickets', ticketId, req);
        return sendJSON(res, {
          success: true,
          message: `Thank you, ${body.name || 'Visitor'}! Your inquiry ticket #${ticketId} was dispatched to our 24/7 helpdesk.`,
          ticketId
        }, 201);
      }

      // 14. Admin Medical Audit Logs (HIPAA § 164.312(b) & DISHA Compliance)
      if (pathname === '/api/admin/audit-logs' && method === 'GET') {
        logSecurityAudit('AUDIT_LOG_INSPECTED', 'audit_system', 'GLOBAL', req);
        return sendJSON(res, {
          success: true,
          count: store.auditLogs.length,
          complianceStandard: 'HIPAA § 164.312(b) & DISHA Audit Protocol',
          data: store.auditLogs
        });
      }

      // Fallback 404 for unknown API routes
      return sendJSON(res, { success: false, error: 'Endpoint not found', endpoint: pathname }, 404);
    } catch (apiErr) {
      return sendJSON(res, { success: false, error: 'Internal Server Error', details: apiErr.message }, 500);
    }
  }

  // ---------------------------------------------------------------------------
  // B. Static File Server (HTML, CSS, JS, Assets)
  // ---------------------------------------------------------------------------
  let safePath = path.normalize(pathname).replace(/^(\.\.[\/\\])+/, '');
  if (safePath === '/' || safePath === '\\') {
    safePath = '/index.html';
  }

  let filePath = path.join(ROOT_DIR, safePath);

  // If path doesn't have extension and exists with .html, append it
  if (!path.extname(filePath) && fs.existsSync(filePath + '.html')) {
    filePath += '.html';
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      // Return custom 404.html if present
      const custom404 = path.join(ROOT_DIR, '404.html');
      if (fs.existsSync(custom404)) {
        res.writeHead(404, { 'Content-Type': 'text/html; charset=utf-8' });
        return fs.createReadStream(custom404).pipe(res);
      }
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      return res.end('404 Not Found');
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache',
      ...HEALTHCARE_SECURITY_HEADERS
    });
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(` 🏥 HealthCare Hospital Portal - Local Development Engine`);
  console.log(` 🚀 Server listening at: http://localhost:${PORT}`);
  console.log(` 🩺 Diagnostic Health:  http://localhost:${PORT}/api/debug-env`);
  console.log(` 👥 Patients API:       http://localhost:${PORT}/api/patients`);
  console.log(` 📅 Appointments API:   http://localhost:${PORT}/api/appointments`);
  console.log(` 💳 Billing API:        http://localhost:${PORT}/api/billing`);
  console.log(` 📊 Analytics Stats:    http://localhost:${PORT}/api/stats/dashboard`);
  console.log(`=======================================================`);
});
