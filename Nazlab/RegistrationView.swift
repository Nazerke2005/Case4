//
//  RegistrationView.swift
//  Nazlab
//
//  Created by Nazerke Turgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData
import CoreData

struct RegistrationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth
    @Environment(\.dismiss) private var dismiss

    // Для проверки уникальности email (оставим, но в register перейдем на выборку по предикату)
    @Query(sort: \User.createdAt) private var users: [User]

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?

    // Управление показом экрана входа
    @State private var isLoginPresented: Bool = false

    // Callback для перехода на экран входа (необязательно, теперь используем fullScreenCover)
    var onLoginTapped: (() -> Void)? = nil

    enum Field {
        case name, email, password, confirm
    }

    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.pink.opacity(0.98),
                Color.purple.opacity(0.98)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text("Регистрация")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                        Text("Создайте учетную запись, чтобы продолжить")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                    VStack(spacing: 18) {
                        StyledLabeledTextField(
                            title: "Имя",
                            systemImage: "person",
                            text: $name,
                            prompt: "Ваше имя",
                            isSecure: false,
                            focused: _focusedField,
                            field: .name,
                            validationState: nameValidation
                        )

                        StyledLabeledTextField(
                            title: "Email",
                            systemImage: "envelope",
                            text: $email,
                            prompt: "name@example.com",
                            isSecure: false,
                            keyboard: .emailAddress,
                            textContentType: .emailAddress,
                            textInputAutocapitalization: .never,
                            focused: _focusedField,
                            field: .email,
                            validationState: emailValidation
                        )

                        StyledLabeledTextField(
                            title: "Пароль",
                            systemImage: "lock",
                            text: $password,
                            prompt: "Минимум 6 символов",
                            isSecure: true,
                            textContentType: .newPassword,
                            focused: _focusedField,
                            field: .password,
                            validationState: passwordValidation
                        )

                        StyledLabeledTextField(
                            title: "Подтверждение пароля",
                            systemImage: "lock.rotation",
                            text: $confirmPassword,
                            prompt: "Повторите пароль",
                            isSecure: true,
                            textContentType: .newPassword,
                            focused: _focusedField,
                            field: .confirm,
                            validationState: confirmValidation
                        )
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
                        .transition(.opacity .combined(with: .move(edge: .top)))
                    }

                    Button {
                        Task { await register() }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView()
                            }
                            Text("Зарегистрироваться")
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

                    Button {
                        if let onLoginTapped {
                            onLoginTapped()
                        } else {
                            isLoginPresented = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Уже есть аккаунт?")
                                .foregroundStyle(.secondary)
                            Text("Войти")
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
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginView()
                .environment(auth)
        }
        .onAppear {
            focusedField = .name
        }
        .animation(.smooth(duration: 0.25), value: errorMessage)
        .animation(.smooth(duration: 0.25), value: canSubmit)
    }

    // MARK: - Validation states for styling

    enum ValidationState {
        case normal, valid, invalid
    }

    private var nameValidation: ValidationState {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return .normal }
        return trimmed.count >= 2 ? .valid : .invalid
    }

    private var emailValidation: ValidationState {
        if email.isEmpty { return .normal }
        return isValidEmail(email) ? .valid : .invalid
    }

    private var passwordValidation: ValidationState {
        if password.isEmpty { return .normal }
        return password.count >= 6 ? .valid : .invalid
    }

    private var confirmValidation: ValidationState {
        if confirmPassword.isEmpty { return .normal }
        return confirmPassword == password ? .valid : .invalid
    }

    private var canSubmit: Bool {
        nameValidation == .valid &&
        emailValidation == .valid &&
        passwordValidation == .valid &&
        confirmValidation == .valid
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return email.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
    }

    @MainActor
    private func register() async {
        errorMessage = nil
        isProcessing = true
        defer { isProcessing = false }

        let normalizedEmail = email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        // Проверка уникальности email через точечный запрос
        do {
            let fetch = FetchDescriptor<User>(predicate: #Predicate { $0.email == normalizedEmail })
            let existing = try modelContext.fetch(fetch)
            if !existing.isEmpty {
                errorMessage = "Пользователь с таким email уже существует."
                return
            }
        } catch {
            // Если запрос не удался, лучше не продолжать регистрировать
            errorMessage = "Не удалось проверить email: \(error.localizedDescription)"
            return
        }

        let hash = PasswordHasher.hash(password)
        let newUser = User(name: trimmedName, email: normalizedEmail, passwordHash: hash, createdAt: .now)
        modelContext.insert(newUser)

        do {
            try modelContext.save()
            auth.signIn(as: normalizedEmail)
            // Явно закрыть экран, если он был показан модально (не навредит, если нет)
            dismiss()
        } catch {
            // Возможная гонка/нарушение уникальности email
            if (error as NSError).code == NSPersistentStoreSaveError || (error as NSError).domain.contains("SwiftData") {
                errorMessage = "Пользователь с таким email уже существует."
            } else {
                errorMessage = "Не удалось сохранить пользователя: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - StyledLabeledTextField

private struct StyledLabeledTextField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    var prompt: String
    var isSecure: Bool
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var textInputAutocapitalization: TextInputAutocapitalization? = .sentences

    @FocusState var focused: RegistrationView.Field?
    let field: RegistrationView.Field

    let validationState: RegistrationView.ValidationState

    private var borderColor: Color {
        switch validationState {
        case .normal: return Color.white.opacity(0.45)
        case .valid: return Color.green.opacity(0.85)
        case .invalid: return Color.red.opacity(0.85)
        }
    }

    private var glowShadow: Color {
        switch validationState {
        case .normal: return Color.purple.opacity(0.25)
        case .valid: return Color.green.opacity(0.28)
        case .invalid: return Color.red.opacity(0.28)
        }
    }

    var body: some View {
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
                Image(systemName: iconForField)
                    .foregroundStyle(.secondary)

                Group {
                    if isSecure {
                        SecureField(prompt, text: $text)
                            .textContentType(textContentType)
                            .focused($focused, equals: field)
                    } else {
                        TextField(prompt, text: $text)
                            .keyboardType(keyboard)
                            .textContentType(textContentType)
                            .textInputAutocapitalization(textInputAutocapitalization)
                            .autocorrectionDisabled()
                            .focused($focused, equals: field)
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
                        focused == field
                        ? borderColor
                        : Color.white.opacity(0.45),
                        lineWidth: focused == field ? 2.2 : 1.2
                    )
            )
            .shadow(color: glowShadow, radius: focused == field ? 18 : 12, x: 0, y: 8)
            .overlay(alignment: .trailing) {
                switch validationState {
                case .valid:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green.opacity(0.9))
                        .padding(.trailing, 12)
                        .transition(.scale .combined(with: .opacity))
                case .invalid:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.trailing, 12)
                        .transition(.scale .combined(with: .opacity))
                case .normal:
                    EmptyView()
                }
            }
        }
        .animation(.smooth(duration: 0.2), value: validationState)
        .animation(.smooth(duration: 0.18), value: focused == field)
    }

    private var iconForField: String {
        switch field {
        case .name: return "person"
        case .email: return "envelope"
        case .password: return "lock"
        case .confirm: return "lock.rotation"
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: User.self, Item.self)
    return RegistrationView()
        .environment(AuthManager())
        .modelContainer(container)
}
