# CTask - Todo List App

A beautiful and functional todo list application built with Flutter that helps you organize your tasks across different states.

## Features

### 🗂️ Four Task States (Grid Layout)
- **Todo**: New tasks ready to be started
- **Doing**: Tasks currently in progress  
- **Pending**: Tasks temporarily paused (with reason tracking)
- **Done**: Completed tasks

### 📊 Grid Dashboard
- **Four-grid layout**: All states visible at once for better overview
- **Responsive design**: Adapts to different screen sizes (2x2 on mobile, 4x1 on desktop)
- **Summary statistics**: Quick overview of total tasks, in-progress, and completed items

### 🎨 Design
- Simple monotone color theme using shades of grey and blue-grey
- Clean, minimal interface focused on productivity
- Consistent visual hierarchy with state-specific colors

### 🌙 Dark Mode Support
- Full dark mode implementation
- Easy toggle between light and dark themes
- Theme-aware colors and components

### 📝 Task Management
- Add new tasks with title and optional description
- Move tasks between states with intuitive buttons
- Delete tasks with confirmation dialog
- View task counts in each state
- **Persistent storage**: All data automatically saved locally
- **Export/Import**: Backup and restore your data as JSON

### ⏸️ Pending State with Reason
- When moving a task to "Pending", you must provide a reason
- Reasons are displayed within the task card
- Helps track why tasks are blocked or paused

## Technical Details

### Architecture
- **State Management**: Provider pattern for clean state management
- **Models**: TodoItem with enum-based states
- **Widgets**: Modular widget structure for reusability
- **Theme**: Centralized theme management with light/dark variants

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   └── todo_item.dart       # Todo item model and states
├── providers/
│   └── todo_provider.dart   # State management
├── screens/
│   └── home_screen.dart     # Main app screen
├── theme/
│   └── app_theme.dart       # Theme configuration
└── widgets/
    ├── add_todo_dialog.dart         # Add new task dialog
    ├── pending_reason_dialog.dart   # Pending reason input
    ├── todo_item_widget.dart        # Individual task card
    └── todo_list_widget.dart        # Task list for each state
```

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

## Usage

1. **Adding Tasks**: Tap the floating action button (+) to add a new task
2. **Grid Overview**: View all four states simultaneously in the grid layout
3. **State Changes**: Use the menu (⋮) on each task card to move between states
4. **Pending Tasks**: When moving to "Pending", provide a reason that explains why the task is paused
5. **Dark Mode**: Toggle between light and dark themes using the theme button in the app bar
6. **Delete Tasks**: Use the menu (⋮) on each task card to delete tasks
7. **Summary Stats**: View total tasks, in-progress, and completed counts at the top

## Dependencies

- `flutter`: Flutter SDK
- `provider: ^6.1.1`: State management
- `shared_preferences: ^2.2.2`: Local data persistence

## Data Storage & Web Hosting

### 💾 **Data Persistence**
- **Local Storage**: Uses browser localStorage (web) or device storage (mobile)
- **JSON Format**: All data stored as structured JSON
- **Auto-Save**: Changes automatically persisted
- **Export/Import**: Full data backup and restore capability
- **Error Handling**: Graceful handling of storage failures

### 🌐 **Web Deployment Ready**
- **PWA Support**: Installable as Progressive Web App
- **Responsive Design**: Works on all screen sizes
- **Offline Capable**: Functions without internet connection
- **SEO Optimized**: Proper meta tags and descriptions
- **Multiple Hosting Options**: Firebase, Netlify, Vercel, GitHub Pages

### 🚀 **GitHub Pages Deployment**
```bash
# Quick setup (Windows)
./deploy-setup.bat

# Quick setup (Mac/Linux)
./deploy-setup.sh

# Or manual setup
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/ctask.git
git push -u origin main
```

**Live Demo**: Once deployed, your app will be available at:
`https://YOUR_USERNAME.github.io/ctask/`

See [GITHUB_PAGES_DEPLOYMENT.md](GITHUB_PAGES_DEPLOYMENT.md) for detailed instructions.
See [WEB_DEPLOYMENT.md](WEB_DEPLOYMENT.md) for other hosting options.

The app is built with Flutter's Material Design 3 components for a modern, accessible user interface.
