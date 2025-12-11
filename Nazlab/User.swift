//
//  User.swift
//  Nazlab
//
//  Created by Nazerke Turganбек on 11.12.2025.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var email: String
    var name: String
    var passwordHash: String
    var createdAt: Date

    init(name: String, email: String, passwordHash: String, createdAt: Date = .now) {
        self.name = name
        self.email = email.lowercased()
        self.passwordHash = passwordHash
        self.createdAt = createdAt
    }
}
