from django.core.management.base import BaseCommand
from hospital.models import Department, DoctorProfile


class Command(BaseCommand):
    help = "Create demo departments and approved doctors."

    def handle(self, *args, **options):
        departments = [
            ("Cardiology", "Heart and cardiovascular care.", "bi-heart-pulse"),
            ("Neurology", "Brain, spine and nervous system care.", "bi-activity"),
            ("Orthopedics", "Bone, joint and mobility care.", "bi-person-walking"),
            ("General Medicine", "Primary and internal medicine.", "bi-clipboard2-pulse"),
            ("Pediatrics", "Specialised care for children.", "bi-balloon"),
            ("Gynecology", "Women's health and maternity care.", "bi-gender-female"),
            ("Dermatology", "Skin, hair and nail care.", "bi-person"),
            ("Radiology", "Imaging and diagnostic services.", "bi-camera"),
        ]
        for name, description, icon in departments:
            Department.objects.get_or_create(name=name, defaults={"description": description, "icon": icon})

        cardiology = Department.objects.get(name="Cardiology")
        neurology = Department.objects.get(name="Neurology")

        DoctorProfile.objects.get_or_create(
            email="rahul@healthcare.com",
            defaults={
                "full_name": "Dr. Rahul Sharma",
                "mobile": "+91 90000 00001",
                "medical_registration_number": "MED-DEMO-001",
                "qualification": "MBBS, MD Cardiology",
                "specialization": "Cardiology",
                "experience": 8,
                "department": cardiology,
                "consultation_fee": 800,
                "availability": "Mon-Fri, 10:00 AM - 4:00 PM",
                "status": "Approved",
                "bio": "Senior cardiology consultant.",
            },
        )
        DoctorProfile.objects.get_or_create(
            email="anita@healthcare.com",
            defaults={
                "full_name": "Dr. Anita Das",
                "mobile": "+91 90000 00002",
                "medical_registration_number": "MED-DEMO-002",
                "qualification": "MBBS, DM Neurology",
                "specialization": "Neurology",
                "experience": 10,
                "department": neurology,
                "consultation_fee": 1000,
                "availability": "Mon-Sat, 11:00 AM - 5:00 PM",
                "status": "Approved",
                "bio": "Consultant neurologist.",
            },
        )
        self.stdout.write(self.style.SUCCESS("Demo data created."))
