//
//  AIService.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation

protocol AIService {
    func generateResponse(for messages: [Message]) async throws -> String
}
