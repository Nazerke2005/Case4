//
//  ProfileView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import SwiftData

struct ProfileView: View {

    @Environment(\.modelContext) private var context
    @Environment(AuthManager.self) private var auth

    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var subjects: Set<String> = []
    @State private var grades: Set<String> = []

    private let allSubjects = [
        "Математика", "Қазақ тілі", "Русский язык",
        "Физика", "Информатика"
    ]

    private let allGrades = [
        "1–4", "5–6", "7–8", "9–11"
    ]

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(spacing: 20) {

                    Text("Профиль")
                        .font(.largeTitle.bold())
                        .padding(.top, 24)

                    profileCard
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { loadProfile() }
        .navigationTitle("Профиль")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            TextField("Аты-жөні", text: $name)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))

            Text("Пәндер")
                .font(.headline)

            chips(allSubjects, selection: $subjects)

            Text("Сыныптар")
                .font(.headline)

            chips(allGrades, selection: $grades)

            Button("Сақтау") {
                saveProfile()
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive) {
                auth.signOut()
            } label: {
                Label("Шығу", systemImage: "rectangle.portrait.and.arrow.right")
            }

        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal)
    }

    private func chips(_ items: [String], selection: Binding<Set<String>>) -> some View {
        FlowLayout(items) { item in
            Button {
                if selection.wrappedValue.contains(item) {
                    selection.wrappedValue.remove(item)
                } else {
                    selection.wrappedValue.insert(item)
                }
            } label: {
                Text(item)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        selection.wrappedValue.contains(item)
                        ? Color.purple.opacity(0.25)
                        : Color.white.opacity(0.2)
                    )
                    .clipShape(Capsule())
            }
        }
    }

    private func loadProfile() {
        if let profile = profiles.first {
            name = profile.name
            subjects = Set(profile.subjects)
            grades = Set(profile.grades)
        }
    }

    private func saveProfile() {
        if let profile = profiles.first {
            profile.name = name
            profile.subjects = Array(subjects)
            profile.grades = Array(grades)
        } else {
            let profile = UserProfile(
                name: name,
                email: auth.currentUserEmail ?? "",
                subjects: Array(subjects),
                grades: Array(grades)
            )
            context.insert(profile)
        }
    }
}
