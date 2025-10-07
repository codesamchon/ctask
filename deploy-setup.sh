#!/bin/bash

# CTask GitHub Pages Deployment Setup Script
# This script helps you quickly set up and deploy your CTask app to GitHub Pages

echo "🚀 CTask GitHub Pages Deployment Setup"
echo "======================================"

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing Git repository..."
    git init
fi

# Check if GitHub remote exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "✅ GitHub remote already configured"
else
    echo "❓ Please enter your GitHub repository URL:"
    echo "   Format: https://github.com/YOUR_USERNAME/ctask.git"
    read -p "Repository URL: " repo_url
    git remote add origin $repo_url
    echo "✅ GitHub remote added"
fi

# Add all files
echo "📦 Adding files to Git..."
git add .

# Commit changes
echo "💾 Committing changes..."
read -p "Enter commit message (press Enter for default): " commit_msg
if [ -z "$commit_msg" ]; then
    commit_msg="Deploy CTask to GitHub Pages"
fi
git commit -m "$commit_msg"

# Push to GitHub
echo "⬆️ Pushing to GitHub..."
git push -u origin main

echo ""
echo "🎉 Setup Complete!"
echo "==================="
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Click 'Settings' > 'Pages'"
echo "3. Set Source to 'GitHub Actions'"
echo "4. Wait 3-5 minutes for deployment"
echo ""
echo "Your app will be live at:"
echo "https://YOUR_USERNAME.github.io/ctask/"
echo ""
echo "GitHub Actions will automatically deploy updates when you push changes!"