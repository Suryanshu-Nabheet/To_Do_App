//
//  TaskModel.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import Foundation
import Combine
import SwiftUI

enum TaskPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var color: String {
        switch self {
        case .low: return "SuccessColor"
        case .medium: return "AccentColor"
        case .high: return "WarningColor"
        case .urgent: return "WarningColor"
        }
        }
    
    var icon: String {
        switch self {
        case .low: return "arrow.down.circle"
        case .medium: return "minus.circle"
        case .high: return "arrow.up.circle"
        case .urgent: return "exclamationmark.triangle"
        }
    }
}

enum TaskCategory: String, CaseIterable, Codable {
    case personal = "Personal"
    case work = "Work"
    case health = "Health"
    case learning = "Learning"
    case finance = "Finance"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .personal: return "person.circle"
        case .work: return "briefcase.circle"
        case .health: return "heart.circle"
        case .learning: return "book.circle"
        case .finance: return "dollarsign.circle"
        case .other: return "folder.circle"
        }
    }
}

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: TaskPriority
    var category: TaskCategory
    var createdAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var tags: [String]
    var aiGenerated: Bool
    var conversationId: UUID?
    
    init(title: String, description: String = "", priority: TaskPriority = .medium, category: TaskCategory = .other, dueDate: Date? = nil, tags: [String] = [], aiGenerated: Bool = false, conversationId: UUID? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.category = category
        self.createdAt = Date()
        self.dueDate = dueDate
        self.completedAt = nil
        self.tags = tags
        self.aiGenerated = aiGenerated
        self.conversationId = conversationId
    }
}

struct ConversationMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

struct Conversation: Identifiable, Codable {
    let id = UUID()
    var messages: [ConversationMessage]
    var summary: String?
    var generatedTasks: [UUID]
    let createdAt: Date
    
    init() {
        self.messages = []
        self.summary = nil
        self.generatedTasks = []
        self.createdAt = Date()
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [TaskItem] = []
    @Published var conversations: [Conversation] = []
    @Published var selectedCategory: TaskCategory?
    @Published var selectedPriority: TaskPriority?
    @Published var searchText: String = ""
    @Published var showCompletedTasks: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "SavedTasks"
    private let conversationsKey = "SavedConversations"
    
    init() {
        loadTasks()
        loadConversations()
    }
    
    // MARK: - Task Management
    func addTask(_ title: String, description: String = "", priority: TaskPriority = .medium, category: TaskCategory = .other, dueDate: Date? = nil, tags: [String] = [], aiGenerated: Bool = false, conversationId: UUID? = nil) {
        let newTask = TaskItem(title: title, description: description, priority: priority, category: category, dueDate: dueDate, tags: tags, aiGenerated: aiGenerated, conversationId: conversationId)
        tasks.append(newTask)
        saveTasks()
    }
    
    func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                tasks[index].completedAt = Date()
            } else {
                tasks[index].completedAt = nil
            }
            saveTasks()
        }
    }
    
    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
        saveTasks()
    }
    
    // MARK: - Filtering and Search
    var filteredTasks: [TaskItem] {
        var filtered = tasks
        
        if !showCompletedTasks {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered.sorted { task1, task2 in
            if task1.priority != task2.priority {
                return task1.priority.rawValue > task2.priority.rawValue
            }
            if let due1 = task1.dueDate, let due2 = task2.dueDate {
                return due1 < due2
            }
            return task1.createdAt > task2.createdAt
        }
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(tasks.count)
    }
    
    // MARK: - Statistics
    var tasksByCategory: [TaskCategory: Int] {
        Dictionary(grouping: tasks, by: { $0.category })
            .mapValues { $0.count }
    }
    
    var tasksByPriority: [TaskPriority: Int] {
        Dictionary(grouping: tasks, by: { $0.priority })
            .mapValues { $0.count }
    }
    
    var overdueTasks: [TaskItem] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return !task.isCompleted && dueDate < now
        }
    }
    
    // MARK: - Conversation Management
    func addConversation() -> Conversation {
        let conversation = Conversation()
        conversations.append(conversation)
        saveConversations()
        return conversation
    }
    
    func addMessage(to conversationId: UUID, content: String, isUser: Bool) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            let message = ConversationMessage(content: content, isUser: isUser)
            conversations[index].messages.append(message)
            saveConversations()
        }
    }
    
    func updateConversationSummary(_ conversationId: UUID, summary: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].summary = summary
            saveConversations()
        }
    }
    
    func addGeneratedTaskToConversation(_ conversationId: UUID, taskId: UUID) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index].generatedTasks.append(taskId)
            saveConversations()
        }
    }
    
    // MARK: - Persistence
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        }
    }
    
    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            userDefaults.set(encoded, forKey: conversationsKey)
        }
    }
    
    private func loadConversations() {
        if let data = userDefaults.data(forKey: conversationsKey),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        }
    }
}
