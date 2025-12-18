//
//  LessonPlanPreviewView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//


import SwiftUI
import UIKit

struct LessonPlanPreviewView: View {

    let plan: LessonPlan

    var body: some View {
        ZStack {
            PinkPurpleFloatingBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text(plan.title)
                        .font(.custom("Times New Roman", size: 22))
                        .bold()

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Предмет: \(plan.subject)")
                        Text("Класс: \(plan.grade)")
                        Text(plan.createdAt.formatted(date: .numeric, time: .omitted))
                    }
                    .font(.custom("Times New Roman", size: 14))
                    .foregroundStyle(.secondary)

                    Divider()

                    if let data = plan.imageData,
                       let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    section("Цели урока", plan.objectives)
                    section("Ход урока", plan.lessonFlow)
                    section("Оценивание", plan.assessment)
                    section("Домашнее задание", plan.homework)

                    Divider()

                    VStack(spacing: 12) {

                        Button {
                            if let url = PDFExporter.makePDF(plan) {
                                share(url)
                            }
                        } label: {
                            Label("📄 Скачать PDF", systemImage: "doc.richtext")
                        }

                        Button {
                            if let url = TextExporter.makeTXT(plan) {
                                share(url)
                            }
                        } label: {
                            Label("📝 Скачать TXT", systemImage: "doc.text")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(22)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                .padding()
            }
        }
        .navigationTitle("Предпросмотр")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Times New Roman", size: 16))
                .bold()
            Text(text)
                .font(.custom("Times New Roman", size: 14))
                .lineSpacing(6)
        }
    }

    private func share(_ url: URL) {
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow?
            .rootViewController?
            .present(vc, animated: true)
    }
}
