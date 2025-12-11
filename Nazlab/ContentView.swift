//
//  ContentView.swift
//  Nazlab
//
//  Created by Nazerke Тurgанбек on 11.12.2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import QuickLook

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AuthManager.self) private var auth
    @Query private var items: [Item]

    var body: some View {
        ZStack {
            // Тіркеу экранындағыдай анималды фон
            PinkPurpleFloatingBackground()

            Group {
                if auth.isAuthenticated {
                    NavigationStack {
                        VStack(spacing: 22) {
                            // Тақырып
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

                            // Тізім карточкасы (стеклянный стиль)
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
                                                // Деталь экраны да фонда және карточкада
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

                            // Төменгі панель: тек "Добавить"
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
                            }
                            .padding(.horizontal)

                            Spacer(minLength: 26)
                        }
                        .padding(.bottom, 12)
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Menu {
                                    // Сабақтар бөлімі (плейсхолдерлер)
                                    NavigationLink {
                                        AddLessonView()
                                    } label: {
                                        Label("Добавить урок", systemImage: "book.fill.badge.plus")
                                    }

                                    NavigationLink {
                                        EditLessonsView()
                                    } label: {
                                        Label("Редактировать уроки", systemImage: "pencil.and.list.clipboard")
                                    }

                                    // Құжаттар (PDF/Word)
                                    NavigationLink {
                                        DocumentsView()
                                    } label: {
                                        Label("Документы", systemImage: "doc.on.doc")
                                    }

                                    Divider()

                                    // ИИ ассистент (плейсхолдер)
                                    NavigationLink {
                                        AssistantPlaceholderView()
                                    } label: {
                                        Label("ИИ ассистент", systemImage: "sparkles")
                                    }

                                    // Профиль (плейсхолдер)
                                    NavigationLink {
                                        ProfilePlaceholderView(currentEmail: auth.currentUserEmail ?? "")
                                    } label: {
                                        Label("Профиль", systemImage: "person.crop.circle")
                                    }

                                    Divider()

                                    Button {
                                        addItem()
                                    } label: {
                                        Label("Добавить Item", systemImage: "plus")
                                    }

                                    // Шығу: аккаунттан шығарып, RegistrationView-ға ауысады
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
                    .id("auth-yes") // Авторизация бар кезде тармақ ID
                } else {
                    RegistrationView()
                        .id("auth-no") // Авторизация жоқ кезде тармақ ID
                }
            }
            .animation(.smooth(duration: 0.25), value: auth.isAuthenticated)
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

// MARK: - Documents

private struct DocumentsView: View {
    @State private var storedFiles: [URL] = []
    @State private var isImporterPresented: Bool = false
    @State private var previewURL: URL?

    private let allowedTypes: [UTType] = [
        .pdf,
        UTType(filenameExtension: "docx")!,
        UTType(filenameExtension: "doc")!
    ]

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    Text("Документы")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                    Text("Добавляйте и просматривайте PDF и Word файлы")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 20)

                // Құжаттар тізімі бар карточка
                VStack(spacing: 0) {
                    if storedFiles.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 44, weight: .regular))
                                .foregroundStyle(.secondary)
                            Text("Пока нет документов")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text("Нажмите “Добавить документ”, чтобы импортировать файл.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 160)
                        .padding(.vertical, 24)
                    } else {
                        List {
                            ForEach(storedFiles, id: \.self) { url in
                                HStack(spacing: 12) {
                                    Image(systemName: iconName(for: url))
                                        .foregroundStyle(.secondary)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(url.lastPathComponent)
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text(formattedSize(of: url) ?? "—")
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    // Алдын ала қарау
                                    Button {
                                        previewURL = url
                                    } label: {
                                        Image(systemName: "eye")
                                    }
                                    .buttonStyle(.borderless)
                                    .padding(.trailing, 6)

                                    // Бөлісу/жүктеу
                                    ShareLink(item: url) {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    .buttonStyle(.borderless)
                                }
                                .padding(.vertical, 6)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteFile(url)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                            }
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

                Button {
                    isImporterPresented = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Добавить документ")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.98), Color.pink.opacity(0.98)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    )
                    .foregroundStyle(.white)
                    .shadow(color: Color.pink.opacity(0.35), radius: 14, x: 0, y: 10)
                }
                .padding(.horizontal)

                Spacer(minLength: 26)
            }
            .padding(.bottom, 12)
        }
        .onAppear(perform: loadStoredFiles)
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: allowedTypes,
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                importFiles(urls)
            case .failure(let error):
                print("File import failed: \(error)")
            }
        }
        .quickLookPreview($previewURL)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    private func loadStoredFiles() {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let urls = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey], options: [.skipsHiddenFiles])
            storedFiles = urls.filter { url in
                let ext = url.pathExtension.lowercased()
                return ext == "pdf" || ext == "doc" || ext == "docx"
            }
        } catch {
            print("Failed to list documents: \(error)")
        }
    }

    private func importFiles(_ urls: [URL]) {
        let fm = FileManager.default
        guard let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        for src in urls {
            let dst = dir.appendingPathComponent(src.lastPathComponent)
            let finalURL = uniqueURL(for: dst)

            do {
                _ = src.startAccessingSecurityScopedResource()
                defer { src.stopAccessingSecurityScopedResource() }
                if fm.fileExists(atPath: finalURL.path) == false {
                    try fm.copyItem(at: src, to: finalURL)
                }
            } catch {
                print("Copy failed: \(error)")
            }
        }

        loadStoredFiles()
    }

    private func deleteFile(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            loadStoredFiles()
        } catch {
            print("Delete failed: \(error)")
        }
    }

    private func uniqueURL(for url: URL) -> URL {
        let fm = FileManager.default
        var candidate = url
        let baseName = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        var counter = 1
        while fm.fileExists(atPath: candidate.path) {
            let newName = "\(baseName) (\(counter)).\(ext)"
            candidate = url.deletingLastPathComponent().appendingPathComponent(newName)
            counter += 1
        }
        return candidate
    }

    private func formattedSize(of url: URL) -> String? {
        do {
            let values = try url.resourceValues(forKeys: [.fileSizeKey])
            if let size = values.fileSize {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                return formatter.string(fromByteCount: Int64(size))
            }
        } catch { }
        return nil
    }

    private func iconName(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.richtext"
        case "doc", "docx": return "doc"
        default: return "doc"
        }
    }
}

