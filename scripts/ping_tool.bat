@echo off
set /p target="Enter IP or Website to ping: "
echo Running throw ping to %target%...

:: Define the target results folder one level up from the script
set "output_dir=%~dp0..\results"

:: Create the results folder if it doesn't exist yet
if not exist "%output_dir%" mkdir "%output_dir%"

:: Extract safe numbers from date and time (removes slashes, colons, and spaces)
set "safe_date=%date:/=-%"
set "safe_time=%time::=-%"
set "safe_time=%safe_time: =0%"

:: Define a clean file path
set "logfile=%output_dir%\ping_%target%_at_%safe_date%_%safe_time%.txt"

:: Run the single ping and save it inside the new folder
ping -n 1 %target% >> "%logfile%"

:: Open the newly created text file
start "" "%logfile%"
pause