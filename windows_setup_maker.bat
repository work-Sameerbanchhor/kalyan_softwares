@echo off
:: ============================================================
::  Kalyan Smart Student System - Windows Setup Maker
::  Windows 7 Compatible Build Script
::  Builds both x64 and ia32 (32-bit) installers.
::  Run this on a Windows machine with Node.js installed.
:: ============================================================

title Kalyan Smart Student System - Setup Builder
color 0A

echo.
echo  ============================================================
echo   Kalyan Smart Student System - Windows Setup Builder
echo   (Windows 7 Compatible)
echo  ============================================================
echo.
echo   This script will:
echo     1. Check prerequisites (Node.js, npm)
echo     2. Install project dependencies
echo     3. Convert icons to required formats
echo     4. Build the Windows installer (.exe)
echo.
echo  ============================================================
echo.

:: -----------------------------------------------------------
:: Step 0: Check if running from the correct directory
:: -----------------------------------------------------------
if not exist "package.json" (
    echo [ERROR] package.json not found!
    echo         Please run this script from the project root directory.
    echo.
    pause
    exit /b 1
)

:: -----------------------------------------------------------
:: Step 1: Check Prerequisites
:: -----------------------------------------------------------
echo [1/5] Checking prerequisites...
echo.

:: Check Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is NOT installed!
    echo.
    echo   For Windows 7 compatibility, you MUST install Node.js v18 (LTS).
    echo   Download from: https://nodejs.org/dist/v18.20.4/node-v18.20.4-x64.msi
    echo                  (32-bit: https://nodejs.org/dist/v18.20.4/node-v18.20.4-x86.msi)
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo   [OK] Node.js found: %NODE_VERSION%

:: Warn if Node.js version is too new (v20+ may not work well with Electron 22)
for /f "tokens=1 delims=." %%v in ("%NODE_VERSION:v=%") do set NODE_MAJOR=%%v
if %NODE_MAJOR% GTR 18 (
    echo   [WARN] Node.js v%NODE_MAJOR% detected. Electron 22 works best with Node.js v18.
    echo          If you have issues, install Node.js v18 from https://nodejs.org/
    echo.
)

:: Check npm
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] npm is NOT installed!
    echo         It usually comes with Node.js. Reinstall Node.js.
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
echo   [OK] npm found: v%NPM_VERSION%

echo.

:: -----------------------------------------------------------
:: Step 2: Ask which architecture to build
:: -----------------------------------------------------------
echo  ============================================================
echo   Which installer do you want to build?
echo  ============================================================
echo.
echo     [1] x64  - Windows 7/10/11 64-bit  (recommended for modern PCs)
echo     [2] ia32 - Windows 7 32-bit         (for older Windows 7 machines)
echo     [3] Both - Build x64 AND ia32
echo.
set /p BUILD_CHOICE="  Enter choice (1/2/3) [default: 3]: "

if "%BUILD_CHOICE%"=="" set BUILD_CHOICE=3
if "%BUILD_CHOICE%"=="1" set BUILD_ARCH=--x64
if "%BUILD_CHOICE%"=="2" set BUILD_ARCH=--ia32
if "%BUILD_CHOICE%"=="3" set BUILD_ARCH=--x64 --ia32

if not defined BUILD_ARCH (
    echo [ERROR] Invalid choice. Please enter 1, 2, or 3.
    pause
    exit /b 1
)

echo.
echo   [OK] Will build: %BUILD_ARCH%
echo.

:: -----------------------------------------------------------
:: Step 3: Install npm dependencies
:: -----------------------------------------------------------
echo [2/5] Installing project dependencies...
echo       (This may take a few minutes on first run)
echo.

call npm install
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to install dependencies!
    echo         Check your internet connection and try again.
    echo.
    pause
    exit /b 1
)

echo.
echo   [OK] Dependencies installed successfully.
echo.

:: -----------------------------------------------------------
:: Step 4: Convert PNG icon to ICO format
:: -----------------------------------------------------------
echo [3/5] Converting icons to required formats...
echo.

