//
//  ContentView.swift
//  Nazlab
//
//  Created by Nazerke Turgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AuthManager.self) private var auth
    @State private var showOnboarding = true

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)

            } else if !auth.isAuthenticated {
                RegistrationView()

            } else {
                NavigationStack {
                    HomeView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {

                                    NavigationLink {
                                        AssistantView()
                                    } label: {
                                        Label("ИИ ассистент", systemImage: "sparkles")
                                    }

                                    NavigationLink {
                                        CreateLessonPlanView()
                                    } label: {
                                        Label("Создать план", systemImage: "doc.badge.plus")
                                    }

                                    NavigationLink {
                                        ProfileView()
                                    } label: {
                                        Label("Профиль", systemImage: "person.crop.circle")
                                    }

                                    NavigationLink {
                                        SettingsView()
                                    } label: {
                                        Label("Настройки", systemImage: "gear")
                                    }

                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                }

                            }
                        }
                }
            }
        }
        .animation(.default, value: auth.isAuthenticated)
    }
}
