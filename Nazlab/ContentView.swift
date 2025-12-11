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

    var body: some View {
        ZStack {
            // Тот же плавный фон, что и в RegistrationView
            PinkPurpleFloatingBackground()

            Group {
                if auth.isAuthenticated {
                    NavigationStack {
                        VStack(spacing: 22) {
                            // Заголовок в стиле RegistrationView
                            VStack(spacing: 10) {
                                Text("Главная")
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                                    .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                                Text("Ваши элементы")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)

                            // Карточка со списком, стилизованная аналогично полям в RegistrationView
                            VStack(spacing: 0) {
                                if items.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "tray")
                                            .font(.system(size: 44, weight: .regular))
                                            .foregroundStyle(.secondary)
                                        Text("Пока нет элементов")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
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
                                                // Детальный экран с тем же фоном и карточкой
                                                ZStack {
                                                    PinkPurpleFloatingBackground()
                                                    VStack(spacing: 16) {
                                                        VStack(spacing: 10) {
                                                            Text("Детали")
                                                                .font(.system(.title, design: .rounded, weight: .bold))
                                                                .foregroundStyle(.primary)
                                                                .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)
                                                            Text("Информация об элементе")
                                                                .font(.subheadline)
                                                                .foregroundStyle(.secondary)
                                                        }
                                                        .multilineTextAlignment(.center)
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
                                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                                .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                                                        )
                                                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 12)
                                                        .padding(.horizontal)

                                                        Spacer(minLength: 16)
                                                    }
                                                    .padding(.bottom, 12)
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
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                            )
                            .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 12)
                            .padding(.horizontal)

                            // Нижняя панель с действиями в стиле RegistrationView
                            HStack(spacing: 12) {
                                Button {
                                    addItem()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Добавить")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color.purple.opacity(0.98),
                                                Color.pink.opacity(0.98)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    )
                                    .foregroundStyle(.white)
                                    .shadow(color: Color.pink.opacity(0.35), radius: 14, x: 0, y: 10)
                                }

                                Button {
                                    auth.signOut()
                                } label: {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                        Text("Выйти")
                                            .bold()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(.white.opacity(0.45), lineWidth: 1.2)
                                    )
                                    .foregroundStyle(.primary)
                                    .shadow(color: Color.purple.opacity(0.22), radius: 12, x: 0, y: 8)
                                }
                            }
                            .padding(.horizontal)

                            Spacer(minLength: 26)
                        }
                        .padding(.bottom, 12)
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    // Навигация к ИИ ассистенту
                                    NavigationLink {
                                        AssistantPlaceholderView()
                                    } label: {
                                        Label("ИИ ассистент", systemImage: "sparkles")
                                    }

                                    // Навигация к профилю
                                    NavigationLink {
                                        ProfilePlaceholderView(currentEmail: auth.currentUserEmail ?? "")
                                    } label: {
                                        Label("Профиль", systemImage: "person.crop.circle")
                                    }

                                    Divider()

                                    Button {
                                        addItem()
                                    } label: {
                                        Label("Добавить", systemImage: "plus")
                                    }

                                    Button(role: .destructive) {
                                        auth.signOut()
                                    } label: {
                                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                                    }
                                } label: {
                                    Image(systemName: "line.3.horizontal")
                                        .imageScale(.large)
                                }
                                .accessibilityLabel("Меню")
                            }
#endif
                        }
                    }
                } else {
                    RegistrationView()
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
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Placeholders

private struct AssistantPlaceholderView: View {
    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()
            VStack(spacing: 16) {
                Text("ИИ ассистент")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                Text("Здесь будет ваш ассистент ИИ.")
                    .foregroundStyle(.secondary)
            }
            .padding(22)
        }
        .navigationTitle("ИИ ассистент")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfilePlaceholderView: View {
    let currentEmail: String

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()
            VStack(spacing: 18) {
                Text("Профиль")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.primary)
                    .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                VStack(spacing: 12) {
                    Label {
                        Text(currentEmail.isEmpty ? "Не указан" : currentEmail)
                            .font(.headline)
                    } icon: {
                        Image(systemName: "envelope")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        Text("Имя пользователя")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "person")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                )
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 12)
                .padding(.horizontal)
            }
            .padding(.vertical, 26)
        }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let container = try! ModelContainer(for: User.self, Item.self)
    return ContentView()
        .environment(AuthManager())
        .modelContainer(container)
}
