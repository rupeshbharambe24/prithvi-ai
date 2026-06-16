@echo off
REM ============================================================
REM  PRITHVI-AI - full weekly pipeline (run every Friday 11 PM)
REM  Double-click this file, or run it from a terminal.
REM ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_weekly.ps1"
echo.
pause
