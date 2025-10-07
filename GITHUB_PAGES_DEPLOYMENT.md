# 🚀 Deploy CTask to GitHub Pages

This guide will help you deploy your CTask Flutter web app to GitHub Pages with automated deployment using GitHub Actions.

## 📋 Prerequisites

1. **GitHub Account**: Make sure you have a GitHub account
2. **Git Installed**: Ensure Git is installed on your computer
3. **Flutter Web Enabled**: Verify Flutter web support is enabled

## 🛠️ Step-by-Step Deployment

### Step 1: Create GitHub Repository

1. **Go to GitHub** and create a new repository:
   - Repository name: `ctask` (or any name you prefer)
   - Make it **Public** (required for free GitHub Pages)
   - Don't initialize with README (since you already have code)

2. **Copy the repository URL** (you'll need this)

### Step 2: Initialize Git and Push Code

Open terminal/command prompt in your project directory and run:

```bash
# Initialize git repository
git init

# Add all files
git add .

# Make first commit
git commit -m "Initial commit: CTask Flutter web app"

# Add GitHub repository as remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/ctask.git

# Push to GitHub
git push -u origin main
```

### Step 3: Enable GitHub Pages

1. **Go to your GitHub repository** on GitHub.com
2. **Click on "Settings"** tab
3. **Scroll down to "Pages"** in the left sidebar
4. **Under "Source"**, select **"GitHub Actions"**
5. **Save the settings**

### Step 4: Configure GitHub Actions (Already Done!)

The repository already includes the GitHub Actions workflow file at `.github/workflows/deploy.yml`. This will:
- ✅ Automatically build your Flutter web app
- ✅ Run tests and code analysis
- ✅ Deploy to GitHub Pages
- ✅ Trigger on every push to main branch

### Step 5: Push and Watch Deployment

```bash
# Make any changes and push
git add .
git commit -m "Ready for GitHub Pages deployment"
git push origin main
```

After pushing:
1. **Go to "Actions" tab** in your GitHub repository
2. **Watch the deployment process** - it takes about 3-5 minutes
3. **Once complete**, your app will be live at: `https://YOUR_USERNAME.github.io/ctask/`

## 🌐 Your Live App URL

After successful deployment, your CTask app will be available at:
```
https://YOUR_USERNAME.github.io/ctask/
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## 🔧 Automatic Updates

Every time you push changes to the `main` branch:
1. GitHub Actions automatically builds the app
2. Runs tests and code analysis
3. Deploys the updated version
4. Your live site updates within minutes!

## 📝 Making Updates

To update your deployed app:

```bash
# Make your changes to the code
# ... edit files ...

# Commit and push changes
git add .
git commit -m "Description of your changes"
git push origin main

# GitHub Actions will automatically deploy the updates!
```

## 🚨 Troubleshooting

### Build Fails
If the GitHub Actions build fails:

1. **Check the Actions tab** for error details
2. **Common issues:**
   - **SDK Version Issues**: Fixed by using flexible SDK constraints
   - **Flutter Version**: Uses latest stable channel automatically
   - **Test failures**: Check your test code
   - **Code analysis errors**: Run `flutter analyze` locally

### SDK Version Error
If you see "SDK version solving failed":
- ✅ **Already Fixed**: The project uses flexible SDK constraints (`>=3.0.0 <4.0.0`)
- ✅ **Auto-Update**: GitHub Actions uses the latest stable Flutter version
- ✅ **Backward Compatible**: Works with older Flutter versions too

### App Not Loading
If the deployed app doesn't load:

1. **Check the browser console** for errors
2. **Verify the URL** is correct: `https://YOUR_USERNAME.github.io/ctask/`
3. **Clear browser cache** and try again

### Permissions Issue
If you get permissions errors:

1. **Go to Settings > Actions > General**
2. **Under "Workflow permissions"**
3. **Select "Read and write permissions"**
4. **Save changes**

## 🎯 What You Get

✅ **Automatic Deployment**: Push to deploy  
✅ **HTTPS Security**: Secure connection  
✅ **Global CDN**: Fast loading worldwide  
✅ **Custom Domain**: Optional custom domain support  
✅ **Free Hosting**: No cost for public repositories  
✅ **Version Control**: Full Git history  
✅ **Rollback Support**: Easy to revert changes  

## 🔗 Useful Links

- **Your Repository**: `https://github.com/YOUR_USERNAME/ctask`
- **Live App**: `https://YOUR_USERNAME.github.io/ctask/`
- **GitHub Actions**: `https://github.com/YOUR_USERNAME/ctask/actions`
- **GitHub Pages Settings**: `https://github.com/YOUR_USERNAME/ctask/settings/pages`

## 🌟 Optional: Custom Domain

To use a custom domain (like `ctask.yourdomain.com`):

1. **Add a `CNAME` file** to the `web` folder with your domain
2. **Configure DNS** with your domain provider
3. **Update GitHub Pages settings** to use your custom domain

## 📱 PWA Features

Your deployed app includes:
- **Install button** in browsers
- **Offline capability**
- **App-like experience** on mobile devices
- **Push notifications** ready (if implemented)

---

**🎉 That's it! Your CTask app is now live on the web!**

Share your app URL with others and enjoy your deployed Flutter web application!