//
//  UserProfile.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftData
import Foundation

@Model
final class UserProfile {
    var name: String
    var email: String
    var subjects: [String]
    var grades: [String]
    var isTeacher: Bool

    init(
        name: String = "",
        email: String = "",
        subjects: [String] = [],
        grades: [String] = [],
        isTeacher: Bool = true
    ) {
        self.name = name
        self.email = email
        self.subjects = subjects
        self.grades = grades
        self.isTeacher = isTeacher
    }
}
