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

:MENU
cls
echo ======================================================
echo               🌐 BATCH IP CHECK TOOL                  
echo ======================================================
echo  [1] Check My Own System IP Config
echo  [2] Check a Specific Target IP / Domain
echo  [3] Exit
echo ======================================================
echo.
set /p "choice=Select an option (1-3): "

if "%choice%"=="1" goto MY_IP
if "%choice%"=="2" goto TARGET_IP
if "%choice%"=="3" exit
goto MENU

:MY_IP
cls
set "FILE_PATH=%RESULTS_DIR%\ipcheck_localhost_%TIMESTAMP%.txt"
echo Running system network audit...
echo.

(
echo Local System IP Check Audit Report
echo Timestamp: %YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%
echo ======================================================
echo.
) > "%FILE_PATH%"

(echo [LOCAL NETWORK ADAPTERS]) >> "%FILE_PATH%"
for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "IPv4"') do (
    set "local_ip=%%A"
    set "local_ip=!local_ip: =!"
    echo   [+] Found Internal IP: !local_ip!
    (echo   - Internal IPv4 Address : !local_ip!) >> "%FILE_PATH%"
)

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| findstr /i "Default Gateway" ^| findstr /r "[0-9]"') do (
    set "gateway_ip=%%A"
    set "gateway_ip=!gateway_ip: =!"
    echo   [+] Found Gateway Route: !gateway_ip!
    (echo   - Default Gateway Route : !gateway_ip!) >> "%FILE_PATH%"
)
(echo.) >> "%FILE_PATH%"

(echo [PUBLIC INTERNET FOOTPRINT]) >> "%FILE_PATH%"
set "public_ip=Unknown"
for /f "delims=" %%B in ('curl -s https://ipify.org 2^>nul') do set "public_ip=%%B"
echo   [+] External Public WAN: %public_ip%
(echo   - External WAN IP Address: %public_ip%) >> "%FILE_PATH%"
goto FINISH

:TARGET_IP
cls
echo ======================================================
echo            🔍 EXTERNAL TARGET IP AUDIT                
echo ======================================================
echo.
set /p "target=Enter the Target IP Address or Domain: "
if "%target%"=="" goto TARGET_IP

:: Adjust file name safely for targets
set "FILE_PATH=%RESULTS_DIR%\ipcheck_%target%_%TIMESTAMP%.txt"

echo.
echo Querying network profile and geographic tracking data for: %target%...
echo.

(
echo Target IP / Domain Check Audit Report
echo Target: %target%
echo Timestamp: %YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%
echo ======================================================
echo.
) > "%FILE_PATH%"

:: Run curl against an unformatted geo lookup API
(echo [GEOGRAPHIC AND ISP DETAILS]) >> "%FILE_PATH%"
for /f "delims=" %%C in ('curl -s https://ipapi.co 2^>nul') do (
    echo   %%C
    (echo   %%C) >> "%FILE_PATH%"
)
goto FINISH

:FINISH
echo.
echo ======================================================
echo 💾 Processing Complete! Data written to results folder.
echo 📂 Saved Path: %FILE_PATH%
echo ======================================================
echo.
pause
goto MENU


