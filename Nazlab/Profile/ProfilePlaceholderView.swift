//
//  ProfilePlaceholderView.swift
//  Nazlab
//
//  Created by Nazerke Turganbek on 14.12.2025.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ProfilePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileManager.self) private var profileManager
    @Environment(AuthManager.self) private var auth
    @Environment(\.modelContext) private var modelContext

    // Persisted user data (локальное хранилище/кэш)
    @AppStorage("profile.fullName") private var fullName: String = ""
    @AppStorage("profile.role") private var role: String = ""
    @AppStorage("profile.school") private var school: String = ""
    @AppStorage("profile.email") private var email: String = ""

    // Settings
    @AppStorage("app.theme") private var theme: Int = 0
    @AppStorage("app.language") private var language: String = "kk"

    @State private var isEditingProfile: Bool = false
    @AppStorage("profile.notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("profile.biometricEnabled") private var biometricEnabled: Bool = false
    @State private var showSignOutConfirm: Bool = false

    // Photos Picker
    @State private var avatarPickerItem: PhotosPickerItem? = nil

    // Запрашиваем пользователя из SwiftData по текущему email
    @Query private var matchedUsers: [User]

    init() {
        // В init нет доступа к auth, поэтому фильтр зададим позже через .onAppear,
        // но чтобы @Query был валидным, инициализируем без фильтра.
        self._matchedUsers = Query()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PinkPurpleFloatingBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        headerCard

                        VStack(spacing: 12) {
                            GradientButton(title: "Редактировать профиль",
                                           systemImage: "pencil",
                                           gradient: [.pink.opacity(0.9), .purple]) {
                                isEditingProfile = true
                            }

                            GradientButton(title: "Уведомления",
                                           systemImage: "bell.badge",
                                           gradient: [.purple, .pink]) {
                                notificationsEnabled.toggle()
                            }

                            GradientButton(title: "Безопасность",
                                           systemImage: "lock.shield",
                                           gradient: [.pink, .purple]) {
                                biometricEnabled.toggle()
                            }
                        }

                        materialCard {
                            VStack(alignment: .leading, spacing: 10) {
                                labeledRow("ФИО", value: fullName)
                                labeledRow("Роль", value: role)
                                labeledRow("Школа", value: school)
                                labeledRow("Email", value: email)
                            }
                        }

                        materialCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "paintbrush")
                                        .foregroundStyle(.secondary)
                                    Text("Тема")
                                    Spacer()
                                    Picker("", selection: $theme) {
                                        Text("Системная").tag(0)
                                        Text("Светлая").tag(1)
                                        Text("Тёмная").tag(2)
                                    }
                                    .pickerStyle(.segmented)
                                }

                                Divider().background(.secondary.opacity(0.2))

                                HStack {
                                    Image(systemName: "character.book.closed")
                                        .foregroundStyle(.secondary)
                                    Text("Язык")
                                    Spacer()
                                    Picker("", selection: $language) {
                                        Text("Қазақша").tag("kk")
                                        Text("Русский").tag("ru")
                                        Text("English").tag("en")
                                    }
                                }

                                Divider().background(.secondary.opacity(0.2))

                                Toggle(isOn: $notificationsEnabled) {
                                    HStack {
                                        Image(systemName: "bell")
                                        Text("Уведомления")
                                    }
                                }

                                Toggle(isOn: $biometricEnabled) {
                                    HStack {
                                        Image(systemName: "faceid")
                                        Text("Защита по биометрии")
                                    }
                                }
                            }
                        }

                        materialCard {
                            VStack(spacing: 12) {
                                linkRow(title: "Помощь и обратная связь", systemImage: "questionmark.circle") {}
                                Divider().background(.secondary.opacity(0.2))
                                linkRow(title: "Политика конфиденциальности", systemImage: "hand.raised") {}
                                Divider().background(.secondary.opacity(0.2))
                                linkRow(title: "О приложении", systemImage: "info.circle") {}
                            }
                        }

                        DestructiveMaterialButton(
                            title: "Выйти",
                            systemImage: "rectangle.portrait.and.arrow.right"
                        ) {
                            showSignOutConfirm = true
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .sheet(isPresented: $isEditingProfile) {
                EditProfileSheet(
                    fullName: $fullName,
                    role: $role,
                    school: $school,
                    email: $email
                )
                .presentationDetents([.medium, .large])
            }
            .alert("Выйти", isPresented: $showSignOutConfirm) {
                Button("Отмена", role: .cancel) {}
                Button("Выйти", role: .destructive) { signOut() }
            } message: {
                Text("Ваши данные сохранятся. Подтвердите выход.")
            }
            .onChange(of: avatarPickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        profileManager.setAvatar(data: data)
                    }
                }
            }
            .task {
                // На входе подтянем текущего пользователя и обновим отображаемые поля.
                let currentEmail = auth.currentUserEmail?.lowercased() ?? ""
                if email.lowercased() != currentEmail {
                    email = currentEmail
                }

                if !currentEmail.isEmpty {
                    do {
                        let descriptor = FetchDescriptor<User>(
                            predicate: #Predicate { $0.email == currentEmail }
                        )
                        if let user = try modelContext.fetch(descriptor).first {
                            if fullName.isEmpty { fullName = user.name }
                            // Если в модели появятся поля role/school — раскомментируйте:
                            // if role.isEmpty { role = user.role }
                            // if school.isEmpty { school = user.school }
                        }
                    } catch {
                        #if DEBUG
                        print("Failed to fetch user:", error)
                        #endif
                    }
                }
            }
        }
    }

    // Header

    private var headerCard: some View {
        materialCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 66, height: 66)
                        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)

                    if let img = profileManager.avatarImage {
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(width: 62, height: 62)
                            .clipShape(Circle())
                    } else {
                        // Инициалы из имени
                        let initials = initialsFromName(fullName).isEmpty ? nil : initialsFromName(fullName)
                        if let initials, !initials.isEmpty {
                            Text(initials)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(fullName.isEmpty ? "—" : fullName)
                        .font(.headline)
                    Text(role.isEmpty ? "—" : role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    PhotosPicker(selection: $avatarPickerItem, matching: .images) {
                        HStack(spacing: 6) {
                            Image(systemName: "camera.fill")
                            Text("Изменить аватар")
                        }
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.35), lineWidth: 1))
                    }
                }

                Spacer()
            }
        }
    }

    // Helpers

    private func initialsFromName(_ name: String) -> String {
        let parts = name
            .split(separator: " ")
            .map { String($0) }
            .filter { !$0.isEmpty }
        guard let firstChar = parts.first?.first else { return "" }
        let secondChar = parts.dropFirst().first?.first
        if let secondChar {
            return String(firstChar).uppercased() + String(secondChar).uppercased()
        } else {
            return String(firstChar).uppercased()
        }
    }

    private func signOut() {
        auth.signOut()
        dismiss()
    }

    // Общая карточка с материал-стилем
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

    private func labeledRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .textSelection(.enabled)
        }
    }

    private func linkRow(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// Buttons

private struct GradientButton: View {
    let title: String
    let systemImage: String
    let gradient: [Color]
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                Text(title).bold()
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .pink.opacity(0.35), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct DestructiveMaterialButton: View {
    let title: String
    let systemImage: String
    var action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            HStack {
                Image(systemName: systemImage)
                Text(title).bold()
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(.red.opacity(0.4), lineWidth: 1.2)
            )
        }
        .buttonStyle(.plain)
        .tint(.red)
    }
}

