//
//  AssistantViewModel.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 13.12.2025.
//
import SwiftUI
import SwiftData
import Combine

@MainActor
final class AssistantViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isSending = false
    @Published var errorMessage: String?
    @Published var isTyping: Bool = false
    


    private var service: AIService?
    private var modelContext: ModelContext?
    private var currentUserEmail = "anonymous"
    private var isConfigured = false

    init() {
        messages = [
            Message(
                role: .system,
                text: "You are a helpful AI assistant. Answer clearly and politely."
            )
        ]
    }

    func configure(
        service: AIService,
        modelContext: ModelContext,
        currentUserEmail: String
    ) {
        guard !isConfigured else { return }
        self.service = service
        self.modelContext = modelContext
        self.currentUserEmail = currentUserEmail.lowercased()
        self.isConfigured = true
        loadHistory()
    }

    func send() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        let userMsg = Message(role: .user, text: trimmed)
        messages.append(userMsg)
        save(userMsg)

        inputText = ""
        isSending = true
        isTyping = true
        errorMessage = nil

        do {
            let context = Array(messages.suffix(6))
            guard let service else { throw GroqError.invalidResponse }
            let response = try await service.generateResponse(for: context)

            let assistantMsg = Message(role: .assistant, text: response)
            messages.append(assistantMsg)
            save(assistantMsg)

            isTyping = false
        } catch {
            isTyping = false
            errorMessage = (error as? LocalizedError)?.errorDescription
        }

        isSending = false
    }

    func clearChat() {
        messages = [
            Message(role: .system, text: "You are a helpful AI assistant.")
        ]
        deleteAll()
    }


    private func save(_ message: Message) {
        guard let modelContext else { return }
        modelContext.insert(
            ChatMessage(
                id: message.id,
                role: message.role.rawValue,
                text: message.text,
                timestamp: message.timestamp,
                userEmail: currentUserEmail
            )
        )
    }

    private func loadHistory() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.userEmail == currentUserEmail },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        if let stored = try? modelContext.fetch(descriptor), !stored.isEmpty {
            messages = stored.map {
                Message(
                    id: $0.id,
                    role: SenderRole(rawValue: $0.role) ?? .user,
                    text: $0.text,
                    timestamp: $0.timestamp
                )
            }
        }
    }

    private func deleteAll() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<ChatMessage>(
            predicate: #Predicate { $0.userEmail == currentUserEmail }
        )
        if let items = try? modelContext.fetch(descriptor) {
            items.forEach { modelContext.delete($0) }
        }
    }
}
