//
//  TaskDetailView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI

struct TaskDetailView: View {
    @State var task: TaskItem
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditing = false
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    @State private var editedPriority: TaskPriority
    @State private var editedCategory: TaskCategory
    @State private var editedDueDate: Date?
    @State private var hasDueDate = false
    @State private var editedTags = ""
    
    init(task: TaskItem, taskManager: TaskManager) {
        self.task = task
        self.taskManager = taskManager
        self._editedTitle = State(initialValue: task.title)
        self._editedDescription = State(initialValue: task.description)
        self._editedPriority = State(initialValue: task.priority)
        self._editedCategory = State(initialValue: task.category)
        self._editedDueDate = State(initialValue: task.dueDate)
        self._hasDueDate = State(initialValue: task.dueDate != nil)
        self._editedTags = State(initialValue: task.tags.joined(separator: ", "))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Task Header
                        taskHeaderView
                        
                        // Task Details
                        taskDetailsView
                        
                        // Tags
                        if !task.tags.isEmpty {
                            tagsView
                        }
                        
                        // Timestamps
                        timestampsView
                        
                        // AI Information
                        if task.aiGenerated {
                            aiInfoView
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if isEditing {
                            isEditing = false
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
    
    private var taskHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(Color(task.priority.color))
                    .frame(width: 16, height: 16)
                
                Spacer()
                
                Button(action: toggleCompletion) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? Color("SuccessColor") : .secondary)
                }
            }
            
            if isEditing {
                TextField("Task Title", text: $editedTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(task.isCompleted ? .secondary : Color("TextColor"))
                    .strikethrough(task.isCompleted)
                    .multilineTextAlignment(.center)
            }
            
            if !task.description.isEmpty || isEditing {
                if isEditing {
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                } else {
                    Text(task.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color("SecondaryBackground"))
        .cornerRadius(16)
    }
    
    private var taskDetailsView: some View {
        VStack(spacing: 16) {
            Text("Task Details")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                // Priority
                HStack {
                    Text("Priority")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    if isEditing {
                        Picker("Priority", selection: $editedPriority) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: task.priority.icon)
                                .font(.caption)
                            Text(task.priority.rawValue)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color(task.priority.color))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                // Category
                HStack {
                    Text("Category")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    if isEditing {
                        Picker("Category", selection: $editedCategory) {
                            ForEach(TaskCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: task.category.icon)
                                .font(.caption)
                            Text(task.category.rawValue)
                                .font(.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(Color("AccentColor"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                // Due Date
                HStack {
                    Text("Due Date")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    if isEditing {
                        Toggle("", isOn: $hasDueDate)
                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    } else {
                        if let dueDate = task.dueDate {
                            Text(dueDate, style: .date)
                                .font(.body)
                                .foregroundColor(dueDate < Date() ? Color("WarningColor") : .secondary)
                        } else {
                            Text("No due date")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                if isEditing && hasDueDate {
                    DatePicker("Due Date", selection: Binding(
                        get: { editedDueDate ?? Date() },
                        set: { editedDueDate = $0 }
                    ), displayedComponents: [.date])
                    .datePickerStyle(CompactDatePickerStyle())
                    .accentColor(Color("AccentColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(12)
                }
                
                // Tags
                HStack {
                    Text("Tags")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                if isEditing {
                    TextField("Enter tags separated by commas", text: $editedTags)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
        }
    }
    
    private var tagsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(task.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .foregroundColor(Color("AccentColor"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("AccentColor").opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var timestampsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timestamps")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 8) {
                HStack {
                    Text("Created")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Text(task.createdAt, style: .date)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color("SecondaryBackground"))
                .cornerRadius(8)
                
                if let completedAt = task.completedAt {
                    HStack {
                        Text("Completed")
                            .font(.body)
                            .foregroundColor(Color("TextColor"))
                        
                        Spacer()
                        
                        Text(completedAt, style: .date)
                            .font(.body)
                            .foregroundColor(Color("SuccessColor"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var aiInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Generated")
                .font(.headline)
                .foregroundColor(Color("SuccessColor"))
            
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(Color("SuccessColor"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("This task was generated by AI")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Based on your conversation with the AI assistant")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("SuccessColor").opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func toggleCompletion() {
        taskManager.toggleTask(task)
        task.isCompleted.toggle()
    }
    
    private func saveChanges() {
        let tagsArray = editedTags.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        task.title = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        task.description = editedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        task.priority = editedPriority
        task.category = editedCategory
        task.dueDate = hasDueDate ? editedDueDate : nil
        task.tags = tagsArray
        
        taskManager.updateTask(task)
        isEditing = false
    }
}

#Preview {
    TaskDetailView(
        task: TaskItem(title: "Sample Task", description: "This is a sample task", priority: .high, category: .work),
        taskManager: TaskManager()
    )
}
