@echo off
setlocal enabledelayedexpansion

REM Unreal Engine Pipeline Cache Cleaner 100% safe, non-destructive script
REM Usage: CleanUECache.bat [--delete] [--log] [--silent]
REM   --delete : Permanently delete files instead of moving to DELETE_ME
REM   --log    : Enable detailed logging to file
REM   --silent : Don't pause at the end (for automated runs)

echo ========================================
echo Unreal Engine Pipeline Cache Cleaner
echo ========================================
echo.

REM Parse command line arguments
set "DELETE_MODE=0"
set "LOG_MODE=0"
set "SILENT_MODE=0"

:parse_args
if "%~1"=="" goto :done_parsing
if /i "%~1"=="--delete" set "DELETE_MODE=1"
if /i "%~1"=="--log" set "LOG_MODE=1"
if /i "%~1"=="--silent" set "SILENT_MODE=1"
shift
goto :parse_args
:done_parsing

REM Set search directories
set "SEARCH_DIR1=%LOCALAPPDATA%"
set "SEARCH_DIR2=%APPDATA%"

REM Set backup directory with timestamp
set "BACKUP_DIR=%TEMP%\DELETE_ME\UE_PipelineCache_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"

REM Set log file in same directory as script
set "LOG_FILE=%~dp0ue_cache_cleaner.log"

REM Initialize or append to log if logging enabled
if %LOG_MODE%==1 (
    echo [%date% %time%] ======== New Run ======== >> "%LOG_FILE%"
    echo Logging enabled: %LOG_FILE%
    echo.
)

REM Create backup directory if not in delete mode
if %DELETE_MODE%==0 (
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    echo Mode: MOVE files to backup
    echo Backup directory: %BACKUP_DIR%
    if %LOG_MODE%==1 echo [%date% %time%] Backup directory: %BACKUP_DIR% >> "%LOG_FILE%"
) else (
    echo Mode: DELETE files permanently
    if %LOG_MODE%==1 echo [%date% %time%] DELETE MODE: Files will be permanently deleted >> "%LOG_FILE%"
)

echo.
echo Searching for *upipelinecache* files...
echo Search Location 1: %SEARCH_DIR1%
echo Search Location 2: %SEARCH_DIR2%
if %LOG_MODE%==1 (
    echo [%date% %time%] Searching in: %SEARCH_DIR1% >> "%LOG_FILE%"
    echo [%date% %time%] Searching in: %SEARCH_DIR2% >> "%LOG_FILE%"
)
echo.
echo This may take a moment...
echo.

REM Counter for processed files
set COUNT=0

REM Search pattern for any file containing "upipelinecache"
REM This will catch: upipelinecache, .upipelinecache, rec.upipelinecache, etc.

echo --- Searching AppData\Local ---
for /f "delims=" %%F in ('dir /s /b "%SEARCH_DIR1%\*upipelinecache*" 2^>nul ^| findstr /v /i /c:"\\DELETE_ME\\"') do (
    call :process_file "%%F"
)

echo.
echo --- Searching AppData\Roaming ---
for /f "delims=" %%F in ('dir /s /b "%SEARCH_DIR2%\*upipelinecache*" 2^>nul ^| findstr /v /i /c:"\\DELETE_ME\\"') do (
    call :process_file "%%F"
)

echo.
echo ========================================
echo Cleanup complete!
echo Total files processed: %COUNT%
if %DELETE_MODE%==0 (
    if %COUNT% gtr 0 (
        echo Backup location: %BACKUP_DIR%
        echo.
        echo Files have been moved to DELETE_ME folder.
        echo You can inspect or restore them if needed.
    )
)
echo ========================================

if %LOG_MODE%==1 (
    echo [%date% %time%] Total files processed: %COUNT% >> "%LOG_FILE%"
    echo [%date% %time%] ======== Run Complete ======== >> "%LOG_FILE%"
    echo.
    echo Log saved to: %LOG_FILE%
)

echo.
if %SILENT_MODE%==0 (
    echo Press any key to exit...
    pause >nul
)

exit /b 0

:process_file
set "FILEPATH=%~1"
echo Found: %FILEPATH%
if %LOG_MODE%==1 echo [%date% %time%] Found: %FILEPATH% >> "%LOG_FILE%"

if %DELETE_MODE%==1 (
    REM Delete mode
    del /f /q "%FILEPATH%" 2>nul
    if !errorlevel! equ 0 (
        echo [DELETED] %FILEPATH%
        if %LOG_MODE%==1 echo [%date% %time%] [DELETED] %FILEPATH% >> "%LOG_FILE%"
        set /a COUNT+=1
    ) else (
        echo [FAILED] Could not delete %FILEPATH%
        if %LOG_MODE%==1 echo [%date% %time%] [FAILED] Could not delete %FILEPATH% >> "%LOG_FILE%"
    )
) else (
    REM Move mode - extract just the filename from the full path
    for %%A in ("%FILEPATH%") do set "FILENAME=%%~nxA"
    
    REM Create unique filename with timestamp if duplicate
    set "DESTFILE=%BACKUP_DIR%\!FILENAME!"
    if exist "!DESTFILE!" (
        set "DESTFILE=%BACKUP_DIR%\!FILENAME!.%time:~0,2%%time:~3,2%%time:~6,2%"
        set "DESTFILE=!DESTFILE: =0!"
    )
    
    move /y "%FILEPATH%" "!DESTFILE!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [MOVED] %FILEPATH%
        echo    --^> !DESTFILE!
        if %LOG_MODE%==1 (
            echo [%date% %time%] [MOVED] %FILEPATH% >> "%LOG_FILE%"
            echo [%date% %time%]    --^> !DESTFILE! >> "%LOG_FILE%"
        )
        set /a COUNT+=1
    ) else (
        echo [FAILED] Could not move %FILEPATH%
        if %LOG_MODE%==1 echo [%date% %time%] [FAILED] Could not move %FILEPATH% >> "%LOG_FILE%"
    )
)
echo.
goto :eof