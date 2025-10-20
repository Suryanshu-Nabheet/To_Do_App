//
//  OllamaService.swift
//  To Do App
//
//  Created by Suryanshu Nabheet on 20/10/25.
//

import Foundation
import Combine

class OllamaService: ObservableObject {
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "http://localhost:11434"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkConnection()
    }
    
    func checkConnection() {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isConnected = false
                    self?.errorMessage = "Ollama not running: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self?.isConnected = true
                    self?.errorMessage = nil
                } else {
                    self?.isConnected = false
                    self?.errorMessage = "Ollama service unavailable"
                }
            }
        }.resume()
    }
    
    func generateResponse(prompt: String, model: String = "llama2") -> AnyPublisher<String, Error> {
        isLoading = true
        errorMessage = nil
        
        let requestBody: [String: Any] = [
            "model": model,
            "prompt": prompt,
            "stream": false
        ]
        
        guard let url = URL(string: "\(baseURL)/api/generate"),
              let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            return Fail(error: OllamaError.invalidRequest)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: OllamaResponse.self, decoder: JSONDecoder())
            .map(\.response)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
            })
            .eraseToAnyPublisher()
    }
    
    func summarizeConversation(messages: [ConversationMessage]) -> AnyPublisher<String, Error> {
        let conversationText = messages.map { message in
            "\(message.isUser ? "User" : "AI"): \(message.content)"
        }.joined(separator: "\n")
        
        let prompt = """
        Please summarize the following conversation and extract actionable tasks. 
        Focus on identifying specific tasks, deadlines, and priorities mentioned.
        
        Conversation:
        \(conversationText)
        
        Summary format:
        1. Key topics discussed
        2. Actionable tasks identified
        3. Suggested priorities and deadlines
        """
        
        return generateResponse(prompt: prompt)
    }
    
    func generateTasksFromSummary(summary: String) -> AnyPublisher<[GeneratedTask], Error> {
        let prompt = """
        Based on this conversation summary, generate specific actionable tasks in JSON format.
        Each task should have: title, description, priority (low/medium/high/urgent), category (personal/work/health/learning/finance/other), and suggested due date.
        
        Summary: \(summary)
        
        Return JSON array format:
        [
            {
                "title": "Task title",
                "description": "Task description",
                "priority": "medium",
                "category": "work",
                "dueDate": "2024-01-15"
            }
        ]
        """
        
        return generateResponse(prompt: prompt)
            .tryMap { response in
                guard let data = response.data(using: .utf8) else {
                    throw OllamaError.invalidResponse
                }
                
                let tasks = try JSONDecoder().decode([GeneratedTask].self, from: data)
                return tasks
            }
            .eraseToAnyPublisher()
    }
}

struct OllamaResponse: Codable {
    let response: String
}

struct GeneratedTask: Codable {
    let title: String
    let description: String
    let priority: String
    let category: String
    let dueDate: String?
}

enum OllamaError: Error, LocalizedError {
    case invalidRequest
    case invalidResponse
    case connectionFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request to Ollama service"
        case .invalidResponse:
            return "Invalid response from Ollama service"
        case .connectionFailed:
            return "Failed to connect to Ollama service"
        }
    }
}
