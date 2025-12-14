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
    @Attribute(.unique) var id: UUID
    var role: String
    var text: String
    var timestamp: Date
    var userEmail: String

    init(
        id: UUID,
        role: String,
        text: String,
        timestamp: Date,
        userEmail: String
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.userEmail = userEmail.lowercased()
    }
}
