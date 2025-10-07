@echo off
REM CTask GitHub Pages Deployment Setup Script for Windows
REM This script helps you quickly set up and deploy your CTask app to GitHub Pages

echo 🚀 CTask GitHub Pages Deployment Setup
echo ======================================

REM Check if git is initialized
if not exist ".git" (
    echo 📁 Initializing Git repository...
    git init
)

REM Check if GitHub remote exists
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ GitHub remote already configured
) else (
    echo ❓ Please enter your GitHub repository URL:
    echo    Format: https://github.com/YOUR_USERNAME/ctask.git
    set /p repo_url="Repository URL: "
    git remote add origin %repo_url%
    echo ✅ GitHub remote added
)

REM Add all files
echo 📦 Adding files to Git...
git add .

REM Commit changes
echo 💾 Committing changes...
set /p commit_msg="Enter commit message (press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Deploy CTask to GitHub Pages
git commit -m "%commit_msg%"

REM Push to GitHub
echo ⬆️ Pushing to GitHub...
git push -u origin main

echo.
echo 🎉 Setup Complete!
echo ===================
echo.
echo Next steps:
echo 1. Go to your GitHub repository
echo 2. Click 'Settings' ^> 'Pages'
echo 3. Set Source to 'GitHub Actions'
echo 4. Wait 3-5 minutes for deployment
echo.
echo Your app will be live at:
echo https://YOUR_USERNAME.github.io/ctask/
echo.
echo GitHub Actions will automatically deploy updates when you push changes!

pause