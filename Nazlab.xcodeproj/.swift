//
//  ChatMessage.swift
//  Nazlab
//
//  Created by Assistant on 14.12.2025.
//

import Foundation
import SwiftData

@Model
final class ChatMessage {
    @Attribute(.indexed) var userEmail: String
    var id: UUID
    var role: String    // "system" | "user" | "assistant"
    var text: String
    var timestamp: Date

    init(userEmail: String, id: UUID = UUID(), role: String, text: String, timestamp: Date = .now) {
        self.userEmail = userEmail.lowercased()
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}
