# To Do App

A modern, advanced To Do application for macOS built with SwiftUI. This app features a beautiful dark blue-black gradient UI, persistent user profile with social links, calendar integration, notifications, and a focus on clean, accessible design.

---

## 🚀 Features

- **Task Management**: Add, complete, and delete tasks with date and time scheduling.
- **Calendar Integration**: View tasks by date in a graphical calendar.
- **User Profile**: Store your name, date of birth, goals, and add/remove your own social links.
- **Social Links**: Add any social platform with automatic icon selection and persistent storage.
- **Notifications**: Get reminders for your scheduled tasks (requires notification permissions).
- **Modern UI**: Clean, minimal, and accessible interface with a blue-black gradient background and bright white text.
- **Data Persistence**: All profile and social link data is saved locally using `UserDefaults`.
- **Production Ready**: Built with best practices for SwiftUI and macOS.

---

## 🛠️ Tech Stack

- **Swift 5**
- **SwiftUI** (for all UI and navigation)
- **UserNotifications** (for local notifications)
- **UserDefaults** (for local data persistence)
- **macOS** (AppKit not required, fully SwiftUI)

---

## 📦 Project Structure

```
To Do App/
├── ContentView.swift      # Main SwiftUI view and all subviews
├── ...                   # Other Swift files
├── To Do App.xcodeproj/  # Xcode project
├── To Do AppTests/       # Unit tests
├── To Do AppUITests/     # UI tests
└── readme.md             # This file
```

---

## 🖥️ Setup & Installation

1. **Clone the repository:**
   ```sh
   https://github.com/Suryanshu-Nabheet/To_Do_App.git
   ```
2. **Open in Xcode:**
   - Open `To Do App.xcodeproj` in Xcode (version 14 or later recommended).
3. **Build & Run:**
   - Select the `My Mac` target and click the Run ▶️ button.
4. **Grant Notification Permissions:**
   - The app will request notification permissions on first launch for reminders.

---

## 📝 Usage

- **Add a Task:**
  - Enter your task in the text field, select a date and time, and click the plus button.
- **Complete/Delete Tasks:**
  - Click the checkmark to complete, or the trash icon to delete.
- **View by Calendar:**
  - Switch to the Calendar tab to see tasks for a specific day.
- **Edit Profile:**
  - Go to Settings, enter your name, date of birth, and goals.
- **Add Social Links:**
  - In Settings, click the plus next to Social Links, enter the platform and URL, and save. Remove with the trash icon.

---

## 🎨 Design

- **Color Scheme:**
  - Blue-black gradient background
  - Bright white text for maximum contrast
  - Minimal, modern, and accessible
- **No unnecessary animations or distractions**

---

## 🔒 Privacy

- All data is stored locally on your device using `UserDefaults`.
- No data is sent to any server or third party.

---

## 🙏 Credits

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/) and [Xcode](https://developer.apple.com/xcode/).
- Calendar and notification features use Apple frameworks.
- Social icons use SF Symbols.

---

## 📄 License

This project is open source and free to use for personal and educational purposes.
