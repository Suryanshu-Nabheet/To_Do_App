//
//  AIChatView.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import SwiftUI
import Combine

struct AIChatView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var ollamaService: OllamaService
    @ObservedObject var speechService: SpeechService
    @Binding var currentConversation: Conversation?
    
    @State private var messageText = ""
    @State private var isGeneratingTasks = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Connection Status
                    connectionStatusView
                    
                    // Messages
                    messagesView
                    
                    // Input Area
                    inputArea
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if currentConversation == nil {
                    currentConversation = taskManager.addConversation()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Assistant")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("TextColor"))
                    
                    Text("Chat with AI to generate tasks")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: generateTasksFromConversation) {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                        Text("Generate Tasks")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("AccentColor"))
                    .cornerRadius(16)
                }
                .disabled(ollamaService.isLoading || currentConversation?.messages.isEmpty == true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            Circle()
                .fill(ollamaService.isConnected ? Color("SuccessColor") : Color("WarningColor"))
                .frame(width: 8, height: 8)
            
            Text(ollamaService.isConnected ? "Connected to Ollama" : "Ollama not connected")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if ollamaService.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color("SecondaryBackground"))
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
    
    private var messagesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if let conversation = currentConversation {
                    ForEach(conversation.messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    if isGeneratingTasks {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating tasks...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Speech Button
                Button(action: toggleSpeechRecognition) {
                    Image(systemName: speechService.isRecording ? "mic.fill" : "mic")
                        .font(.title2)
                        .foregroundColor(speechService.isRecording ? Color("WarningColor") : Color("AccentColor"))
                        .frame(width: 44, height: 44)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(22)
                }
                .disabled(!speechService.isAuthorized)
                
                // Text Input
                TextField("Type your message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                // Send Button
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(messageText.isEmpty ? Color.gray : Color("AccentColor"))
                        .cornerRadius(22)
                }
                .disabled(messageText.isEmpty || ollamaService.isLoading)
            }
            
            // Speech Recognition Text
            if !speechService.recognizedText.isEmpty {
                Text(speechService.recognizedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("SecondaryBackground"))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func toggleSpeechRecognition() {
        if speechService.isRecording {
            speechService.stopRecording()
            messageText = speechService.recognizedText
        } else {
            speechService.startRecording()
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let conversationId = currentConversation?.id else { return }
        
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        
        // Add user message
        taskManager.addMessage(to: conversationId, content: userMessage, isUser: true)
        
        // Generate AI response
        let prompt = """
        You are a helpful AI assistant that helps users organize their tasks and productivity. 
        Respond naturally to their message and ask follow-up questions to understand their needs better.
        Keep responses concise and helpful.
        
        User message: \(userMessage)
        """
        
        ollamaService.generateResponse(prompt: prompt)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error generating response: \(error)")
                    }
                },
                receiveValue: { response in
                    taskManager.addMessage(to: conversationId, content: response, isUser: false)
                }
            )
            .store(in: &cancellables)
    }
    
    private func generateTasksFromConversation() {
        guard let conversation = currentConversation,
              !conversation.messages.isEmpty else { return }
        
        isGeneratingTasks = true
        
        ollamaService.summarizeConversation(messages: conversation.messages)
            .flatMap { summary in
                self.taskManager.updateConversationSummary(conversation.id, summary: summary)
                return self.ollamaService.generateTasksFromSummary(summary: summary)
            }
            .sink(
                receiveCompletion: { completion in
                    self.isGeneratingTasks = false
                    if case .failure(let error) = completion {
                        print("Error generating tasks: \(error)")
                    }
                },
                receiveValue: { generatedTasks in
                    for generatedTask in generatedTasks {
                        let priority = TaskPriority(rawValue: generatedTask.priority) ?? .medium
                        let category = TaskCategory(rawValue: generatedTask.category) ?? .other
                        
                        var dueDate: Date?
                        if let dueDateString = generatedTask.dueDate {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-MM-dd"
                            dueDate = formatter.date(from: dueDateString)
                        }
                        
                        self.taskManager.addTask(
                            generatedTask.title,
                            description: generatedTask.description,
                            priority: priority,
                            category: category,
                            dueDate: dueDate,
                            aiGenerated: true,
                            conversationId: conversation.id
                        )
                        
                        self.taskManager.addGeneratedTaskToConversation(conversation.id, taskId: UUID())
                    }
                }
            )
            .store(in: &cancellables)
    }
}

struct MessageBubble: View {
    let message: ConversationMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color("AccentColor"))
                        .cornerRadius(18)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.8, alignment: .trailing)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(.body)
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(18)
                    
                    Text(message.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity * 0.8, alignment: .leading)
                
                Spacer()
            }
        }
    }
}

#Preview {
    AIChatView(
        taskManager: TaskManager(),
        ollamaService: OllamaService(),
        speechService: SpeechService(),
        currentConversation: .constant(nil)
    )
}
