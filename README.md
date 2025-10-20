# 🚀 Advanced To-Do App - AI-Powered iOS Application

A sophisticated, enterprise-grade iOS To-Do application built with SwiftUI featuring a sleek black and blue theme. This app combines traditional task management with cutting-edge AI capabilities, including local Ollama integration, speech recognition, and intelligent task generation from conversations.

## ✨ Features

### 🎨 **Modern Design**
- **Black & Blue Theme**: Elegant dark theme with blue accent colors
- **Card-based Layout**: Clean, organized task display
- **Smooth Animations**: Spring animations for interactions
- **Responsive Design**: Adapts to different screen sizes

### 📋 **Advanced Task Management**
- ✅ **Rich Task Creation**: Add tasks with descriptions, priorities, categories, due dates, and tags
- ✅ **Priority System**: Low, Medium, High, and Urgent priority levels with color coding
- ✅ **Category Organization**: Personal, Work, Health, Learning, Finance, and Other categories
- ✅ **Due Date Management**: Set and track task deadlines with overdue notifications
- ✅ **Tag System**: Organize tasks with custom tags for better filtering
- ✅ **Task Editing**: Full task detail editing with inline modifications
- ✅ **Smart Filtering**: Filter by category, priority, completion status, and search terms
- ✅ **Progress Analytics**: Comprehensive progress tracking and statistics

### 🤖 **AI-Powered Features**
- 🧠 **Local Ollama Integration**: Connect to your local Ollama instance for privacy-focused AI
- 🎤 **Speech-to-Text**: Voice input for hands-free task creation
- 💬 **AI Chat Interface**: Natural conversation with AI assistant
- 📝 **Conversation Summarization**: AI automatically summarizes your conversations
- ⚡ **Smart Task Generation**: AI creates actionable tasks from your conversations
- 🔗 **Conversation Tracking**: Link AI-generated tasks to their source conversations
- 🎯 **Intelligent Suggestions**: AI-powered task recommendations and insights

### 🚀 **User Experience**
- **Tabbed Navigation**: Dedicated tabs for Tasks, AI Chat, Analytics, and Settings
- **Advanced Filtering**: Multi-criteria filtering with visual chips
- **Real-time Analytics**: Comprehensive statistics and progress tracking
- **Empty States**: Beautiful onboarding and guidance throughout the app
- **Visual Feedback**: Smooth animations and micro-interactions
- **Responsive Design**: Optimized for all iOS device sizes

## 🛠 Technical Stack

- **Framework**: SwiftUI (iOS 14+)
- **Architecture**: MVVM (Model-View-ViewModel) with Combine
- **AI Integration**: Local Ollama API with HTTP requests
- **Speech Recognition**: Apple Speech Framework
- **Data Persistence**: UserDefaults with JSON encoding
- **Animation**: SwiftUI animations and transitions
- **Color Management**: Comprehensive color asset system
- **Charts**: Swift Charts for analytics visualization

## 📁 Project Structure

```
To Do App/
├── To Do App/
│   ├── ContentView.swift          # Main tabbed interface
│   ├── TasksView.swift            # Task management interface
│   ├── AIChatView.swift           # AI conversation interface
│   ├── AnalyticsView.swift        # Statistics and analytics
│   ├── SettingsView.swift         # App settings and configuration
│   ├── AddTaskView.swift          # Task creation interface
│   ├── TaskDetailView.swift       # Task editing and details
│   ├── TaskModel.swift            # Data models and business logic
│   ├── OllamaService.swift        # AI integration service
│   ├── SpeechService.swift        # Speech recognition service
│   ├── To_Do_AppApp.swift         # App entry point
│   └── Assets.xcassets/           # Comprehensive color system
│       ├── AccentColor.colorset/  # Primary blue accent
│       ├── PrimaryBackground.colorset/ # Main background
│       ├── SecondaryBackground.colorset/ # Card backgrounds
│       ├── SuccessColor.colorset/ # Success states
│       ├── WarningColor.colorset/ # Warning states
│       └── TextColor.colorset/    # Primary text color
├── To Do AppTests/                # Unit tests
└── To Do AppUITests/              # UI tests
```

