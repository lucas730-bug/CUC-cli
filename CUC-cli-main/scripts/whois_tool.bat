@echo off
setlocal enabledelayedexpansion

:: 1. Establish project directory layouts dynamically
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"
set "RESULTS_DIR=%SCRIPT_DIR%..\results"
set "ERRORS_DIR=%SCRIPT_DIR%..\errors"

:: Force check and allocate database folders so saves never drop execution threads
if not exist "%RESULTS_DIR%" mkdir "%RESULTS_DIR%"
if not exist "%ERRORS_DIR%" mkdir "%ERRORS_DIR%"

:: 2. Format a clean, Windows-safe filename timestamp (YYYYMMDD_HHMMSS)
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "TIMESTAMP=%YYYY%%MM%%DD%_%HH%%Min%%Sec%"

cls
echo ======================================================
echo               🌐 BATCH WHOIS LOOKUP TOOL              
echo ======================================================
echo.
set /p "target=Enter target domain name (e.g., google.com): "
if "%target%"=="" (
    echo [!] No domain entered. Returning to master console menu.
    pause
    exit /b
)

set "FILE_PATH=%RESULTS_DIR%\whois_%target%_%TIMESTAMP%.txt"
set "ERROR_LOG=%ERRORS_DIR%\whois_err_%target%_%TIMESTAMP%.txt"

:: 3. Log basic document header data into the output file while dropping bugs to /errors
(
echo Infrastructure WHOIS Audit Report
echo Target Domain: %target%
echo Timestamp: %YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%
echo ======================================================
echo.
) > "%FILE_PATH%" 2>>"%ERROR_LOG%"

echo.
echo ⏳ Querying registration records for %target% using core net-utils...
echo Errors or connection drops will log silently into your /errors path.
echo ----------------------------------------------------------------------

:: 4. Query standard diagnostic records via standard nslookup pipes
(echo [DNS REGISTRY SUMMARY]) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
for /f "tokens=*" %%A in ('nslookup -type=any %target% 2>>"!ERROR_LOG!" ^| findstr /i /v "Server Address"') do (
    echo   %%A
    (echo   %%A) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
)

:: 5. Extract authoritative Name Servers responsible for the identity footprint
echo.
echo Checking authoritative Name Servers...
(echo. & echo [AUTHORITATIVE NAME SERVERS]) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
for /f "tokens=2 delims==" %%B in ('nslookup -type=ns %target% 2>>"!ERROR_LOG!" ^| findstr /i "nameserver"') do (
    set "ns_val=%%B"
    set "ns_val=!ns_val: =!"
    echo   [+] NS: !ns_val!
    (echo   - Authoritative NS: !ns_val!) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
)

:: 6. Grab raw zone configuration markers
(echo. & echo [START OF AUTHORITY INFO]) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
for /f "tokens=*" %%C in ('nslookup -type=soa %target% 2>>"!ERROR_LOG!" ^| findstr /i /v "Server Address"') do (
    (echo   %%C) >> "%FILE_PATH%" 2>>"%ERROR_LOG%"
)

:: 7. Clean up empty error log files if no runtime anomalies occurred
for %%F in ("%ERROR_LOG%") do if %%~zF==0 del "%%F"

echo.
echo ======================================================
echo 💾 Processing Complete! Data written to results folder.
echo 📂 Saved Path: %FILE_PATH%
echo ======================================================
echo.
pause

:: FIX: Strictly utilize exit /b to pass the terminal context right back to your purple multi-tool panel loop
exit /b


