//
//  ContentView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var taskManager = TaskManager()
    @State private var newTaskTitle = ""
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Task List
                    if taskManager.tasks.isEmpty {
                        emptyStateView
                    } else {
                        taskListView
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddTask) {
                addTaskView
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Tasks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("\(taskManager.tasks.count) tasks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color("AccentColor"))
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
                
                Text("\(completedTasksCount)/\(taskManager.tasks.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("CardBackgroundColor"))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color("AccentColor"))
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(.horizontal, 20)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(taskManager.tasks) { task in
                    TaskRowView(task: task, taskManager: taskManager)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(Color("AccentColor"))
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text("No tasks yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("TextColor"))
                
                Text("Add your first task to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddTask = true
            }) {
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
    
    private var addTaskView: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("New Task")
                        .font(.headline)
                        .foregroundColor(Color("TextColor"))
                    
                    TextField("Enter task title", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                
                Spacer()
                
                Button(action: {
                    if !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        taskManager.addTask(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines))
                        newTaskTitle = ""
                        showingAddTask = false
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Task")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color("AccentColor"))
                    .cornerRadius(12)
                }
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(20)
            .background(Color("BackgroundColor"))
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newTaskTitle = ""
                        showingAddTask = false
                    }
                }
            }
        }
    }
    
    private var completedTasksCount: Int {
        taskManager.tasks.filter { $0.isCompleted }.count
    }
    
    private var progressPercentage: Double {
        guard !taskManager.tasks.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(taskManager.tasks.count)
    }
}

struct TaskRowView: View {
    let task: TaskItem
    let taskManager: TaskManager
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    taskManager.toggleTask(task)
                    isAnimating.toggle()
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? Color("AccentColor") : .secondary)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            }
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(task.isCompleted ? .secondary : Color("TextColor"))
                    .strikethrough(task.isCompleted)
                    .multilineTextAlignment(.leading)
                
                Text(task.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Delete Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    taskManager.deleteTask(task)
                }
            }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
                    .opacity(0.7)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("CardBackgroundColor"))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
}
