//
//  LessonPlanExporters.swift
//  Nazlab
//
//  Created by Assistant on 14.12.2025.
//

import SwiftUI
import UIKit
import PDFKit

enum LessonPlanPDFExporter {
    static func makePDF(_ plan: LessonPlan) -> URL? {
        let renderer = LessonPlanPDFRenderer(plan: plan)
        return renderer.render()
    }

    private struct LessonPlanPDFRenderer {
        let plan: LessonPlan

        func render() -> URL? {
            // Уақытша файл жолы
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("LessonPlan_\(plan.id.uuidString).pdf")

            // Парақ өлшемі (A4)
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // 72 dpi * A4 inches
            let margin: CGFloat = 36

            UIGraphicsBeginPDFContextToFile(tempURL.path, .zero, nil)
            defer { UIGraphicsEndPDFContext() }

            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

            // Контентті салу
            let contentWidth = pageRect.width - margin * 2
            var cursor = CGPoint(x: margin, y: margin)

            func draw(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 6) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = spacing
                paragraph.alignment = .left

                let attrs: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]

                let attributed = NSAttributedString(string: text, attributes: attrs)
                let bounding = attributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )

                if cursor.y + bounding.height > pageRect.height - margin {
                    // жаңа парақ
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                    cursor = CGPoint(x: margin, y: margin)
                }

                attributed.draw(with: CGRect(origin: cursor, size: CGSize(width: contentWidth, height: bounding.height)),
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                context: nil)
                cursor.y += bounding.height + 12
            }

            // Тақырып
            draw(plan.title, font: .systemFont(ofSize: 22, weight: .bold))

            // Мета
            draw("Предмет: \(plan.subject)\nКласс: \(plan.grade)\nДата: \(plan.createdAt.formatted(date: .numeric, time: .omitted))",
                 font: .systemFont(ofSize: 12), color: .secondaryLabel, spacing: 3)

            // Сурет (егер бар болса)
            if let data = plan.imageData, let img = UIImage(data: data) {
                let maxW = contentWidth
                let ratio = img.size.height / img.size.width
                let targetSize = CGSize(width: maxW, height: maxW * ratio)

                if cursor.y + targetSize.height > pageRect.height - margin {
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                    cursor = CGPoint(x: margin, y: margin)
                }

                img.draw(in: CGRect(origin: cursor, size: targetSize))
                cursor.y += targetSize.height + 16
            }

            // Бөлімдер
            draw("Цели урока", font: .systemFont(ofSize: 16, weight: .semibold))
            draw(plan.objectives, font: .systemFont(ofSize: 13))

            draw("Ход урока", font: .systemFont(ofSize: 16, weight: .semibold))
            draw(plan.lessonFlow, font: .systemFont(ofSize: 13))

            draw("Оценивание", font: .systemFont(ofSize: 16, weight: .semibold))
            draw(plan.assessment, font: .systemFont(ofSize: 13))

            draw("Домашнее задание", font: .systemFont(ofSize: 16, weight: .semibold))
            draw(plan.homework, font: .systemFont(ofSize: 13))

            ctx.flush()
            return tempURL
        }
    }
}

enum TextExporter {
    static func makeTXT(_ plan: LessonPlan) -> URL? {
        let filename = "LessonPlan_\(plan.id.uuidString).txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        let text = """
        \(plan.title)
        Предмет: \(plan.subject)
        Класс: \(plan.grade)
        Дата: \(plan.createdAt.formatted(date: .numeric, time: .omitted))

        Цели урока:
        \(plan.objectives)

        Ход урока:
        \(plan.lessonFlow)

        Оценивание:
        \(plan.assessment)

        Домашнее задание:
        \(plan.homework)
        """

        do {
            try text.data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            print("TXT export error:", error.localizedDescription)
            return nil
        }
    }
}
