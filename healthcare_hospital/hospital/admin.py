from django.contrib import admin
from .models import Appointment, Department, DoctorProfile, PatientProfile, Ticket

@admin.register(PatientProfile)
class PatientProfileAdmin(admin.ModelAdmin):
    list_display = ("patient_id", "user", "phone", "blood_group", "created_at")
    search_fields = ("patient_id", "user__username", "user__first_name", "phone")

@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ("name",)
    search_fields = ("name",)

@admin.register(DoctorProfile)
class DoctorProfileAdmin(admin.ModelAdmin):
    list_display = ("full_name", "specialization", "department", "experience", "status", "rating")
    list_filter = ("status", "department", "specialization")
    search_fields = ("full_name", "email", "medical_registration_number")

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ("appointment_id", "patient", "doctor", "date", "time", "status")
    list_filter = ("status", "appointment_type", "department", "date")
    search_fields = ("appointment_id", "patient__patient_id", "doctor__full_name")

@admin.register(Ticket)
class TicketAdmin(admin.ModelAdmin):
    list_display = ("ticket_id", "patient", "category", "priority", "status", "created_at")
    list_filter = ("category", "priority", "status")
    search_fields = ("ticket_id", "subject", "patient__patient_id")
