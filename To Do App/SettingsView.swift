//
//  SettingsView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var ollamaService: OllamaService
    
    @State private var showingClearDataAlert = false
    @State private var showingOllamaSetup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // AI Settings
                        aiSettingsSection
                        
                        // Task Settings
                        taskSettingsSection
                        
                        // Data Management
                        dataManagementSection
                        
                        // App Info
                        appInfoSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all tasks and conversations. This action cannot be undone.")
        }
        .sheet(isPresented: $showingOllamaSetup) {
            OllamaSetupView(ollamaService: ollamaService)
        }
    }
    
    private var aiSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Settings")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 12) {
                // Ollama Connection Status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ollama Connection")
                            .font(.body)
                            .foregroundColor(Color("TextColor"))
                        
                        Text(ollamaService.isConnected ? "Connected" : "Not Connected")
                            .font(.caption)
                            .foregroundColor(ollamaService.isConnected ? Color("SuccessColor") : Color("WarningColor"))
                    }
                    
                    Spacer()
                    
                    Button("Setup") {
                        showingOllamaSetup = true
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AccentColor"))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                // AI Model Selection
                HStack {
                    Text("AI Model")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Text("llama2")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
            }
        }
    }
    
    private var taskSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Settings")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 12) {
                // Show Completed Tasks Toggle
                HStack {
                    Text("Show Completed Tasks")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Toggle("", isOn: $taskManager.showCompletedTasks)
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                // Default Priority
                HStack {
                    Text("Default Priority")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Text("Medium")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
            }
        }
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 12) {
                // Export Data
                Button(action: exportData) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color("AccentColor"))
                        
                        Text("Export Data")
                            .font(.body)
                            .foregroundColor(Color("TextColor"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(12)
                }
                
                // Clear All Data
                Button(action: { showingClearDataAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(Color("WarningColor"))
                        
                        Text("Clear All Data")
                            .font(.body)
                            .foregroundColor(Color("WarningColor"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Information")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 12) {
                InfoRow(title: "Version", value: "2.0.0")
                InfoRow(title: "Build", value: "2024.10.20")
                InfoRow(title: "Developer", value: "Suryanshu Nabheet")
                
                HStack {
                    Text("Total Tasks")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Text("\(taskManager.tasks.count)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
                
                HStack {
                    Text("Conversations")
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                    
                    Spacer()
                    
                    Text("\(taskManager.conversations.count)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("SecondaryBackground"))
                .cornerRadius(12)
            }
        }
    }
    
    private func exportData() {
        // Implementation for exporting data
        print("Export data functionality")
    }
    
    private func clearAllData() {
        taskManager.tasks.removeAll()
        taskManager.conversations.removeAll()
        UserDefaults.standard.removeObject(forKey: "SavedTasks")
        UserDefaults.standard.removeObject(forKey: "SavedConversations")
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color("TextColor"))
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

struct OllamaSetupView: View {
    @ObservedObject var ollamaService: OllamaService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 60))
                                .foregroundColor(Color("AccentColor"))
                            
                            Text("Ollama Setup")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color("TextColor"))
                            
                            Text("Connect to your local Ollama instance for AI-powered task generation")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Setup Instructions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Setup Instructions")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InstructionStep(
                                    number: 1,
                                    title: "Install Ollama",
                                    description: "Download and install Ollama from https://ollama.ai"
                                )
                                
                                InstructionStep(
                                    number: 2,
                                    title: "Start Ollama Service",
                                    description: "Run 'ollama serve' in your terminal"
                                )
                                
                                InstructionStep(
                                    number: 3,
                                    title: "Pull a Model",
                                    description: "Run 'ollama pull llama2' to download a model"
                                )
                                
                                InstructionStep(
                                    number: 4,
                                    title: "Test Connection",
                                    description: "Tap the 'Test Connection' button below"
                                )
                            }
                        }
                        
                        // Connection Status
                        VStack(spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(ollamaService.isConnected ? Color("SuccessColor") : Color("WarningColor"))
                                    .frame(width: 12, height: 12)
                                
                                Text(ollamaService.isConnected ? "Connected" : "Not Connected")
                                    .font(.body)
                                    .foregroundColor(Color("TextColor"))
                                
                                Spacer()
                            }
                            
                            if let errorMessage = ollamaService.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(Color("WarningColor"))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color("WarningColor").opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(12)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: ollamaService.checkConnection) {
                                HStack {
                                    if ollamaService.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    Text("Test Connection")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color("AccentColor"))
                                .cornerRadius(12)
                            }
                            .disabled(ollamaService.isLoading)
                            
                            Button("Done") {
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(Color("TextColor"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(12)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Ollama Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstructionStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color("AccentColor"))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color("TextColor"))
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("SecondaryBackground"))
        .cornerRadius(12)
    }
}

#Preview {
    SettingsView(taskManager: TaskManager(), ollamaService: OllamaService())
}
