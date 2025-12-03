@echo off
REM BukAlert Vercel Deployment Script for Windows
REM This script builds the Flutter web app and prepares it for Vercel deployment

echo 🚀 Starting BukAlert Vercel Deployment
echo =====================================

REM Check if Flutter is available
if exist "..\flutter\bin\flutter.bat" (
    set FLUTTER_CMD=..\flutter\bin\flutter.bat
    echo ✅ Flutter found at ..\flutter\bin\flutter.bat
) else (
    flutter --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo ❌ Flutter is not installed or not in PATH
        echo Please install Flutter and add it to your PATH
        pause
        exit /b 1
    )
    set FLUTTER_CMD=flutter
    echo ✅ Flutter found in PATH
)

REM Check if npm is available for Vercel CLI
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ npm found
for /f "tokens=*" %%i in ('npm --version') do echo %%i

REM Check if Vercel CLI is available
vercel --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Vercel CLI not found. Installing...
    npm install -g vercel
    if %errorlevel% neq 0 (
        echo ❌ Failed to install Vercel CLI
        pause
        exit /b 1
    )
)

echo ✅ Vercel CLI ready

REM Clean previous builds
echo 🧹 Cleaning previous builds...
%FLUTTER_CMD% clean
if %errorlevel% neq 0 (
    echo ❌ Failed to clean Flutter project
    pause
    exit /b 1
)

REM Get dependencies
echo 📦 Installing dependencies...
%FLUTTER_CMD% pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to get Flutter dependencies
    pause
    exit /b 1
)

REM Build for web
echo 🔨 Building Flutter web app...
%FLUTTER_CMD% build web --release
if %errorlevel% neq 0 (
    echo ❌ Flutter web build failed
    pause
    exit /b 1
)

REM Check if build was successful
if not exist "build\web" (
    echo ❌ Build failed - build\web directory not found
    pause
    exit /b 1
)

echo ✅ Build completed successfully

REM Check if user is logged into Vercel
vercel whoami >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔐 Please login to Vercel first:
    vercel login
    if %errorlevel% neq 0 (
        echo ❌ Vercel login failed
        pause
        exit /b 1
    )
)

echo 📤 Deploying to Vercel...

REM Deploy to Vercel
if "%1"=="--prod" (
    echo 🌐 Deploying to production...
    vercel --prod
) else (
    echo 🧪 Deploying to preview...
    vercel
)

if %errorlevel% neq 0 (
    echo ❌ Vercel deployment failed
    pause
    exit /b 1
)

echo.
echo 🎉 Deployment completed!
echo.
echo 📱 Test your app at the provided Vercel URL
echo 📊 Check deployment status at https://vercel.com/dashboard
echo.
echo 📚 For detailed deployment guide, see VERCEL_DEPLOYMENT.md
echo.
pause
