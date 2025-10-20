//
//  AnalyticsView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview Cards
                        overviewCards
                        
                        // Charts
                        chartsSection
                        
                        // Task Lists
                        taskListsSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overviewCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            StatCard(
                title: "Total Tasks",
                value: "\(taskManager.tasks.count)",
                icon: "checklist",
                color: "AccentColor"
            )
            
            StatCard(
                title: "Completed",
                value: "\(taskManager.completedTasksCount)",
                icon: "checkmark.circle.fill",
                color: "SuccessColor"
            )
            
            StatCard(
                title: "Completion Rate",
                value: "\(Int(taskManager.progressPercentage * 100))%",
                icon: "chart.line.uptrend.xyaxis",
                color: "AccentColor"
            )
            
            StatCard(
                title: "Overdue",
                value: "\(taskManager.overdueTasks.count)",
                icon: "exclamationmark.triangle.fill",
                color: "WarningColor"
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            // Tasks by Category Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Tasks by Category")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                
                if #available(iOS 16.0, *) {
                    Chart(taskManager.tasksByCategory.map { (category, count) in
                        (category.rawValue, count)
                    }, id: \.0) { item in
                        BarMark(
                            x: .value("Category", item.0),
                            y: .value("Count", item.1)
                        )
                        .foregroundStyle(Color("AccentColor"))
                    }
                    .frame(height: 200)
                    .padding()
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(12)
                } else {
                    // Fallback for iOS < 16
                    VStack(spacing: 8) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.rawValue)
                                    .font(.body)
                                    .foregroundColor(Color("TextColor"))
                                
                                Spacer()
                                
                                Text("\(taskManager.tasksByCategory[category] ?? 0)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("AccentColor"))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Tasks by Priority Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Tasks by Priority")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                
                VStack(spacing: 8) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        HStack {
                            Circle()
                                .fill(Color(priority.color))
                                .frame(width: 12, height: 12)
                            
                            Text(priority.rawValue)
                                .font(.body)
                                .foregroundColor(Color("TextColor"))
                            
                            Spacer()
                            
                            Text("\(taskManager.tasksByPriority[priority] ?? 0)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(Color("AccentColor"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var taskListsSection: some View {
        VStack(spacing: 20) {
            // Overdue Tasks
            if !taskManager.overdueTasks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overdue Tasks")
                        .font(.headline)
                        .foregroundColor(Color("WarningColor"))
                    
                    ForEach(taskManager.overdueTasks.prefix(5)) { task in
                        OverdueTaskRow(task: task)
                    }
                }
            }
            
            // Recent AI Generated Tasks
            let aiTasks = taskManager.tasks.filter { $0.aiGenerated }.suffix(5)
            if !aiTasks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent AI Generated Tasks")
                        .font(.headline)
                        .foregroundColor(Color("SuccessColor"))
                    
                    ForEach(Array(aiTasks)) { task in
                        AITaskRow(task: task)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(color))
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color("TextColor"))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

struct OverdueTaskRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color("WarningColor"))
                .frame(width: 8, height: 8)
            
            Text(task.title)
                .font(.body)
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            if let dueDate = task.dueDate {
                Text(dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(Color("WarningColor"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color("WarningColor").opacity(0.1))
        .cornerRadius(8)
    }
}

struct AITaskRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .font(.caption)
                .foregroundColor(Color("SuccessColor"))
            
            Text(task.title)
                .font(.body)
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Text(task.createdAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color("SuccessColor").opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    AnalyticsView(taskManager: TaskManager())
}
