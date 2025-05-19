// ContentView.swift
// Enhanced Advanced ToDo App with Calendar, Alarms, Profile & High Motion UI

import SwiftUI
import UserNotifications

// MARK: - Models

struct Task: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var date: Date
    var isCompleted: Bool = false
}

struct UserProfile: Codable {
    var name: String = ""
    var dob: Date = Date()
    var goals: String = ""
    var socialLinks: [SocialLink] = []
}

struct SocialLink: Identifiable, Codable {
    var id: UUID
    var platform: String
    var url: String
    var icon: String

    init(id: UUID = UUID(), platform: String, url: String, icon: String) {
        self.id = id
        self.platform = platform
        self.url = url
        self.icon = icon
    }
}

// MARK: - ContentView

struct ContentView: View {
    // Task Management
    @State private var tasks: [Task] = []
    @State private var newTask: String = ""
    @State private var taskDate: Date = Date()
    @FocusState private var isInputFocused: Bool

    // Profile
    @State private var userProfile = UserProfile()
    @State private var newSocialPlatform: String = ""
    @State private var newSocialUrl: String = ""
    @State private var showingAddSocial = false
    
    // Calendar
    @State private var selectedDate = Date()

    // MARK: - Init
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        loadUserProfile()
    }

    // MARK: - Body
    var body: some View {
        TabView {
            mainToDoView
                .tabItem {
                    Label("Tasks", systemImage: "checkmark.circle")
                }

            calendarView
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            settingsView
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(.white)
        .background(
            LinearGradient(colors: [.black, Color(red: 0.1, green: 0.1, blue: 0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    // MARK: - ToDo View
    var mainToDoView: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.1, green: 0.1, blue: 0.3)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("To Do")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [Color.blue, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .shadow(color: Color.blue.opacity(0.7), radius: 8, x: 0, y: 4)
                        .padding(.top)

                    VStack(spacing: 12) {
                        TextField("New task", text: $newTask)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .focused($isInputFocused)
                            .shadow(color: .blue.opacity(0.3), radius: 5)

                        HStack {
                            DatePicker("", selection: $taskDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .colorInvert()
                                .colorMultiply(.white)
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(15)
                                .shadow(color: .blue.opacity(0.3), radius: 5)

                            Button(action: addTask) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 32))
                                    .shadow(color: .blue.opacity(0.5), radius: 5)
                            }
                            .disabled(newTask.isEmpty)
                            .opacity(newTask.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .padding(.horizontal)

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(tasks.sorted(by: { $0.date < $1.date })) { task in
                                TaskRow(task: task,
                                        onToggle: { toggleCompletion(for: task) },
                                        onDelete: { deleteTask(task) })
                                    .animation(.spring(), value: tasks)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Calendar View
    var calendarView: some View {
        ZStack {
            AnimatedBackground()

            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(20)
                    .colorMultiply(.white)
                    .padding()

                List(filteredTasksForSelectedDate) { task in
                    HStack {
                        Text(task.title)
                            .foregroundColor(.white)
                        Spacer()
                        Text(task.date, style: .time)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.black.opacity(0.4))
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    var filteredTasksForSelectedDate: [Task] {
        tasks.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }

    // MARK: - Settings View
    var settingsView: some View {
        ZStack {
            LinearGradient(colors: [.black, Color(red: 0.1, green: 0.1, blue: 0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Text("Profile")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 20) {
                        // Profile Image
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.3)))
                            .padding(.bottom, 10)

                        // Name
                        TextField("Your Name", text: $userProfile.name)
                            .textFieldStyle(CustomTextFieldStyle())
                            .onChange(of: userProfile.name) { _, _ in saveUserProfile() }

                        // Date of Birth
                        DatePicker("Date of Birth", selection: $userProfile.dob, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorInvert()
                            .colorMultiply(.white)
                            .padding(.horizontal)
                            .onChange(of: userProfile.dob) { _, _ in saveUserProfile() }

                        // Goals
                        Text("Goals & Aspirations")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        TextEditor(text: $userProfile.goals)
                            .frame(height: 120)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .onChange(of: userProfile.goals) { _, _ in saveUserProfile() }

                        // Social Links
                        HStack {
                            Text("Social Links")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { showingAddSocial = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)

                        // Existing Social Links
                        ForEach(userProfile.socialLinks) { link in
                            HStack {
                                Image(systemName: link.icon)
                                    .foregroundColor(.white)
                                    .frame(width: 30)
                                
                                Text(link.platform)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Link(destination: URL(string: link.url) ?? URL(string: "https://apple.com")!) {
                                    Image(systemName: "arrow.up.right")
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: { deleteSocialLink(link) }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddSocial) {
            AddSocialLinkView(isPresented: $showingAddSocial, onSave: addSocialLink)
        }
    }

    // MARK: - Custom TextField Style
    struct CustomTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
                .foregroundColor(.white)
        }
    }

    // MARK: - Actions
    func addTask() {
        guard !newTask.isEmpty else { return }
        withAnimation {
            let task = Task(title: newTask, date: taskDate)
            tasks.append(task)
            scheduleNotification(for: task)
            newTask = ""
            taskDate = Date()
        }
    }

    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(of: task) {
            tasks[index].isCompleted.toggle()
        }
    }

    func deleteTask(_ task: Task) {
        if let index = tasks.firstIndex(of: task) {
            tasks.remove(at: index)
        }
    }

    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = "To Do Reminder"
        content.body = task.title
        content.sound = UNNotificationSound.default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func addSocialLink(_ platform: String, url: String) {
        let icon = getIconForPlatform(platform)
        let newLink = SocialLink(platform: platform, url: url, icon: icon)
        userProfile.socialLinks.append(newLink)
        saveUserProfile()
    }

    func deleteSocialLink(_ link: SocialLink) {
        userProfile.socialLinks.removeAll { $0.id == link.id }
        saveUserProfile()
    }

    func getIconForPlatform(_ platform: String) -> String {
        let lowercased = platform.lowercased()
        switch lowercased {
        case "website": return "globe"
        case "email": return "envelope.fill"
        case "phone": return "phone.fill"
        case "linkedin": return "link"
        case "twitter": return "bird.fill"
        case "instagram": return "camera.fill"
        default: return "link"
        }
    }

    // MARK: - Persistence
    func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
}

// MARK: - Task Row View

struct TaskRow: View {
    var task: Task
    var onToggle: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .scaleEffect(task.isCompleted ? 1.2 : 1.0)
                    .animation(.easeInOut, value: task.isCompleted)
            }

            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .strikethrough(task.isCompleted, color: .white)

                Text(task.date, style: .date) + Text(", ") + Text(task.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.2))
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Animated Background

struct AnimatedBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.7), Color.black]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .animation(Animation.linear(duration: 10).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear { animateGradient = true }
        .ignoresSafeArea()
    }
}

// MARK: - Add Social Link View
struct AddSocialLinkView: View {
    @Binding var isPresented: Bool
    let onSave: (String, String) -> Void
    
    @State private var platform: String = ""
    @State private var url: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Platform (e.g., LinkedIn, Twitter)", text: $platform)
                TextField("URL", text: $url)
            }
            .navigationTitle("Add Social Link")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(platform, url)
                        isPresented = false
                    }
                    .disabled(platform.isEmpty || url.isEmpty)
                }
            }
        }
    }
}
