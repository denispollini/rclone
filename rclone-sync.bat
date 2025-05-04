@echo off
SETLOCAL EnableDelayedExpansion
:: Source and destination configuration
set "SOURCE=C:\Users\Denis\My Drive"
set "LOG_DIR=logs"
set "DROPBOX_REMOTE=dropbox"
set "KDRIVE_REMOTE=kdrive"
set "BACKUP_FOLDER_NAME=BackupDrive"
:: Use rclone from current directory
set "RCLONE=rclone.exe"
:: Exclusion options for rclone
set "EXCLUDE_OPTIONS=--exclude=desktop.ini --exclude=.DS_Store --exclude=Thumbs.db --exclude=**/.*"
:: Variable to track errors
set "ERROR_OCCURRED=0"
:: Create log folder if it doesn't exist
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
:: Create log filename with date and time (format YYYYMMDD_HHMM)
set "LOG_DATE=%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%"
:: Remove any spaces in time format
set "LOG_DATE=%LOG_DATE: =0%"
set "LOG_FILE=%LOG_DIR%\sync_error_%LOG_DATE%.log"
echo Starting synchronization from "%SOURCE%" to cloud services...
echo Excluded files: desktop.ini, .DS_Store, Thumbs.db, hidden files (.*) 
:: Sync with Dropbox
echo Syncing with Dropbox in progress...
%RCLONE% sync "%SOURCE%" %DROPBOX_REMOTE%:%BACKUP_FOLDER_NAME% --progress %EXCLUDE_OPTIONS%
if %ERRORLEVEL% neq 0 (
    if %ERROR_OCCURRED%==0 (
        echo ===== SYNCHRONIZATION ERROR REPORT %date% %time% ===== > "%LOG_FILE%"
    )
    echo [%time%] ERROR during Dropbox synchronization >> "%LOG_FILE%"
    echo [%time%] Source: "%SOURCE%" >> "%LOG_FILE%"
    echo [%time%] Destination: %DROPBOX_REMOTE%:%BACKUP_FOLDER_NAME% >> "%LOG_FILE%"
    echo. >> "%LOG_FILE%"
    set "ERROR_OCCURRED=1"
) else (
    echo Dropbox synchronization completed successfully.
)
:: Sync with KDrive
::echo Syncing with KDrive in progress...
::%RCLONE% sync "%SOURCE%" %KDRIVE_REMOTE%:%BACKUP_FOLDER_NAME% --progress %EXCLUDE_OPTIONS%
::if %ERRORLEVEL% neq 0 (
::    if %ERROR_OCCURRED%==0 (
::        echo ===== SYNCHRONIZATION ERROR REPORT %date% %time% ===== > "%LOG_FILE%"
::    )
::    echo [%time%] ERROR during KDrive synchronization >> "%LOG_FILE%"
::    echo [%time%] Source: "%SOURCE%" >> "%LOG_FILE%"
::    echo [%time%] Destination: %KDRIVE_REMOTE%:%BACKUP_FOLDER_NAME% >> "%LOG_FILE%"
::    echo. >> "%LOG_FILE%"
::    set "ERROR_OCCURRED=1"
::) else (
::    echo KDrive synchronization completed successfully.
::)
:: Show final notification
if %ERROR_OCCURRED%==1 (
    echo Errors occurred during synchronization. Check "%LOG_FILE%"
    msg * "Synchronization completed with ERRORS. Check the log: %LOG_FILE%"
) else (
    echo All synchronizations completed successfully.
    msg * "Synchronization completed SUCCESSFULLY!"
)
:: Pause at the end of execution (optional)
echo.
echo Press any key to close this window...
pause >nul
@echo on