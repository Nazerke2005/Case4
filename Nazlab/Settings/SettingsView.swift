//
//  SettingsView.swift
//  Nazlab
//
//  Created by Nazerke Turganbek on 14.12.2025.
//

import SwiftUI
import LocalAuthentication
import SwiftData

struct SettingsView: View {

    @Environment(\.modelContext) private var modelContext

    // App settings
    @AppStorage("app.theme") private var theme: Int = 0 // 0: Системная, 1: Светлая, 2: Тёмная
    @AppStorage("profile.notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("profile.biometricEnabled") private var biometricEnabled: Bool = false

    // For confirmations
    @State private var showClearPlansConfirm = false
    @State private var showClearChatConfirm = false
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(spacing: 18) {

                    Text("Настройки")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)
                        .padding(.top, 8)

                    // Конфиденциальность и безопасность (перестилизовано)
                    materialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Конфиденциальность и безопасность",
                                  systemImage: "lock.shield")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Divider().background(.secondary.opacity(0.15))

                            Toggle(isOn: $notificationsEnabled) {
                                HStack(spacing: 10) {
                                    Image(systemName: "bell")
                                        .foregroundStyle(.secondary)
                                    Text("Уведомления")
                                }
                            }

                            Toggle(isOn: $biometricEnabled) {
                                HStack(spacing: 10) {
                                    Image(systemName: "faceid")
                                        .foregroundStyle(.secondary)
                                    Text("Биометрическая защита")
                                }
                            }
                            .onChange(of: biometricEnabled) { _, newValue in
                                if newValue { checkBiometricsSupport() }
                            }
                        }
                    }

                    // Управление данными
                    materialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Управление данными", systemImage: "tray.full")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Divider().background(.secondary.opacity(0.15))

                            buttonRow(
                                title: "Очистить планы уроков",
                                systemImage: "trash",
                                role: .destructive
                            ) { showClearPlansConfirm = true }

                            Divider().background(.secondary.opacity(0.15))

                            buttonRow(
                                title: "Очистить историю чата",
                                systemImage: "bubble.left.and.bubble.right",
                                role: .destructive
                            ) { showClearChatConfirm = true }

                            Divider().background(.secondary.opacity(0.15))

                            buttonRow(
                                title: "Сбросить настройки",
                                systemImage: "arrow.counterclockwise",
                                role: .destructive
                            ) { showResetConfirm = true }
                        }
                    }

                    // О приложении
                    materialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("О приложении", systemImage: "info.circle")
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Divider().background(.secondary.opacity(0.15))

                            HStack {
                                Image(systemName: "number")
                                    .foregroundStyle(.secondary)
                                Text("Версия")
                                Spacer()
                                Text(appVersionString)
                                    .foregroundStyle(.secondary)
                            }

                            Divider().background(.secondary.opacity(0.15))

                            Link(destination: URL(string: "https://example.com/privacy")!) {
                                HStack {
                                    Image(systemName: "hand.raised")
                                    Text("Политика конфиденциальности")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            Divider().background(.secondary.opacity(0.15))

                            Link(destination: URL(string: "mailto:support@example.com")!) {
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("Поддержка")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Очистить планы уроков?",
            isPresented: $showClearPlansConfirm,
            titleVisibility: .visible
        ) {
            Button("Очистить", role: .destructive) { clearAllLessonPlans() }
            Button("Отмена", role: .cancel) { }
        }
        .confirmationDialog(
            "Очистить историю чата?",
            isPresented: $showClearChatConfirm,
            titleVisibility: .visible
        ) {
            Button("Очистить", role: .destructive) { clearAllChat() }
            Button("Отмена", role: .cancel) { }
        }
        .confirmationDialog(
            "Сбросить настройки?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Сбросить", role: .destructive) { resetAppSettings() }
            Button("Отмена", role: .cancel) { }
        }
    }

    // Styled helpers

    @ViewBuilder
    private func materialCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.35), lineWidth: 1.1)
        )
        .shadow(color: .black.opacity(0.12), radius: 18, y: 10)
    }

    @ViewBuilder
    private func buttonRow(
        title: String,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title).bold()
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .tint(role == .destructive ? .red : .accentColor)
    }

    //  Helpers

    private var appVersionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return b.isEmpty ? v : "\(v) (\(b))"
    }

    private func checkBiometricsSupport() {
        let context = LAContext()
        var error: NSError?
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricEnabled = false
        }
    }

    private func clearAllLessonPlans() {
        let descriptor = FetchDescriptor<LessonPlan>()
        if let plans = try? modelContext.fetch(descriptor) {
            plans.forEach { modelContext.delete($0) }
        }
    }

    private func clearAllChat() {
        let descriptor = FetchDescriptor<ChatMessage>()
        if let messages = try? modelContext.fetch(descriptor) {
            messages.forEach { modelContext.delete($0) }
        }
    }

    private func resetAppSettings() {
        UserDefaults.standard.removeObject(forKey: "app.theme")
        UserDefaults.standard.removeObject(forKey: "app.language")
        UserDefaults.standard.removeObject(forKey: "profile.notificationsEnabled")
        UserDefaults.standard.removeObject(forKey: "profile.biometricEnabled")
    }
}