## 🎨 Color Scheme

| Color | Hex Code | Usage |
|-------|----------|-------|
| Accent Color | #3366FF | Interactive elements, buttons, progress bars |
| Primary Background | #333333 | Main app background |
| Secondary Background | #4D4D4D | Card backgrounds, input fields |
| Success Color | #1A9966 | Completed tasks, success states |
| Warning Color | #CC6600 | Overdue tasks, warnings |
| Text Color | #FFFFFF | Primary text, headings |

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** with iOS 14.0+ deployment target
- **macOS 12.0+** for development
- **Ollama** installed locally (optional, for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Suryanshu-Nabheet/To_Do_App.git
   cd To_Do_App
   ```

2. **Open in Xcode**
   ```bash
   open "To Do App.xcodeproj"
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### AI Setup (Optional)

To enable AI features, you'll need to set up Ollama locally:

1. **Install Ollama**
   ```bash
   # macOS
   brew install ollama
   
   # Or download from https://ollama.ai
   ```

2. **Start Ollama Service**
   ```bash
   ollama serve
   ```

3. **Download a Model**
   ```bash
   ollama pull llama2
   ```

4. **Configure in App**
   - Open the app and go to Settings
   - Tap "Setup" next to Ollama Connection
   - Follow the setup instructions
   - Test the connection

## 📱 Usage

### Basic Task Management

1. **Adding Tasks**
   - Tap the "+" button in the Tasks tab
   - Fill in task details (title, description, priority, category)
   - Set due date and add tags if needed
   - Tap "Save" to create the task

2. **Managing Tasks**
   - Tap the circle to mark tasks as complete
   - Tap the info icon to view/edit task details
   - Tap the trash icon to delete tasks
   - Use filters to organize your view

3. **Filtering and Search**
   - Use filter chips to filter by category or priority
   - Use the search functionality to find specific tasks
   - Toggle completed tasks visibility in settings

### AI Features

1. **Voice Input**
   - Tap the microphone icon in the AI Chat tab
   - Speak your message naturally
   - The app will convert speech to text automatically

2. **AI Conversations**
   - Type or speak your thoughts and needs
   - The AI will respond and help organize your tasks
   - Use "Generate Tasks" to create actionable items from conversations

3. **Analytics**
   - View comprehensive statistics in the Analytics tab
   - Track progress across different categories and priorities
   - Monitor overdue tasks and AI-generated content

## 🔧 Development

### Key Components

- **TaskManager**: Central data management with Combine publishers
- **OllamaService**: HTTP client for local AI integration
- **SpeechService**: Speech recognition and audio processing
- **TaskItem**: Rich data model with priority, category, and metadata
- **Conversation**: AI chat history and task generation tracking

### Architecture Patterns

- **MVVM**: Clear separation of concerns with SwiftUI views
- **Combine**: Reactive programming for data flow
- **ObservableObject**: State management across views
- **Protocol-Oriented**: Extensible service architecture

## 🚀 Future Enhancements

- [ ] **Cloud Sync**: iCloud integration for cross-device synchronization
- [ ] **Widgets**: iOS home screen widgets for quick task access
- [ ] **Shortcuts**: Siri Shortcuts for voice task creation
- [ ] **Collaboration**: Shared task lists and team features
- [ ] **Advanced AI**: More sophisticated AI models and capabilities
- [ ] **Themes**: Additional color themes and customization options
- [ ] **Export**: Task export to various formats (PDF, CSV, etc.)
- [ ] **Notifications**: Smart reminders and deadline alerts

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Suryanshu Nabheet**
- GitHub: [@Suryanshu-Nabheet](https://github.com/Suryanshu-Nabheet)
- LinkedIn: [Suryanshu Nabheet](https://linkedin.com/in/suryanshu-nabheet)

## 🙏 Acknowledgments

- **Apple** for SwiftUI and iOS development tools
- **Ollama** for local AI model hosting
- **Swift Community** for inspiration and best practices

---

**Built with ❤️ using SwiftUI and AI**