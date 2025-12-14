//
//  LessonPlan.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation
import SwiftData

@Model
final class LessonPlan {
    var id: UUID = UUID()
    var title: String
    var subject: String
    var grade: String
    var objectives: String
    var lessonFlow: String
    var assessment: String
    var homework: String
    var imageData: Data?
    var createdAt: Date = Date()

    init(
        title: String,
        subject: String,
        grade: String,
        objectives: String,
        lessonFlow: String,
        assessment: String,
        homework: String,
        imageData: Data? = nil
    ) {
        self.title = title
        self.subject = subject
        self.grade = grade
        self.objectives = objectives
        self.lessonFlow = lessonFlow
        self.assessment = assessment
        self.homework = homework
        self.imageData = imageData
    }

    // convenience: full content for older code that used single "content" string
    var content: String {
        """
        Цели урока:
        \(objectives)

        Ход урока:
        \(lessonFlow)

        Оценивание:
        \(assessment)

        Домашнее задание:
        \(homework)
        """
    }
}
