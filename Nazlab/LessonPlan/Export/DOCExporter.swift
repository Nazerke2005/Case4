//
//  DOCExporter.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation

enum DOCExporter {

    static func makeDOC(_ plan: LessonPlan) -> URL? {

        let html = """
        <html>
        <head>
        <meta charset="utf-8">
        <style>
        body {
            font-family: "Times New Roman";
            font-size: 14pt;
        }
        h1 {
            font-size: 18pt;
        }
        </style>
        </head>
        <body>

        <h1>\(plan.title)</h1>

        <p><b>Предмет:</b> \(plan.subject)</p>
        <p><b>Класс:</b> \(plan.grade)</p>

        <p><b>Цели урока:</b><br>\(plan.objectives)</p>
        <p><b>Ход урока:</b><br>\(plan.lessonFlow)</p>
        <p><b>Оценивание:</b><br>\(plan.assessment)</p>
        <p><b>Домашнее задание:</b><br>\(plan.homework)</p>

        </body>
        </html>
        """

        let fileName = "\(plan.title.replacingOccurrences(of: " ", with: "_")).doc"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try html.data(using: .utf8)?.write(to: url)
            return url
        } catch {
            print("DOC error:", error)
            return nil
        }
    }
}
