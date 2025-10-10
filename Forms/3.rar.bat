@echo off
:: Get date/time via PowerShell (WMIC not needed)
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set "DATE=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format HHmmss"') do set "TIME=%%i"
set "TIMESTAMP=%DATE%_%TIME%"

:: Set base directory and folder name
set "BASE_DIR=D:\Oracle_database_backup\finance-soft-"
set "FOLDER_NAME=Backup%DATE%"
set "BACKUP_FOLDER=%BASE_DIR%\%FOLDER_NAME%"
set "OUTPUT_FILE=%BASE_DIR%\%FOLDER_NAME%.rar"

:: Path to WinRAR or 7-Zip (adjust accordingly)
set "RAR_PATH=C:\Program Files\WinRAR\rar.exe"

:: Ensure backup folder exists before compressing
if not exist "%BACKUP_FOLDER%" (
  echo [ERROR] Backup folder not found: "%BACKUP_FOLDER%"
  pause
  exit /b 1
)

:: Compress the folder to a .rar file
"%RAR_PATH%" a -r "%OUTPUT_FILE%" "%BACKUP_FOLDER%"

:: Check if the .rar file was created successfully
if exist "%OUTPUT_FILE%" (
    echo Compression successful: %OUTPUT_FILE%
    echo Deleting folder: %BACKUP_FOLDER%
    rmdir /s /q "%BACKUP_FOLDER%"
    if not exist "%BACKUP_FOLDER%" (
        echo Folder deleted successfully.
        cd /d "D:\Oracle_database_backup\finance-soft-"
        git add *
        git commit -m "Backup %TIMESTAMP%"
        git push
        echo Git push completed.
    ) else (
        echo Failed to delete folder: %BACKUP_FOLDER%
    )
) else (
    echo Compression failed. Folder not deleted.
)

