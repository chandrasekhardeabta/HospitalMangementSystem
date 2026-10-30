/**
 * HealthCare Hospital Portal - Universal API Client
 * Seamlessly interfaces between Live Backend REST API and Offline Local Storage
 * 100% Production-Grade, Dual-Mode Resilient
 */

const ApiClient = {
  baseUrl: (typeof localStorage !== 'undefined' && localStorage.getItem('hospital_api_base')) || '/api',

  setBackendUrl(url) {
    this.baseUrl = url || '/api';
    if (typeof localStorage !== 'undefined') {
      if (url && url !== '/api') {
        localStorage.setItem('hospital_api_base', url);
      } else {
        localStorage.removeItem('hospital_api_base');
      }
    }
    console.log(`[ApiClient]: Active backend route set to: ${this.baseUrl}`);
  },

  getBackendUrl() {
    return this.baseUrl;
  },

  async request(endpoint, options = {}) {
    const url = `${this.baseUrl}${endpoint}`;
    const token = typeof localStorage !== 'undefined' ? localStorage.getItem('hospital_jwt_token') : null;

    const headers = {
      'Content-Type': 'application/json',
      ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
      ...(options.headers || {})
    };

    try {
      const res = await fetch(url, { ...options, headers });
      if (!res.ok) {
        const errorText = await res.text();
        let parsed;
        try { parsed = JSON.parse(errorText); } catch(e) { parsed = { error: errorText }; }
        throw new Error(parsed?.error || `HTTP ${res.status}: ${res.statusText}`);
      }
      return await res.json();
    } catch (err) {
      // Offline or Edge connection issue - log and return null for safe fallback
      console.warn(`[ApiClient Network Alert]: ${endpoint} unavailable, falling back to local store.`, err.message);
      return null;
    }
  },

  // --- Health Diagnostics ---
  async checkHealth() {
    return await this.request('/debug-env');
  },

  // --- Patients API ---
  async getPatients(search = '', dept = '') {
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    if (dept && dept !== 'all') params.set('dept', dept);

    const qs = params.toString() ? `?${params.toString()}` : '';
    const res = await this.request(`/patients${qs}`);
    if (res && res.success && Array.isArray(res.data)) {
      if (typeof HospitalStore !== 'undefined' && !search && (!dept || dept === 'all')) {
        localStorage.setItem(HospitalStore.KEYS.PATIENTS, JSON.stringify(res.data));
      }
      return res.data;
    }
    return typeof HospitalStore !== 'undefined' ? HospitalStore.getPatients() : [];
  },

  async createPatient(patientData) {
    const res = await this.request('/patients', {
      method: 'POST',
      body: JSON.stringify(patientData)
    });
    if (res && res.success && res.data) {
      if (typeof HospitalStore !== 'undefined') {
        HospitalStore.savePatient(res.data);
      }
      return res.data;
    }
    // Local fallback
    return typeof HospitalStore !== 'undefined' ? HospitalStore.savePatient(patientData) : patientData;
  },

  async deletePatient(id) {
    await this.request(`/patients/${id}`, { method: 'DELETE' });
    if (typeof HospitalStore !== 'undefined') {
      return HospitalStore.deletePatient(id);
    }
    return true;
  },

  // --- Appointments API ---
  async getAppointments(status = 'all', search = '') {
    const params = new URLSearchParams();
    if (status && status !== 'all') params.set('status', status);
    if (search) params.set('search', search);

    const qs = params.toString() ? `?${params.toString()}` : '';
    const res = await this.request(`/appointments${qs}`);
    if (res && res.success && Array.isArray(res.data)) {
      if (typeof HospitalStore !== 'undefined' && status === 'all' && !search) {
        localStorage.setItem(HospitalStore.KEYS.APPOINTMENTS, JSON.stringify(res.data));
      }
      return res.data;
    }
    return typeof HospitalStore !== 'undefined' ? HospitalStore.getAppointments() : [];
  },

  async bookAppointment(apptData) {
    const res = await this.request('/appointments', {
      method: 'POST',
      body: JSON.stringify(apptData)
    });
    if (res && res.success && res.data) {
      if (typeof HospitalStore !== 'undefined') {
        HospitalStore.saveAppointment(res.data);
      }
      return res.data;
    }
    return typeof HospitalStore !== 'undefined' ? HospitalStore.saveAppointment(apptData) : apptData;
  },

  async updateAppointmentStatus(id, newStatus) {
    const res = await this.request(`/appointments/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: newStatus })
    });
    if (typeof HospitalStore !== 'undefined') {
      HospitalStore.updateAppointmentStatus(id, newStatus);
    }
    return res?.data || null;
  },

  async cancelAppointment(id) {
    await this.request(`/appointments/${id}`, { method: 'DELETE' });
    if (typeof HospitalStore !== 'undefined') {
      const list = HospitalStore.getAppointments().filter(a => a.id !== id);
      localStorage.setItem(HospitalStore.KEYS.APPOINTMENTS, JSON.stringify(list));
      return list;
    }
    return true;
  },

  // --- Billing API ---
  async getInvoices(status = 'all') {
    const qs = status && status !== 'all' ? `?status=${encodeURIComponent(status)}` : '';
    const res = await this.request(`/billing${qs}`);
    if (res && res.success && Array.isArray(res.data)) {
      if (typeof HospitalStore !== 'undefined' && status === 'all') {
        localStorage.setItem(HospitalStore.KEYS.INVOICES, JSON.stringify(res.data));
      }
      return res.data;
    }
    return typeof HospitalStore !== 'undefined' ? HospitalStore.getInvoices() : [];
  },

  async payInvoice(id, paymentMethod = 'UPI / Online') {
    const res = await this.request(`/billing/${id}`, {
      method: 'PATCH',
      body: JSON.stringify({ paymentMethod })
    });
    if (typeof HospitalStore !== 'undefined') {
      HospitalStore.payInvoice(id);
    }
    return res?.data || null;
  },

  // --- Clinical Treatment / EHR ---
  async getClinicalRecord(patientId) {
    const res = await this.request(`/treatment/${patientId}`);
    if (res && res.success && res.data) {
      return res.data;
    }
    return typeof HospitalStore !== 'undefined' ? HospitalStore.getClinicalRecord(patientId) : null;
  },

  // --- Doctors Directory ---
  async getDoctors(dept = 'all') {
    const qs = dept && dept !== 'all' ? `?dept=${encodeURIComponent(dept)}` : '';
    const res = await this.request(`/doctors${qs}`);
    if (res && res.success && Array.isArray(res.data)) {
      return res.data;
    }
    return null;
  },

  // --- Stats Dashboard ---
  async getDashboardStats() {
    const res = await this.request('/stats/dashboard');
    if (res && res.success && res.stats) {
      return res.stats;
    }
    return null;
  },

  // --- Authentication ---
  async login(email, password) {
    const res = await this.request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
    if (res && res.success && res.token) {
      localStorage.setItem('hospital_jwt_token', res.token);
      if (typeof HospitalStore !== 'undefined') {
        HospitalStore.setSession(res.user);
      }
      return res;
    }
    return null;
  },

  async register(data) {
    const res = await this.request('/auth/register', {
      method: 'POST',
      body: JSON.stringify(data)
    });
    if (res && res.success && res.token) {
      localStorage.setItem('hospital_jwt_token', res.token);
      if (typeof HospitalStore !== 'undefined') {
        HospitalStore.setSession(res.user);
      }
      return res;
    }
    return res;
  },

  async getMe() {
    return await this.request('/auth/me');
  },

  async logout() {
    try {
      await this.request('/auth/logout', { method: 'POST' });
    } catch(e) {}
    localStorage.removeItem('hospital_jwt_token');
    if (typeof HospitalStore !== 'undefined') {
      HospitalStore.clearSession();
    }
  },

  // --- Applications & Inquiries ---
  async submitDoctorApplication(data) {
    return await this.request('/applications/doctor', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  async submitCareerApplication(data) {
    return await this.request('/applications/career', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  async submitContactInquiry(data) {
    return await this.request('/contact', {
      method: 'POST',
      body: JSON.stringify(data)
    });
  },

  // --- Security & Audit Logs (HIPAA § 164.312(b)) ---
  async getAuditLogs() {
    return await this.request('/admin/audit-logs');
  }
};

// Export to global window scope
if (typeof window !== 'undefined') {
  window.ApiClient = ApiClient;
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = ApiClient;
}
