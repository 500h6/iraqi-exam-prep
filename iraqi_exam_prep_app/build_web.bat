@echo off
REM Secure Build Script for Flutter Web
REM Usage: build_web.bat
REM Make sure to set environment variables before running

IF "%FIREBASE_API_KEY%"=="" (
    echo ERROR: FIREBASE_API_KEY not set
    exit /b 1
)

flutter build web --release ^
    --dart-define=FIREBASE_API_KEY=%FIREBASE_API_KEY% ^
    --dart-define=FIREBASE_APP_ID=%FIREBASE_APP_ID% ^
    --dart-define=FIREBASE_MESSAGING_SENDER_ID=%FIREBASE_MESSAGING_SENDER_ID% ^
    --dart-define=FIREBASE_PROJECT_ID=%FIREBASE_PROJECT_ID% ^
    --dart-define=FIREBASE_AUTH_DOMAIN=%FIREBASE_AUTH_DOMAIN% ^
    --dart-define=FIREBASE_STORAGE_BUCKET=%FIREBASE_STORAGE_BUCKET% ^
    --dart-define=FIREBASE_MEASUREMENT_ID=%FIREBASE_MEASUREMENT_ID% ^
    --dart-define=SUPABASE_URL=%SUPABASE_URL% ^
    --dart-define=SUPABASE_ANON_KEY=%SUPABASE_ANON_KEY%

echo Build complete!
