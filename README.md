# 📱 To-Do App - iOS SwiftUI Application

A beautiful, modern iOS To-Do application built with SwiftUI featuring a sleek black and blue theme. This app provides a clean and intuitive interface for managing your daily tasks with smooth animations and persistent data storage.

## ✨ Features

### 🎨 **Modern Design**
- **Black & Blue Theme**: Elegant dark theme with blue accent colors
- **Card-based Layout**: Clean, organized task display
- **Smooth Animations**: Spring animations for interactions
- **Responsive Design**: Adapts to different screen sizes

### 📋 **Core Functionality**
- ✅ **Add Tasks**: Create new tasks with a simple tap
- ✅ **Mark Complete**: Toggle task completion with animated checkboxes
- ✅ **Delete Tasks**: Remove unwanted tasks with swipe or tap
- ✅ **Progress Tracking**: Visual progress bar showing completion percentage
- ✅ **Task Counter**: Real-time count of total tasks
- ✅ **Data Persistence**: Tasks saved automatically using UserDefaults

### 🚀 **User Experience**
- **Empty State**: Beautiful onboarding when no tasks exist
- **Visual Feedback**: Animated interactions and smooth transitions
- **Relative Time**: Shows when each task was created
- **Intuitive Navigation**: Simple, gesture-based interface

## 🛠 Technical Stack

- **Framework**: SwiftUI (iOS 14+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults with JSON encoding
- **Animation**: SwiftUI animations and transitions
- **Color Management**: Custom color assets in Assets.xcassets

## 📁 Project Structure

```
To Do App/
├── To Do App/
│   ├── ContentView.swift          # Main UI and task management
│   ├── TaskModel.swift            # Data models and business logic
│   ├── To_Do_AppApp.swift         # App entry point
│   └── Assets.xcassets/           # Color assets and app icons
│       ├── AccentColor.colorset/  # Blue accent color
│       ├── BackgroundColor.colorset/ # Dark background
│       ├── CardBackgroundColor.colorset/ # Card backgrounds
│       └── TextColor.colorset/    # Primary text color
├── To Do AppTests/                # Unit tests
└── To Do AppUITests/              # UI tests
```

## 🎨 Color Scheme

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Accent Color** | `#3366FF` | Interactive elements, progress bar |
| **Background** | `#1A1A1A` | Main app background |
| **Card Background** | `#262626` | Task card backgrounds |
| **Text** | `#FFFFFF` | Primary text color |

## 🚀 Getting Started

### Prerequisites
- Xcode 12.0 or later
- iOS 14.0 or later
- macOS 11.0 or later (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Suryanshu-Nabheet/To_Do_App.git
   ```

2. **Open in Xcode**
   ```bash
   cd To_Do_App
   open "To Do App.xcodeproj"
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run the app

## 📱 How to Use

### Adding Tasks
1. Tap the **+** button in the top-right corner
2. Enter your task description
3. Tap **"Add Task"** to save

### Managing Tasks
- **Complete**: Tap the circle icon next to any task
- **Delete**: Tap the trash icon on any task
- **View Progress**: See completion percentage in the progress bar

### Features Overview
- **Task Counter**: Shows total number of tasks at the top
- **Progress Bar**: Visual representation of completed vs total tasks
- **Empty State**: Helpful message and call-to-action when no tasks exist
- **Persistent Storage**: All tasks are automatically saved

## 🔧 Technical Details

### Data Model
```swift
struct TaskItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
    var createdAt: Date
}
```

### State Management
- Uses `@StateObject` for TaskManager
- ObservableObject pattern for reactive UI updates
- UserDefaults for data persistence with JSON encoding

### Key Components
- **ContentView**: Main app interface and navigation
- **TaskRowView**: Individual task display component
- **TaskManager**: Business logic and data management
- **Custom Colors**: Organized color assets for consistent theming

## 🎯 Future Enhancements

- [ ] Task categories and filtering
- [ ] Due dates and reminders
- [ ] Task priority levels
- [ ] Search functionality
- [ ] Dark/Light mode toggle
- [ ] Widget support
- [ ] iCloud synchronization
- [ ] Task sharing capabilities

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Suryanshu Nabheet**
- GitHub: [@Suryanshu-Nabheet](https://github.com/Suryanshu-Nabheet)
- Project Link: [https://github.com/Suryanshu-Nabheet/To_Do_App](https://github.com/Suryanshu-Nabheet/To_Do_App)

## 🙏 Acknowledgments

- SwiftUI documentation and examples
- iOS Human Interface Guidelines
- Apple Developer Community

---

⭐ **Star this repository if you found it helpful!**
