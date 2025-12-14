//
//  ContentView.swift
//  Nazlab
//
//  Created by Nazerke Turgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth
    @Query private var items: [Item]

    @State private var showOnboarding = true

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()
            Group {

                // 1️⃣ Onboarding
                if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)

                // 2️⃣ Registration
                } else if !auth.isAuthenticated {
                    RegistrationView()

                // 3️⃣ Home
                } else {
                    NavigationStack {

                        VStack(spacing: 22) {

                            // Заголовок
                            VStack(spacing: 10) {
                                Text("Главная")
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .shadow(color: Color.purple.opacity(0.25), radius: 8)

                                Text("Ваши элементы")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)

                            // Список карточек
                            VStack(spacing: 0) {
                                if items.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 44))
                                            .foregroundStyle(.secondary)

                                        Text("Пока нет элементов")
                                            .font(.headline)

                                        Text("Нажмите “Добавить”, чтобы создать первый элемент.")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 160)
                                    .padding(.vertical, 24)

                                } else {
                                    List {
                                        ForEach(items) { item in
                                            NavigationLink {
                                                ZStack {
                                                    PinkPurpleFloatingBackground()
                                                    VStack(spacing: 16) {

                                                        VStack(spacing: 10) {
                                                            Text("Детали")
                                                                .font(.system(.title, design: .rounded, weight: .bold))
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: Color.purple.opacity(0.25), radius: 8)

                                                            Text("Информация об элементе")
                                                                .font(.subheadline)
                                                                .foregroundStyle(.secondary)
                                                        }
                                                        .padding(.top, 12)

                                                        VStack(spacing: 16) {
                                                            HStack(spacing: 12) {
                                                                Image(systemName: "clock")
                                                                    .foregroundStyle(.secondary)

                                                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                                                    .font(.headline)
                                                            }
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                        .padding(22)
                                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 22)
                                                                .stroke(.white.opacity(0.35), lineWidth: 1.2)
                                                        )
                                                        .shadow(color: .black.opacity(0.12), radius: 20)
                                                        .padding(.horizontal)

                                                        Spacer(minLength: 16)
                                                    }
                                                }
                                                .navigationBarTitleDisplayMode(.inline)
                                            } label: {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "clock")
                                                        .foregroundStyle(.secondary)

                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                                            .font(.headline)

                                                        Text("Открыть детали")
                                                            .font(.subheadline)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                }
                                                .padding(.vertical, 6)
                                            }
                                        }
                                        .onDelete(perform: deleteItems)
                                    }
                                    .listStyle(.plain)
                                    .scrollContentBackground(.hidden)
                                }
                            }
                            .padding(22)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(.white.opacity(0.35), lineWidth: 1.2)
                            )
                            .shadow(color: .black.opacity(0.12), radius: 20)
                            .padding(.horizontal)

                            // Добавить кнопку
                            HStack(spacing: 12) {
                                Button {
                                    addItem()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Добавить").bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(colors: [.purple.opacity(0.98), .pink.opacity(0.98)],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    )
                                    .foregroundStyle(.white)
                                    .shadow(color: .pink.opacity(0.35), radius: 14)
                                }
                            }
                            .padding(.horizontal)

                            Spacer(minLength: 26)
                        }
                        .padding(.bottom, 12)

                        // 🔥🔥🔥 БУРГЕР МЕНЮ ДҰРЫС ОРНЫНА ҚАЙТАРЫЛДЫ
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarTrailing) {

                                Menu {

                                    // 1️⃣ AI ASSISTANT (Gemini)
                                    NavigationLink {
                                        AssistantView()
                                    } label: {
                                        Label("ИИ ассистент", systemImage: "sparkles")
                                    }

                                    // 2️⃣ Профиль
                                    NavigationLink {
                                        Text(auth.currentUserEmail ?? "Нет email")
                                            .padding()
                                    } label: {
                                        Label("Профиль", systemImage: "person.crop.circle")
                                    }

                                    Divider()

                                    // 3️⃣ Логаут
                                    Button {
                                        auth.signOut()
                                    } label: {
                                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                                    }

                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .imageScale(.large)
                                }
                            }
#endif
                        }
                    }
                }
            }
            .animation(.default, value: auth.isAuthenticated)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.forEach { index in
                modelContext.delete(items[index])
            }
        }
    }
}

