//
//  LoginView.swift
//  Nazlab
//
//  Created by Nazerke Turgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?

    @Query private var users: [User]

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    private var canSubmit: Bool {
        isValidEmail(email) && password.count >= 6
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PinkPurpleFloatingBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        VStack(spacing: 10) {
                            Text("Вход")
                                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                                .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                            Text("Введите email и пароль")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)

                        VStack(spacing: 18) {
                            field(title: "Email",
                                  systemImage: "envelope",
                                  isSecure: false,
                                  text: $email,
                                  prompt: "name@example.com",
                                  keyboard: .emailAddress,
                                  textContentType: .emailAddress,
                                  field: .email)

                            field(title: "Пароль",
                                  systemImage: "lock",
                                  isSecure: true,
                                  text: $password,
                                  prompt: "Ваш пароль",
                                  textContentType: .password,
                                  field: .password)
                        }
                        .padding(22)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 12)
                        .padding(.horizontal)

                        if let errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text(errorMessage)
                                    .foregroundStyle(.primary)
                            }
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(.orange.opacity(0.5), lineWidth: 1.2)
                            )
                            .shadow(color: .orange.opacity(0.25), radius: 10, x: 0, y: 6)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Button {
                            Task { await login() }
                        } label: {
                            HStack {
                                if isProcessing {
                                    ProgressView()
                                }
                                Text("Войти")
                                    .bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
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
                        .disabled(!canSubmit || isProcessing)
                        .opacity((!canSubmit || isProcessing) ? 0.8 : 1.0)
                        .padding(.horizontal)

                        // Нижняя ссылка: нет аккаунта? Зарегистрироваться
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Нет аккаунта?")
                                    .foregroundStyle(.secondary)
                                Text("Зарегистрироваться")
                                    .bold()
                                    .foregroundStyle(.pink)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        Spacer(minLength: 26)
                    }
                    .padding(.vertical, 26)
                }
            }
            .onAppear { focusedField = .email }
            .animation(.smooth(duration: 0.25), value: errorMessage)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func field(title: String,
                       systemImage: String,
                       isSecure: Bool,
                       text: Binding<String>,
                       prompt: String,
                       keyboard: UIKeyboardType = .default,
                       textContentType: UITextContentType? = nil,
                       field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(.pink.opacity(0.9))
            }

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)

                Group {
                    if isSecure {
                        SecureField(prompt, text: text)
                            .textContentType(textContentType)
                            .focused($focusedField, equals: field)
                    } else {
                        TextField(prompt, text: text)
                            .keyboardType(keyboard)
                            .textContentType(textContentType)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focusedField, equals: field)
                    }
                }
                .textFieldStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        (focusedField == field ? Color.pink.opacity(0.9) : Color.white.opacity(0.45)),
                        lineWidth: focusedField == field ? 2.2 : 1.2
                    )
            )
            .shadow(
                color: (focusedField == field ? Color.pink.opacity(0.35) : Color.purple.opacity(0.22)),
                radius: focusedField == field ? 18 : 12,
                x: 0, y: 8
            )
            .animation(.smooth(duration: 0.18), value: focusedField == field)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    @MainActor
    private func login() async {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let enteredHash = PasswordHasher.hash(password)

        guard let user = users.first(where: { $0.email == normalizedEmail }) else {
            errorMessage = "Пользователь с таким email не найден."
            return
        }

        guard user.passwordHash == enteredHash else {
            errorMessage = "Неверный пароль."
            return
        }

        auth.signIn(as: normalizedEmail)
        dismiss()
    }
}

#Preview {
    let container = try! ModelContainer(for: User.self, Item.self)
    return LoginView()
        .environment(AuthManager())
        .modelContainer(container)
}
