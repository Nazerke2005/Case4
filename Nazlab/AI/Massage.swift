//
//  Massage.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
}

struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let role: SenderRole
    var text: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        role: SenderRole,
        text: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}
