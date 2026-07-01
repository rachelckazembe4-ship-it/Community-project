@echo off
echo Starting Flutter mobile app...
cd /d "%~dp0mobile_app"
flutter pub get
flutter run
pause
