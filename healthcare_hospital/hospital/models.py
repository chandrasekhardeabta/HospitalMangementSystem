import uuid
from django.contrib.auth.models import User
from django.db import models


class PatientProfile(models.Model):
    GENDER_CHOICES = [
        ("Male", "Male"),
        ("Female", "Female"),
        ("Other", "Other"),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="patient_profile")
    patient_id = models.CharField(max_length=30, unique=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=20, choices=GENDER_CHOICES, blank=True)
    blood_group = models.CharField(max_length=5, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    address = models.TextField(blank=True)
    emergency_contact = models.CharField(max_length=30, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.patient_id:
            self.patient_id = f"PAT-{self.created_at.year if self.created_at else 2026}-{uuid.uuid4().hex[:5].upper()}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.patient_id} - {self.user.get_full_name() or self.user.username}"


class Department(models.Model):
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True)
    icon = models.CharField(max_length=50, default="bi-heart-pulse")

    class Meta:
        ordering = ["name"]

    def __str__(self):
        return self.name


class DoctorProfile(models.Model):
    STATUS_CHOICES = [
        ("Submitted", "Submitted"),
        ("Under Review", "Under Review"),
        ("Interview", "Interview"),
        ("Approved", "Approved"),
        ("Rejected", "Rejected"),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="doctor_profile", null=True, blank=True)
    full_name = models.CharField(max_length=150)
    email = models.EmailField()
    mobile = models.CharField(max_length=20)
    medical_registration_number = models.CharField(max_length=100)
    qualification = models.CharField(max_length=200)
    specialization = models.CharField(max_length=150)
    experience = models.PositiveIntegerField(default=0)
    previous_hospital = models.CharField(max_length=200, blank=True)
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True, blank=True)
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    availability = models.CharField(max_length=255, blank=True)
    bio = models.TextField(blank=True)
    photo = models.ImageField(upload_to="doctors/", blank=True, null=True)
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default="Submitted")
    rating = models.DecimalField(max_digits=3, decimal_places=1, default=4.8)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.full_name


class Appointment(models.Model):
    STATUS_CHOICES = [
        ("Pending", "Pending"),
        ("Confirmed", "Confirmed"),
        ("Completed", "Completed"),
        ("Cancelled", "Cancelled"),
        ("No-Show", "No-Show"),
    ]
    TYPE_CHOICES = [
        ("OPD", "OPD Consultation"),
        ("Follow-up", "Follow-up"),
        ("Telemedicine", "Telemedicine"),
    ]

    appointment_id = models.CharField(max_length=30, unique=True, blank=True)
    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name="appointments")
    doctor = models.ForeignKey(DoctorProfile, on_delete=models.SET_NULL, null=True, related_name="appointments")
    department = models.ForeignKey(Department, on_delete=models.SET_NULL, null=True)
    date = models.DateField()
    time = models.TimeField()
    appointment_type = models.CharField(max_length=30, choices=TYPE_CHOICES, default="OPD")
    symptoms = models.TextField(blank=True)
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default="Pending")
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.appointment_id:
            self.appointment_id = f"APT-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)

    def __str__(self):
        return self.appointment_id


class Ticket(models.Model):
    CATEGORY_CHOICES = [
        ("Appointment Problem", "Appointment Problem"),
        ("Billing Problem", "Billing Problem"),
        ("Medical Report", "Medical Report"),
        ("Pharmacy", "Pharmacy"),
        ("Doctor", "Doctor"),
        ("Technical Problem", "Technical Problem"),
        ("General Query", "General Query"),
    ]
    PRIORITY_CHOICES = [
        ("Low", "Low"),
        ("Medium", "Medium"),
        ("High", "High"),
    ]
    STATUS_CHOICES = [
        ("Open", "Open"),
        ("In Progress", "In Progress"),
        ("Waiting for Patient", "Waiting for Patient"),
        ("Resolved", "Resolved"),
        ("Closed", "Closed"),
    ]

    ticket_id = models.CharField(max_length=30, unique=True, blank=True)
    patient = models.ForeignKey(PatientProfile, on_delete=models.CASCADE, related_name="tickets")
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    subject = models.CharField(max_length=200)
    description = models.TextField()
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default="Medium")
    status = models.CharField(max_length=30, choices=STATUS_CHOICES, default="Open")
    attachment = models.FileField(upload_to="tickets/", blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.ticket_id:
            self.ticket_id = f"TKT-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)

    def __str__(self):
        return self.ticket_id
