from django import forms
from django.contrib.auth.models import User
from .models import Appointment, Department, DoctorProfile, PatientProfile, Ticket


class PatientRegistrationForm(forms.Form):
    full_name = forms.CharField(max_length=150)
    email = forms.EmailField()
    date_of_birth = forms.DateField(required=False, widget=forms.DateInput(attrs={"type": "date"}))
    gender = forms.ChoiceField(choices=[("", "Select gender")] + PatientProfile.GENDER_CHOICES, required=False)
    blood_group = forms.CharField(max_length=5, required=False)
    phone = forms.CharField(max_length=20)
    address = forms.CharField(widget=forms.Textarea(attrs={"rows": 3}))
    emergency_contact = forms.CharField(max_length=30, required=False)
    password = forms.CharField(widget=forms.PasswordInput)
    confirm_password = forms.CharField(widget=forms.PasswordInput)

    def clean_email(self):
        email = self.cleaned_data["email"].lower()
        if User.objects.filter(username=email).exists():
            raise forms.ValidationError("An account with this email already exists.")
        return email

    def clean(self):
        cleaned = super().clean()
        if cleaned.get("password") and cleaned.get("confirm_password") and cleaned["password"] != cleaned["confirm_password"]:
            self.add_error("confirm_password", "Passwords do not match.")
        return cleaned


class PatientLoginForm(forms.Form):
    identifier = forms.CharField(label="Patient ID / Email / Mobile")
    password = forms.CharField(widget=forms.PasswordInput)


class AppointmentForm(forms.ModelForm):
    class Meta:
        model = Appointment
        fields = ["department", "doctor", "date", "time", "appointment_type", "symptoms"]
        widgets = {
            "date": forms.DateInput(attrs={"type": "date"}),
            "time": forms.TimeInput(attrs={"type": "time"}),
            "symptoms": forms.Textarea(attrs={"rows": 4, "placeholder": "Briefly describe your symptoms"}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["department"].queryset = Department.objects.all()
        self.fields["doctor"].queryset = DoctorProfile.objects.filter(status="Approved")


class DoctorApplicationForm(forms.ModelForm):
    class Meta:
        model = DoctorProfile
        fields = [
            "full_name", "email", "mobile", "medical_registration_number",
            "qualification", "specialization", "experience", "previous_hospital",
            "department", "consultation_fee", "availability", "photo"
        ]
        widgets = {
            "availability": forms.TextInput(attrs={"placeholder": "Mon-Fri, 10:00 AM - 4:00 PM"}),
        }


class TicketForm(forms.ModelForm):
    class Meta:
        model = Ticket
        fields = ["category", "subject", "description", "priority", "attachment"]
        widgets = {
            "description": forms.Textarea(attrs={"rows": 5}),
        }
