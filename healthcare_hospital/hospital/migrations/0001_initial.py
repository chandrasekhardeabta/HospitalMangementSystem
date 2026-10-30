from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import uuid


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Department",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("name", models.CharField(max_length=100, unique=True)),
                ("description", models.TextField(blank=True)),
                ("icon", models.CharField(default="bi-heart-pulse", max_length=50)),
            ],
            options={"ordering": ["name"]},
        ),
        migrations.CreateModel(
            name="PatientProfile",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("patient_id", models.CharField(blank=True, max_length=30, unique=True)),
                ("date_of_birth", models.DateField(blank=True, null=True)),
                ("gender", models.CharField(blank=True, choices=[("Male", "Male"), ("Female", "Female"), ("Other", "Other")], max_length=20)),
                ("blood_group", models.CharField(blank=True, max_length=5)),
                ("phone", models.CharField(blank=True, max_length=20)),
                ("address", models.TextField(blank=True)),
                ("emergency_contact", models.CharField(blank=True, max_length=30)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("user", models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name="patient_profile", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="DoctorProfile",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("full_name", models.CharField(max_length=150)),
                ("email", models.EmailField(max_length=254)),
                ("mobile", models.CharField(max_length=20)),
                ("medical_registration_number", models.CharField(max_length=100)),
                ("qualification", models.CharField(max_length=200)),
                ("specialization", models.CharField(max_length=150)),
                ("experience", models.PositiveIntegerField(default=0)),
                ("previous_hospital", models.CharField(blank=True, max_length=200)),
                ("consultation_fee", models.DecimalField(decimal_places=2, default=0, max_digits=10)),
                ("availability", models.CharField(blank=True, max_length=255)),
                ("bio", models.TextField(blank=True)),
                ("photo", models.ImageField(blank=True, null=True, upload_to="doctors/")),
                ("status", models.CharField(choices=[("Submitted", "Submitted"), ("Under Review", "Under Review"), ("Interview", "Interview"), ("Approved", "Approved"), ("Rejected", "Rejected")], default="Submitted", max_length=30)),
                ("rating", models.DecimalField(decimal_places=1, default=4.8, max_digits=3)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("department", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to="hospital.department")),
                ("user", models.OneToOneField(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, related_name="doctor_profile", to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name="Appointment",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("appointment_id", models.CharField(blank=True, max_length=30, unique=True)),
                ("date", models.DateField()),
                ("time", models.TimeField()),
                ("appointment_type", models.CharField(choices=[("OPD", "OPD Consultation"), ("Follow-up", "Follow-up"), ("Telemedicine", "Telemedicine")], default="OPD", max_length=30)),
                ("symptoms", models.TextField(blank=True)),
                ("status", models.CharField(choices=[("Pending", "Pending"), ("Confirmed", "Confirmed"), ("Completed", "Completed"), ("Cancelled", "Cancelled"), ("No-Show", "No-Show")], default="Pending", max_length=30)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("department", models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to="hospital.department")),
                ("doctor", models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="appointments", to="hospital.doctorprofile")),
                ("patient", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="appointments", to="hospital.patientprofile")),
            ],
        ),
        migrations.CreateModel(
            name="Ticket",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("ticket_id", models.CharField(blank=True, max_length=30, unique=True)),
                ("category", models.CharField(choices=[("Appointment Problem", "Appointment Problem"), ("Billing Problem", "Billing Problem"), ("Medical Report", "Medical Report"), ("Pharmacy", "Pharmacy"), ("Doctor", "Doctor"), ("Technical Problem", "Technical Problem"), ("General Query", "General Query")], max_length=50)),
                ("subject", models.CharField(max_length=200)),
                ("description", models.TextField()),
                ("priority", models.CharField(choices=[("Low", "Low"), ("Medium", "Medium"), ("High", "High")], default="Medium", max_length=20)),
                ("status", models.CharField(choices=[("Open", "Open"), ("In Progress", "In Progress"), ("Waiting for Patient", "Waiting for Patient"), ("Resolved", "Resolved"), ("Closed", "Closed")], default="Open", max_length=30)),
                ("attachment", models.FileField(blank=True, null=True, upload_to="tickets/")),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("patient", models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name="tickets", to="hospital.patientprofile")),
            ],
        ),
    ]
