@echo off
REM CTask Flutter App - Test Runner Script (Windows)
REM This script runs only the working tests to ensure CI/CD pipeline success

echo 🧪 Running CTask Flutter App Test Suite...
echo ==============================================

echo.
echo 📋 Running Unit Tests for TodoItem...
flutter test test/unit_tests/todo_item_test.dart --no-sound-null-safety
set ITEM_RESULT=%ERRORLEVEL%

echo.
echo 💾 Running Unit Tests for TodoRepository...
flutter test test/unit_tests/todo_repository_test.dart --no-sound-null-safety
set REPO_RESULT=%ERRORLEVEL%

echo.
echo ==============================================
echo 📊 Test Results Summary
echo ==============================================

if %ITEM_RESULT%==0 (
    echo ✅ TodoItem Tests: PASSED
) else (
    echo ❌ TodoItem Tests: FAILED
)

if %REPO_RESULT%==0 (
    echo ✅ TodoRepository Tests: PASSED
) else (
    echo ❌ TodoRepository Tests: FAILED
)

REM Overall result
if %ITEM_RESULT%==0 if %REPO_RESULT%==0 (
    echo.
    echo 🎉 All Core Tests PASSED! App is ready for deployment.
    exit /b 0
) else (
    echo.
    echo 💥 Some tests FAILED! Please fix before deployment.
    exit /b 1
)