// Edit sheet

private struct EditProfileSheet: View {
    @Binding var fullName: String
    @Binding var role: String
    @Binding var school: String
    @Binding var email: String

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case fullName, role, school, email }

    var body: some View {
        NavigationStack {
            ZStack {
                PinkPurpleFloatingBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 10) {
                            Text("Редактировать профиль")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundStyle(.primary)
                                .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                            Text("Обновите личные данные")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                        materialCard {
                            VStack(spacing: 14) {
                                labeledField(
                                    title: "ФИО",
                                    systemImage: "person",
                                    text: $fullName,
                                    prompt: "Ваше полное имя",
                                    field: .fullName
                                )

                                labeledField(
                                    title: "Роль",
                                    systemImage: "person.badge.shield.checkmark",
                                    text: $role,
                                    prompt: "Учитель / Ученик / ...",
                                    field: .role
                                )

                                labeledField(
                                    title: "Школа",
                                    systemImage: "building.2",
                                    text: $school,
                                    prompt: "Название школы",
                                    field: .school
                                )

                                labeledField(
                                    title: "Email",
                                    systemImage: "envelope",
                                    text: $email,
                                    prompt: "name@example.com",
                                    keyboard: .emailAddress,
                                    field: .email
                                )
                            }
                        }

                        HStack(spacing: 12) {
                            Button {
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text("Отмена").bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(.white.opacity(0.35), lineWidth: 1.1)
                                )
                            }
                            .buttonStyle(.plain)

                            Button {
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark")
                                    Text("Сохранить").bold()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(colors: [.purple, .pink],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing),
                                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                                )
                                .foregroundStyle(.white)
                                .shadow(color: .pink.opacity(0.35), radius: 12, y: 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func labeledField(
        title: String,
        systemImage: String,
        text: Binding<String>,
        prompt: String,
        keyboard: UIKeyboardType = .default,
        field: Field
    ) -> some View {
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

                TextField(prompt, text: text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: field)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        (focusedField == field ? Color.pink.opacity(0.9) : Color.white.opacity(0.45)),
                        lineWidth: focusedField == field ? 2.0 : 1.2
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

    // Локальная карточка с материал-стилем
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
}