:: Check if ImageMagick is available
where magick >nul 2>nul
if %errorlevel% equ 0 (
    echo   [INFO] ImageMagick found. Converting icons...

    :: Convert logo PNG to ICO
    if exist "media\kalyan_college_logo.png" (
        magick "media\kalyan_college_logo.png" -resize 256x256 "media\kalyan_college_logo.ico"
        if %errorlevel% equ 0 (
            echo   [OK] kalyan_college_logo.ico created.
        ) else (
            echo   [WARN] Failed to convert logo to ICO.
        )
    ) else (
        echo   [WARN] media\kalyan_college_logo.png not found. Skipping ICO conversion.
    )

    :: Convert banner PNG to BMP for NSIS installer sidebar
    if exist "media\kalyan_college_banner.png" (
        magick "media\kalyan_college_banner.png" -resize 164x314! -gravity center "media\installer_sidebar.bmp"
        if %errorlevel% equ 0 (
            echo   [OK] installer_sidebar.bmp created.
        ) else (
            echo   [WARN] Failed to convert banner to BMP.
        )
    ) else (
        echo   [WARN] media\kalyan_college_banner.png not found. Skipping BMP conversion.
    )
) else (
    :: ImageMagick not found - check if ICO already exists
    echo   [WARN] ImageMagick is NOT installed.
    echo          Checking if icon files already exist...

    if exist "media\kalyan_college_logo.ico" (
        echo   [OK] kalyan_college_logo.ico already exists. Proceeding...
    ) else (
        echo.
        echo   [ERROR] media\kalyan_college_logo.ico is missing and cannot be created
        echo           without ImageMagick!
        echo.
        echo   To fix this, either:
        echo     1. Install ImageMagick: https://imagemagick.org/script/download.php
        echo        (Check "Install legacy utilities" during setup)
        echo     2. Manually create the .ico file and place it in the media\ folder.
        echo.
        pause
        exit /b 1
    )

    if exist "media\installer_sidebar.bmp" (
        echo   [OK] installer_sidebar.bmp already exists. Proceeding...
    ) else (
        echo   [WARN] media\installer_sidebar.bmp is missing. The installer sidebar
        echo          image will not be shown. Install ImageMagick to auto-generate it.
    )
)

echo.

:: -----------------------------------------------------------
:: Step 5: Clean previous build (optional)
:: -----------------------------------------------------------
echo [4/5] Cleaning previous build output...
echo.

if exist "dist" (
    rmdir /s /q "dist"
    echo   [OK] Previous dist\ folder removed.
) else (
    echo   [OK] No previous build found. Clean slate.
)

echo.

:: -----------------------------------------------------------
:: Step 6: Build the Windows installer
:: -----------------------------------------------------------
echo [5/5] Building Windows installer (%BUILD_ARCH%)...
echo       (This may take several minutes)
echo.
echo  ============================================================
echo   DO NOT close this window while the build is in progress!
echo  ============================================================
echo.

call npx electron-builder --win %BUILD_ARCH%
if %errorlevel% neq 0 (
    echo.
    echo  ============================================================
    echo   [ERROR] Build FAILED!
    echo  ============================================================
    echo.
    echo   Common fixes:
    echo     - Make sure all dependencies are installed (run: npm install)
    echo     - Check that media\kalyan_college_logo.ico exists
    echo     - Ensure you have a stable internet connection
    echo     - Try running as Administrator
    echo     - Make sure Node.js v18 is installed (not v20+)
    echo.
    pause
    exit /b 1
)

:: -----------------------------------------------------------
:: Build Complete!
:: -----------------------------------------------------------
echo.
echo  ============================================================
echo.
echo   [SUCCESS] Windows installer(s) built successfully!
echo.
echo   Output location: dist\
echo.

:: List the generated installer files
echo   Generated files:
echo   -------------------------------------------------------
if exist "dist\*.exe" (
    for %%f in (dist\*.exe) do (
        echo     %%f
        for %%s in ("%%f") do echo     Size: %%~zs bytes
    )
) else (
    echo     [WARN] No .exe files found in dist\
)
echo   -------------------------------------------------------
echo.
echo   WHICH FILE TO GIVE TO USERS?
echo   -------------------------------------------------------
echo     *-ia32 Setup.exe  --^>  Windows 7 (32-bit machines)
echo     *-x64  Setup.exe  --^>  Windows 7/10/11 (64-bit machines)
echo.
echo   If unsure: give them the ia32 file. It works on BOTH
echo   32-bit AND 64-bit Windows 7 machines.
echo   -------------------------------------------------------
echo.

:: Open the dist folder in Explorer
echo   Opening output folder...
if exist "dist" (
    explorer "dist"
)

echo.
echo  ============================================================
echo   Build complete! You can close this window now.
echo  ============================================================
echo.
pause
