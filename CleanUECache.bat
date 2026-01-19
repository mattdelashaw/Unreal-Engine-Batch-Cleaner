@echo off
setlocal enabledelayedexpansion

REM Unreal Engine Pipeline Cache Cleaner
REM Usage: CleanUECache.bat [--delete] [--log]
REM   --delete : Permanently delete files instead of moving to DELETE_ME
REM   --log    : Enable detailed logging to file

echo ========================================
echo Unreal Engine Pipeline Cache Cleaner
echo ========================================
echo.

REM Parse command line arguments
set "DELETE_MODE=0"
set "LOG_MODE=0"

:parse_args
if "%~1"=="" goto :done_parsing
if /i "%~1"=="--delete" set "DELETE_MODE=1"
if /i "%~1"=="--log" set "LOG_MODE=1"
shift
goto :parse_args
:done_parsing

REM Set the base directory to search
set "SEARCH_DIR=%LOCALAPPDATA%"

REM Set backup directory
set "BACKUP_DIR=%TEMP%\DELETE_ME\UE_PipelineCache_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "BACKUP_DIR=%BACKUP_DIR: =0%"

REM Set log file
set "LOG_FILE=%~dp0ue_cache_cleaner.log"

REM Create backup directory if not in delete mode
if %DELETE_MODE%==0 (
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    echo Backup directory: %BACKUP_DIR%
    if %LOG_MODE%==1 echo [%date% %time%] Backup directory: %BACKUP_DIR% >> "%LOG_FILE%"
) else (
    echo DELETE MODE: Files will be permanently deleted
    if %LOG_MODE%==1 echo [%date% %time%] DELETE MODE: Files will be permanently deleted >> "%LOG_FILE%"
)

if %LOG_MODE%==1 (
    echo Logging enabled: %LOG_FILE%
    echo [%date% %time%] ======== New Run ======== >> "%LOG_FILE%"
)

echo.
echo Searching for upipelinecache files in: %SEARCH_DIR%
if %LOG_MODE%==1 echo [%date% %time%] Searching in: %SEARCH_DIR% >> "%LOG_FILE%"
echo.

REM Counter for processed files
set COUNT=0

REM Find and process all upipelinecache files
for /f "delims=" %%F in ('dir /s /b "%SEARCH_DIR%\upipelinecache" 2^>nul') do (
    echo Found: %%F
    if %LOG_MODE%==1 echo [%date% %time%] Found: %%F >> "%LOG_FILE%"
    
    if %DELETE_MODE%==1 (
        REM Delete mode
        del /f /q "%%F" 2>nul
        if !errorlevel! equ 0 (
            echo [DELETED] %%F
            if %LOG_MODE%==1 echo [%date% %time%] [DELETED] %%F >> "%LOG_FILE%"
            set /a COUNT+=1
        ) else (
            echo [FAILED] Could not delete %%F
            if %LOG_MODE%==1 echo [%date% %time%] [FAILED] Could not delete %%F >> "%LOG_FILE%"
        )
    ) else (
        REM Move mode
        move /y "%%F" "%BACKUP_DIR%\" >nul 2>&1
        if !errorlevel! equ 0 (
            echo [MOVED] %%F
            if %LOG_MODE%==1 echo [%date% %time%] [MOVED] %%F >> "%LOG_FILE%"
            set /a COUNT+=1
        ) else (
            echo [FAILED] Could not move %%F
            if %LOG_MODE%==1 echo [%date% %time%] [FAILED] Could not move %%F >> "%LOG_FILE%"
        )
    )
    echo.
)

echo ========================================
echo Cleanup complete!
echo Total files processed: %COUNT%
if %DELETE_MODE%==0 echo Backup location: %BACKUP_DIR%
echo ========================================
if %LOG_MODE%==1 (
    echo [%date% %time%] Total files processed: %COUNT% >> "%LOG_FILE%"
    echo [%date% %time%] ======== Run Complete ======== >> "%LOG_FILE%"
    echo.
    echo Log saved to: %LOG_FILE%
)
echo.

REM Optional: Uncomment to keep window open
REM pause

exit /b 0