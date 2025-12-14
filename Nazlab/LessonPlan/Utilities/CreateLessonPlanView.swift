//
//  CreateLessonPlanView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

//
//  CreateLessonPlanView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//
//
//  CreateLessonPlanView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct CreateLessonPlanView: View {

    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Form fields
    @State private var subject = ""
    @State private var grade = ""
    @State private var title = ""
    @State private var objectives = ""
    @State private var lessonFlow = ""
    @State private var assessment = ""
    @State private var homework = ""
    @State private var createdPlan: LessonPlan?
    @State private var showPreview = false

    // MARK: - Image
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?

    // MARK: - AI
    @State private var isFillingWithAI = false

    // MARK: - View
    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(spacing: 20) {

                    Text("Создание поурочного плана")
                        .font(.custom("Times New Roman", size: 20))
                        .bold()
                        .padding(.top, 24)

                    formCard
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Новый план")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPreview) {
            if let plan = createdPlan {
                NavigationStack {
                    LessonPlanPreviewView(plan: plan)
                }
            }
        }
    }

    // MARK: - Form Card
    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {

            formField("Предмет", text: $subject)
            formField("Класс", text: $grade)
            formField("Тема урока", text: $title)

            formEditor("Цели урока", text: $objectives)
            formEditor("Ход урока", text: $lessonFlow)
            formEditor("Оценивание", text: $assessment)
            formEditor("Домашнее задание", text: $homework)

            imagePicker

            // ✨ AI Fill
            Button {
                Task { await fillWithAI() }
            } label: {
                Label(
                    isFillingWithAI ? "AI толтырып жатыр…" : "✨ AI арқылы толтыру",
                    systemImage: "sparkles"
                )
                .frame(maxWidth: .infinity)
            }
            .disabled(isFillingWithAI)

            // Save
            Button {
                saveLessonPlan()
            } label: {
                Text("Сохранить план")
                    .font(.custom("Times New Roman", size: 14))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.top, 8)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal)
    }

    // MARK: - Form helpers
    private func formField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Times New Roman", size: 14))
                .bold()

            TextField("", text: text)
                .font(.custom("Times New Roman", size: 12))
                .padding(10)
                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private func formEditor(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Times New Roman", size: 14))
                .bold()

            TextEditor(text: text)
                .font(.custom("Times New Roman", size: 12))
                .frame(minHeight: 90)
                .padding(8)
                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Image picker
    private var imagePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Фото для урока (необязательно)")
                .font(.custom("Times New Roman", size: 14))
                .bold()

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Выбрать изображение", systemImage: "photo")
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }

            if let data = imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Save
    private func saveLessonPlan() {
        let plan = LessonPlan(
            title: title,
            subject: subject,
            grade: grade,
            objectives: objectives,
            lessonFlow: lessonFlow,
            assessment: assessment,
            homework: homework,
            imageData: imageData
        )

        modelContext.insert(plan)

        createdPlan = plan
        showPreview = true
    }

    // MARK: - AI
    private func fillWithAI() async {
        isFillingWithAI = true
        defer { isFillingWithAI = false }

        let service = GroqService()

        let prompt = """
        Ты — опытный учитель.

        Составь ПОУРОЧНЫЙ ПЛАН по строгой структуре.

        Предмет: \(subject)
        Класс: \(grade)
        Тема урока: \(title)

        Ответ верни СТРОГО в формате:

        ЦЕЛИ:
        1. ...
        2. ...

        ХОД:
        1. Организационный момент
        2. Актуализация знаний
        3. Объяснение нового материала
        4. Закрепление
        5. Рефлексия

        ОЦЕНИВАНИЕ:
        - ...
        - ...

        ДОМАШНЕЕ:
        ...

        НЕ добавляй лишний текст.
        """

        do {
            let response = try await service.generateResponse(
                for: [Message(role: .user, text: prompt)]
            )
            parseStructuredAIResponse(response)
        } catch {
            print("AI error:", error.localizedDescription)
        }
    }


    private func parseStructuredAIResponse(_ text: String) {
        objectives  = extractBlock(from: text, start: "ЦЕЛИ:", end: "ХОД:")
        lessonFlow  = extractBlock(from: text, start: "ХОД:", end: "ОЦЕНИВАНИЕ:")
        assessment  = extractBlock(from: text, start: "ОЦЕНИВАНИЕ:", end: "ДОМАШНЕЕ:")
        homework    = extractBlock(from: text, start: "ДОМАШНЕЕ:", end: nil)
    }

    private func extractBlock(
        from text: String,
        start: String,
        end: String?
    ) -> String {

        guard let startRange = text.range(of: start) else {
            return ""
        }

        let startIndex = startRange.upperBound
        let remainingText = text[startIndex...]

        if let end = end,
           let endRange = remainingText.range(of: end) {
            return remainingText[..<endRange.lowerBound]
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return remainingText
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }


}
