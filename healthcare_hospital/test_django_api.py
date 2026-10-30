import os
import django
import json

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'healthcare.settings')
django.setup()

from django.test import Client

client = Client()

print("=" * 60)
print(" [TEST] Testing Django + Chandra Frontend Integration")
print("=" * 60)

# -------------------------------------------------------------------------
# 1. Test HTML Page Rendering (Chandra Project UI)
# -------------------------------------------------------------------------
pages = [
    "/",
    "/index.html",
    "/about.html",
    "/services.html",
    "/departments.html",
    "/doctors.html",
    "/appointments.html",
    "/book-appointment.html",
    "/patients.html",
    "/billing.html",
    "/treatment.html",
    "/reports.html",
    "/careers.html",
    "/contact.html",
    "/login.html",
    "/register.html",
    "/admin.html",
    "/privacy.html",
    "/terms.html"
]

print("\n--- A. Testing Modern Frontend Pages ---")
for page in pages:
    r = client.get(page)
    status_msg = "OK" if r.status_code == 200 else f"FAIL ({r.status_code})"
    assert r.status_code == 200, f"Page {page} failed with status {r.status_code}"
    print(f"[{status_msg}] Page: {page} (Length: {len(r.content)} bytes)")

# -------------------------------------------------------------------------
# 2. Test Root Static File Resolvers
# -------------------------------------------------------------------------
print("\n--- B. Testing Direct Static Asset Resolvers ---")
static_assets = [
    "/styles.css",
    "/script.js",
    "/api-client.js",
    "/favicon.svg",
    "/assets/doctor_rajesh.jpg"
]

for asset in static_assets:
    r = client.get(asset)
    status_msg = "OK" if r.status_code == 200 else f"FAIL ({r.status_code})"
    assert r.status_code == 200, f"Asset {asset} failed with status {r.status_code}"
    print(f"[{status_msg}] Static: {asset} (Content-Type: {r.headers.get('Content-Type')})")

# -------------------------------------------------------------------------
# 3. Test REST API Endpoints
# -------------------------------------------------------------------------
print("\n--- C. Testing Django REST API Endpoints ---")

# 1. Debug Env
r = client.get('/api/debug-env')
assert r.status_code == 200
print(f"[OK] GET /api/debug-env: {r.status_code} ({r.json().get('status')})")

# 2. Patients GET & POST
r = client.get('/api/patients')
assert r.status_code == 200
print(f"[OK] GET /api/patients: {r.status_code} (count: {r.json().get('count')})")

r = client.post('/api/patients', data=json.dumps({"name": "Anita Verma", "phone": "+91 98765 44444", "dept": "Cardiology"}), content_type="application/json")
assert r.status_code == 201
p_id = r.json().get('data', {}).get('id')
print(f"[OK] POST /api/patients: {r.status_code} (created: {p_id})")

# 3. Appointments GET & POST
r = client.get('/api/appointments')
assert r.status_code == 200
print(f"[OK] GET /api/appointments: {r.status_code} (count: {r.json().get('count')})")

r = client.post('/api/appointments', data=json.dumps({"patient": "Anita Verma", "reason": "Heart Checkup"}), content_type="application/json")
assert r.status_code == 201
a_id = r.json().get('data', {}).get('id')
print(f"[OK] POST /api/appointments: {r.status_code} (booked: {a_id})")

# 4. Doctors GET
r = client.get('/api/doctors')
assert r.status_code == 200
print(f"[OK] GET /api/doctors: {r.status_code} (count: {r.json().get('count')})")

# 5. Billing GET & PATCH
r = client.get('/api/billing')
assert r.status_code == 200
print(f"[OK] GET /api/billing: {r.status_code} (count: {r.json().get('count')})")

r = client.patch('/api/billing/INV003', data=json.dumps({"paymentMethod": "UPI"}), content_type="application/json")
assert r.status_code == 200
print(f"[OK] PATCH /api/billing/INV003: {r.status_code} ({r.json().get('message')})")

# 6. Stats Dashboard GET
r = client.get('/api/stats/dashboard')
assert r.status_code == 200
print(f"[OK] GET /api/stats/dashboard: {r.status_code} (patientsCount: {r.json().get('stats', {}).get('patientsCount')})")

# 7. Treatment EHR GET
r = client.get('/api/treatment/PNT001')
assert r.status_code == 200
print(f"[OK] GET /api/treatment/PNT001: {r.status_code} (ehr: {r.json().get('data', {}).get('ehr')})")

# 8. Auth Login POST
r = client.post('/api/auth/login', data=json.dumps({"email": "rajesh@healthcare.com", "password": "doctor123"}), content_type="application/json")
assert r.status_code == 200
print(f"[OK] POST /api/auth/login: {r.status_code} (user: {r.json().get('user', {}).get('name')})")

# 9. Auth Register POST
r = client.post('/api/auth/register', data=json.dumps({
    "email": f"test_patient_{os.urandom(3).hex()}@healthcare.com",
    "password": "patient123",
    "full_name": "Meera Joshi",
    "phone": "+91 98765 77777"
}), content_type="application/json")
assert r.status_code == 201
print(f"[OK] POST /api/auth/register: {r.status_code} (user: {r.json().get('user', {}).get('name')})")

# 10. Auth Me GET
r = client.get('/api/auth/me')
assert r.status_code == 200
print(f"[OK] GET /api/auth/me: {r.status_code} (active user: {r.json().get('user', {}).get('name')})")

# 11. Auth Logout POST
r = client.post('/api/auth/logout')
assert r.status_code == 200
print(f"[OK] POST /api/auth/logout: {r.status_code}")

# 12. Doctor Application POST
r = client.post('/api/applications/doctor', data=json.dumps({
    "fullName": "Dr. Vivek Murthy",
    "email": "vivek@example.com",
    "specialization": "Pediatrics"
}), content_type="application/json")
assert r.status_code == 201
print(f"[OK] POST /api/applications/doctor: {r.status_code} (ref: {r.json().get('reference')})")

# 13. Career Application POST
r = client.post('/api/applications/career', data=json.dumps({
    "name": "Sunita Rao",
    "position": "Senior ICU Staff Nurse"
}), content_type="application/json")
assert r.status_code == 201
print(f"[OK] POST /api/applications/career: {r.status_code} (ref: {r.json().get('reference')})")

# 14. Contact Ticket POST
r = client.post('/api/contact', data=json.dumps({
    "name": "Rohan Gupta",
    "email": "rohan@example.com",
    "message": "Inquiry about OPD timings"
}), content_type="application/json")
assert r.status_code == 201
print(f"[OK] POST /api/contact: {r.status_code} (ticket: {r.json().get('ticketId')})")

# 15. Audit Logs GET
r = client.get('/api/admin/audit-logs')
assert r.status_code == 200
print(f"[OK] GET /api/admin/audit-logs: {r.status_code} (count: {r.json().get('count')}, standard: {r.json().get('complianceStandard')})")

print("\n" + "=" * 60)
print(" [SUCCESS] ALL PAGES, STATIC ASSETS, AND REST APIS PASSED WITH 100% SUCCESS!")
print("=" * 60)
