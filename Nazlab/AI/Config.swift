//
//  Config.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Combine
import SwiftUI
import Foundation

enum Config {

    static var groqAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String ?? ""
    }

    static let baseURL = URL(string: "https://api.groq.com")!
    static let chatPath = "/openai/v1/chat/completions"
    static let model = "llama-3.1-70b-versatile"
    static let requestTimeout: TimeInterval = 60
}