// MARK: - Lesson placeholders

private struct AddLessonView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var details: String = ""
    @State private var date: Date = .now

    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text("Добавить урок")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                        Text("Заполните данные урока")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                    VStack(spacing: 18) {
                        field(title: "Название", systemImage: "text.book.closed", text: $title, prompt: "Название урока")
                        field(title: "Описание", systemImage: "text.alignleft", text: $details, prompt: "Краткое описание")
                        dateField(title: "Дата", systemImage: "calendar", date: $date)
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
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
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
                        Task { await save() }
                    } label: {
                        HStack {
                            if isSaving { ProgressView() }
                            Text("Сохранить")
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.98), Color.pink.opacity(0.98)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        )
                        .foregroundStyle(.white)
                        .shadow(color: Color.pink.opacity(0.35), radius: 14, x: 0, y: 10)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                    .padding(.horizontal)

                    Spacer(minLength: 26)
                }
                .padding(.vertical, 26)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .animation(.smooth(duration: 0.25), value: errorMessage)
    }

    @ViewBuilder
    private func field(title: String, systemImage: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.pink.opacity(0.9), .secondary)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                TextField(prompt, text: text)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
            )
            .shadow(color: Color.purple.opacity(0.22), radius: 12, x: 0, y: 8)
        }
    }

    @ViewBuilder
    private func dateField(title: String, systemImage: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.pink.opacity(0.9), .secondary)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                DatePicker("", selection: date, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.45), lineWidth: 1.2)
            )
            .shadow(color: Color.purple.opacity(0.22), radius: 12, x: 0, y: 8)
        }
    }

    @MainActor
    private func save() async {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        // Мұнда SwiftData-ға сақтау қосылады (Lesson моделі дайын болғанда)
        dismiss()
    }
}

private struct EditLessonsView: View {
    @State private var lessons: [DraftLesson] = [
        .init(id: UUID(), title: "Математика", details: "Уравнения", date: .now),
        .init(id: UUID(), title: "История", details: "Древний мир", date: .now.addingTimeInterval(3600))
    ]

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()
            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    Text("Редактировать уроки")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .shadow(color: Color.purple.opacity(0.25), radius: 8, x: 0, y: 4)

                    Text("Список ваших уроков")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 20)

                List {
                    ForEach($lessons) { $lesson in
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Название", text: $lesson.title)
                                .font(.headline)
                            TextField("Описание", text: $lesson.details)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            DatePicker("Дата", selection: $lesson.date, displayedComponents: [.date, .hourAndMinute])
                                .font(.footnote)
                        }
                        .padding(12)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(.white.opacity(0.35), lineWidth: 1.0)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 6)
                    }
                    .onDelete { indexSet in
                        lessons.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)

                Spacer(minLength: 16)
            }
            .padding(.bottom, 12)
        }
        .navigationTitle("Уроки")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct DraftLesson: Identifiable {
        var id: UUID
        var title: String
        var details: String
        var date: Date
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
