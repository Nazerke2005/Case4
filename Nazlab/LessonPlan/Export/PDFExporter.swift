//
//  PDFExporter.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//
import Foundation
import PDFKit
import UIKit

enum PDFExporter {

    static func makePDF(_ plan: LessonPlan) -> URL? {

        let pdfMetaData: [String: Any] = [
            kCGPDFContextCreator as String: "LessonPlanBuilderAI",
            kCGPDFContextAuthor as String: "Nazlab"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let fileName = "\(plan.title.replacingOccurrences(of: " ", with: "_")).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()

                let text = buildText(from: plan)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "TimesNewRomanPSMT", size: 14) ?? .systemFont(ofSize: 14)
                ]

                let textRect = CGRect(x: 40, y: 40, width: pageWidth - 80, height: pageHeight - 80)
                text.draw(in: textRect, withAttributes: attributes)
            }
            return url
        } catch {
            print("PDF error:", error)
            return nil
        }
    }

    private static func buildText(from plan: LessonPlan) -> String {
        """
        \(plan.title)

        Предмет: \(plan.subject)
        Класс: \(plan.grade)

        Цели урока:
        \(plan.objectives)

        Ход урока:
        \(plan.lessonFlow)

        Оценивание:
        \(plan.assessment)

        Домашнее задание:
        \(plan.homework)
        """
    }
}
