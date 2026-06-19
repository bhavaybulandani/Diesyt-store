@echo off
echo Starting DIESYT Admin Server...
start "" "http://localhost:8080"
powershell -ExecutionPolicy Bypass -File "%~dp0admin\admin_server.ps1"
pause
