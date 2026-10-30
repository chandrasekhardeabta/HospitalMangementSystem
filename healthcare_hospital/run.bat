@echo off
title HealthCare Hospital - Unified Django & Frontend Platform
cd /d "%~dp0"
echo ===============================================================
echo  HealthCare Hospital - Unified Django & Modern Frontend
echo  Website & REST API:      http://127.0.0.1:8001
echo  Diagnostics Check:       http://127.0.0.1:8001/api/debug-env
echo  Django Admin Console:    http://127.0.0.1:8001/admin/
echo ===============================================================
timeout /t 1 /nobreak >nul
start http://127.0.0.1:8001
python manage.py runserver 8001
pause
