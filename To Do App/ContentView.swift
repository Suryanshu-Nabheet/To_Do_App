//
//  ContentView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var ollamaService = OllamaService()
    @StateObject private var speechService = SpeechService()
    
    @State private var selectedTab = 0
    @State private var showingAddTask = false
    @State private var showingAIChat = false
    @State private var showingSettings = false
    @State private var currentConversation: Conversation?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Tasks View
            TasksView(taskManager: taskManager)
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tasks")
                }
                .tag(0)
            
            // AI Chat View
            AIChatView(
                taskManager: taskManager,
                ollamaService: ollamaService,
                speechService: speechService,
                currentConversation: $currentConversation
            )
            .tabItem {
                Image(systemName: "brain.head.profile")
                Text("AI Chat")
            }
            .tag(1)
            
            // Analytics View
            AnalyticsView(taskManager: taskManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(2)
            
            // Settings View
            SettingsView(taskManager: taskManager, ollamaService: ollamaService)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(Color("AccentColor"))
        .onAppear {
            setupAppearance()
        }
    }
    
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("PrimaryBackground"))
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct TasksView: View {
    @ObservedObject var taskManager: TaskManager
    @State private var showingAddTask = false
    @State private var showingFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Stats
                    headerView
                    
                    // Filter Bar
                    filterBar
                    
                    // Tasks List
                    if taskManager.filteredTasks.isEmpty {
                        emptyStateView
                    } else {
                        tasksListView
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTask) {
                AddTaskView(taskManager: taskManager)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Tasks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("\(taskManager.tasks.count) total • \(taskManager.completedTasksCount) completed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { showingFilters.toggle() }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                    }
                    
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Progress Bar
            if !taskManager.tasks.isEmpty {
                progressBarView
            }
        }
    }
    
    private var progressBarView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(taskManager.progressPercentage * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("AccentColor"))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("SecondaryBackground"))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: geometry.size.width * taskManager.progressPercentage, height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.5), value: taskManager.progressPercentage)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 20)
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: taskManager.selectedCategory == nil && taskManager.selectedPriority == nil
                ) {
                    taskManager.selectedCategory = nil
                    taskManager.selectedPriority = nil
                }
                
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: taskManager.selectedCategory == category
                    ) {
                        taskManager.selectedCategory = category
                    }
                }
                
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    FilterChip(
                        title: priority.rawValue,
                        isSelected: taskManager.selectedPriority == priority,
                        color: priority.color
                    ) {
                        taskManager.selectedPriority = priority
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }
    
    private var tasksListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(taskManager.filteredTasks) { task in
                    AdvancedTaskRowView(task: task, taskManager: taskManager)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checklist")
                .font(.system(size: 80))
                .foregroundColor(Color("AccentColor"))
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text("No tasks found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextColor"))
                
                Text("Add your first task or try adjusting your filters")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { showingAddTask = true }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color("AccentColor"))
                .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: String
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: String = "AccentColor", action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : Color("TextColor"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(color) : Color("SecondaryBackground"))
                .cornerRadius(20)
        }
    }
}

struct AdvancedTaskRowView: View {
    let task: TaskItem
    let taskManager: TaskManager
    @State private var isAnimating = false
    @State private var showingDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Priority Indicator
                Circle()
                    .fill(Color(task.priority.color))
                    .frame(width: 12, height: 12)
                
                // Checkbox
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        taskManager.toggleTask(task)
                        isAnimating.toggle()
                    }
                }) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(task.isCompleted ? Color("SuccessColor") : .secondary)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                }
                
                // Task Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .secondary : Color("TextColor"))
                        .strikethrough(task.isCompleted)
                        .multilineTextAlignment(.leading)
                    
                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 8) {
                        // Category Badge
                        HStack(spacing: 4) {
                            Image(systemName: task.category.icon)
                                .font(.caption2)
                            Text(task.category.rawValue)
                                .font(.caption2)
                        }
                        .foregroundColor(Color("AccentColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("AccentColor").opacity(0.1))
                        .cornerRadius(8)
                        
                        // Due Date
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text(dueDate, style: .date)
                                    .font(.caption2)
                            }
                            .foregroundColor(dueDate < Date() ? Color("WarningColor") : .secondary)
                        }
                        
                        // AI Generated Badge
                        if task.aiGenerated {
                            HStack(spacing: 4) {
                                Image(systemName: "brain.head.profile")
                                    .font(.caption2)
                                Text("AI")
                                    .font(.caption2)
                            }
                            .foregroundColor(Color("SuccessColor"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color("SuccessColor").opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: 8) {
                    Button(action: { showingDetails = true }) {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundColor(Color("AccentColor"))
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            taskManager.deleteTask(task)
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(Color("WarningColor"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("SecondaryBackground"))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .sheet(isPresented: $showingDetails) {
            TaskDetailView(task: task, taskManager: taskManager)
        }
    }
}

#Preview {
    ContentView()
}