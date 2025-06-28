@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

echo 🚀 WSL Disk Shrink Tool
echo ========================

:: Check if sudo is available
where sudo >nul 2>&1
if %errorlevel% neq 0 (
    echo ⛔ Windows sudo not found
    pause
    exit /b 1
)

:: Find all WSL distributions and their disk paths
echo 🔎 Available WSL distributions:
echo.

set COUNT=0
set WSL_LIST=

:: Check C:\wsl\ directory structure
if exist "C:\wsl\" (
    for /d %%d in ("C:\wsl\*") do (
        if exist "%%d\ext4.vhdx" (
            set /a COUNT+=1
            set WSL_NAME=%%~nd
            set WSL_PATH=%%d
            set WSL_LIST[!COUNT!]=!WSL_NAME!
            set WSL_PATH[!COUNT!]=!WSL_PATH!
            echo !COUNT!. 📁 !WSL_NAME!
        )
    )
)

if %COUNT% equ 0 (
    echo ⛔ No WSL distributions found
    pause
    exit /b 1
)

:: User selection
echo.
set /p CHOICE="🎮 Select WSL (1-%COUNT%): "

:: Validate choice
if "%CHOICE%"=="" goto :invalid_choice
if %CHOICE% lss 1 goto :invalid_choice
if %CHOICE% gtr %COUNT% goto :invalid_choice

set SELECTED_WSL=!WSL_LIST[%CHOICE%]!
set SELECTED_PATH=!WSL_PATH[%CHOICE%]!
set DISK_FILE=%SELECTED_PATH%\ext4.vhdx

:: Verify disk file exists
if not exist "%DISK_FILE%" (
    echo ⛔ Disk file not found
    pause
    exit /b 1
)

:: Stop WSL if running
wsl --terminate %SELECTED_WSL% 2>nul

:: Final confirmation
set /p CONFIRM="🔥 Shrink %SELECTED_WSL% disk? (Y/n): "
if /i "%CONFIRM%"=="n" (
    echo ❌ Cancelled
    pause
    exit /b 0
)

:: Create diskpart script
set SCRIPT=%TEMP%\wsl_shrink_%RANDOM%.txt
echo select vdisk file="%DISK_FILE%" > "%SCRIPT%"
echo attach vdisk readonly >> "%SCRIPT%"
echo compact vdisk >> "%SCRIPT%"
echo detach vdisk >> "%SCRIPT%"

echo ⚡ Shrinking...
sudo diskpart /s "%SCRIPT%"

if %errorlevel% equ 0 (
    echo 🎉 Completed!
) else (
    echo 💥 Failed!
)

:: Cleanup
del "%SCRIPT%" 2>nul
pause
exit /b 0

:invalid_choice
echo ⛔ Invalid selection
pause
exit /b 1