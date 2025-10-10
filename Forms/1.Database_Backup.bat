@echo off
setlocal enableextensions

:: --- Oracle paths ---
set "ORACLE_HOME=E:\WINDOWS.X64_193000_db_home"
set "PATH=%ORACLE_HOME%\bin;%PATH%"

:: --- DB connect ---
set "DB_USER=erp"
set "DB_PASS=Asdbnm123"
set "DB_SVC=erp"   :: TNS service name or EZCONNECT host/service

:: --- Base backup folder (keep quotes; avoid trailing space) ---
set "BASE_BACKUP_DIR=E:\Oracle\Forms"

:: --- Get yyyymmdd without WMIC (use PowerShell) ---
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "DATE=%%i"

:: --- Build dated folder ---
set "BACKUP_DIR=%BASE_BACKUP_DIR%\Backup%DATE%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: --- File names (quote everything with spaces) ---
set "DUMP_FILE=%BACKUP_DIR%\backup_%DATE%.dmp"
set "LOG_FILE=%BACKUP_DIR%\backup_%DATE%.log"

echo Backing up to: "%DUMP_FILE%"

:: --- Export (classic EXP) ---
:: NOTE: quote FILE= and LOG= values to avoid LRM-00112
"%ORACLE_HOME%\bin\exp.exe" %DB_USER%/%DB_PASS%@%DB_SVC% OWNER=%DB_USER% FILE="%DUMP_FILE%" LOG="%LOG_FILE%"
if errorlevel 1 (
  echo [ERROR] EXP failed. Check "%LOG_FILE%".
  goto :end
)

:: --- Optional: delete dated subfolders older than 7 days ---
:: (use PowerShell for robust directory pruning)
powershell -NoProfile -Command ^
  "Get-ChildItem -Path '%BASE_BACKUP_DIR%' -Directory | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-7)} | Remove-Item -Recurse -Force"

echo Backup completed successfully.
:end

pause