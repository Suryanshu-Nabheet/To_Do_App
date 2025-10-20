//
//  AddTaskView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var taskManager: TaskManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedPriority = TaskPriority.medium
    @State private var selectedCategory = TaskCategory.other
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var tags = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            TextField("Enter task title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        // Description Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            TextField("Enter task description (optional)", text: $description, axis: .vertical)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                                .lineLimit(3...6)
                        }
                        
                        // Priority Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            HStack(spacing: 12) {
                                ForEach(TaskPriority.allCases, id: \.self) { priority in
                                    PriorityButton(
                                        priority: priority,
                                        isSelected: selectedPriority == priority
                                    ) {
                                        selectedPriority = priority
                                    }
                                }
                            }
                        }
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(TaskCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        
                        // Due Date
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Due Date")
                                    .font(.headline)
                                    .foregroundColor(Color("TextColor"))
                                
                                Spacer()
                                
                                Toggle("", isOn: $hasDueDate)
                                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                            }
                            
                            if hasDueDate {
                                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .accentColor(Color("AccentColor"))
                            }
                        }
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            TextField("Enter tags separated by commas", text: $tags)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let tagsArray = tags.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        taskManager.addTask(
            title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: selectedPriority,
            category: selectedCategory,
            dueDate: hasDueDate ? dueDate : nil,
            tags: tagsArray
        )
        
        dismiss()
    }
}

struct PriorityButton: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: priority.icon)
                    .font(.caption)
                Text(priority.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : Color("TextColor"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(priority.color) : Color("SecondaryBackground"))
            .cornerRadius(16)
        }
    }
}

struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : Color("AccentColor"))
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : Color("TextColor"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color("AccentColor") : Color("SecondaryBackground"))
            .cornerRadius(12)
        }
    }
}

#Preview {
    AddTaskView(taskManager: TaskManager())
}
