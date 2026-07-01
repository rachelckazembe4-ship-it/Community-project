@echo off
echo Starting Django backend server...
cd /d "%~dp0backend"
python manage.py runserver
pause
