@echo off
setlocal enabledelayedexpansion

:: 1. Establish project directory layouts dynamically
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "RESULTS_DIR=%SCRIPT_DIR%..\results"

:: Force create results directory if it doesn't exist yet
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"

:: 2. Format a clean, Windows-safe filename timestamp (YYYYMMDD_HHMMSS)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "TIMESTAMP=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

:: 3. Prompt user for target domain
cls
echo ======================================================
echo             🌐 BATCH SUBDOMAIN SCANNER                
echo ======================================================
echo.
set /p "target_domain=Enter the base domain (e.g., google.com): "
if "%target_domain%"=="" (
    echo No domain entered. Exiting.
    pause
    exit /b
)

set "FILE_PATH=%RESULTS_DIR%\subdomain_%target_domain%_%TIMESTAMP%.txt"

:: 4. Write report header to file
(
echo Subdomain Verification Results
echo Target Domain: %target_domain%
echo Timestamp: %YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%
echo ======================================================
echo.
) > "%FILE_PATH%"

echo.
echo 🔍 Verifying deployment subdomains for: %target_domain%...
echo This will check standard prefixes in the background...
echo.

:: 5. Define a robust list of common web infrastructure subdomains
set "subdomains=www mail dev blog api staging test shop secure vpn app status docs portal beta internal news cloud proxy ftp ns"

:: 6. Loop through prefixes and verify resolution
for %%S in (%subdomains%) do (
    set "full_host=%%S.%target_domain%"
    
    :: Use nslookup to query the hostname, filtering out default loopback errors
    set "resolved_ip="
    for /f "tokens=2 delims=:" %%A in ('nslookup !full_host! 2^>nul ^| findstr /i "Address:"') do (
        set "temp_ip=%%A"
        set "temp_ip=!temp_ip: =!"
        :: Ignore standard DNS resolver status responses
        if not "!temp_ip!"=="" if not "!temp_ip:~0,3!"=="127" if not "!temp_ip:~0,4!"=="192." (
            set "resolved_ip=!temp_ip!"
        )
    )
    
    :: If an external IP configuration was found, record it permanently
    if not "!resolved_ip!"=="" (
        set "log_line=✅ Active: !full_host! -> !resolved_ip!"
        echo !log_line!
        (echo !log_line!) >> "%FILE_PATH%"
    )
)

echo.
echo ======================================================
echo 💾 Scan Complete! All found entries are permanently kept.
echo 📂 Saved Path: %FILE_PATH%
echo ======================================================
echo.
pause
