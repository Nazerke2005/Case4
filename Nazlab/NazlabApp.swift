//
//  NazlabApp.swift
//  Nazlab
//
//  Created by Nazerke Tургaнбек on 11.12.2025.
//

import SwiftUI
import SwiftData

@main
struct NazlabApp: App {
    @State private var auth = AuthManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            User.self,
            ChatMessage.self, // добавили модель чата
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var languageManager = LanguageManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(auth) // <-- inject AuthManager for @Environment(AuthManager.self)
                .environmentObject(languageManager)
                .environment(\.locale, languageManager.current.locale)
                .modelContainer(sharedModelContainer) // ensure SwiftData is available app-wide
        }
    }
}
