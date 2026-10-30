# HealthCare Hospital — Django Hospital Management System

A clean, responsive Hospital Management System starter built with:

- Python 3.8+
- Django 4.2 LTS
- SQLite for local development
- Bootstrap 5.3
- Bootstrap Icons
- Custom CSS + JavaScript
- Django ORM, forms, authentication and admin

## Project structure

```
healthcare_hospital/
├── manage.py
├── requirements.txt
├── healthcare/
│   ├── settings.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── hospital/
│   ├── admin.py
│   ├── apps.py
│   ├── forms.py
│   ├── models.py
│   ├── urls.py
│   ├── views.py
│   └── migrations/
├── templates/
│   ├── base.html
│   ├── home.html
│   ├── pages/
│   ├── patient/
│   └── doctor/
└── static/
    ├── css/style.css
    └── js/main.js
```

## Run locally

### Windows / Python 3.8

```bat
py -3.8 -m venv env
env\Scriptsctivate
python -m pip install --upgrade pip
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

Open `http://127.0.0.1:8000/`.

Admin: `http://127.0.0.1:8000/admin/`

## Main routes

- `/` — Home
- `/about/` — About
- `/services/` — Services
- `/departments/` — Departments
- `/doctors/` — Doctors
- `/appointments/` — Appointment booking
- `/patient/register/` — Patient registration
- `/patient/login/` — Patient login
- `/patient/dashboard/` — Patient dashboard
- `/doctor/apply/` — Doctor application
- `/doctor/login/` — Doctor login
- `/doctor/dashboard/` — Doctor dashboard
- `/support/` — Support ticket
- `/admin/` — Django admin

## Customisation

The visual system is intentionally centralised in `static/css/style.css`.
Change the CSS variables at the top of that file to rebrand the portal.

The navigation is in `templates/base.html`.
Home page sections are in `templates/home.html`.
Business logic is in `hospital/views.py`, database structure in `hospital/models.py`,
and forms in `hospital/forms.py`.

This is a production-oriented starter, not a finished clinical system. Before real deployment,
add proper permissions, audit logs, secure document storage, backups, email/SMS/OTP providers,
payment gateway integration, and privacy/security controls appropriate to your jurisdiction.
