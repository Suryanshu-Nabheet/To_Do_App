//
//  TaskModel.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import Foundation
import Combine
import SwiftUI

struct TaskItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}

class TaskManager: ObservableObject {
    @Published var tasks: [TaskItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "SavedTasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(_ title: String) {
        let newTask = TaskItem(title: title)
        tasks.append(newTask)
        saveTasks()
    }
    
    func toggleTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
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
}
