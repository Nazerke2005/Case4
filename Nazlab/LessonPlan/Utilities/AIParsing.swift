//
//  AIParsing.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation

// Қарапайым секция экстракторы: "Цели урока:", "Ход урока:", "Оценивание:", "Домашнее задание:"
func extractSection(named name: String, from text: String) -> String {
    // pattern: name followed by any chars until next section header or end
    let pattern = "(?s)\(NSRegularExpression.escapedPattern(for: name))\\s*[:\\-]?\\s*(.*?)(?=(Цели урока|Ход урока|Оценивание|Домашнее задание|$))"
    if let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
        let ns = text as NSString
        if let m = re.firstMatch(in: text, options: [], range: NSRange(location: 0, length: ns.length)) {
            let range = m.range(at: 1)
            return ns.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    return ""
}

// Convenience parse for full AI response
func parseAIResponseIntoSections(_ text: String) -> (objectives: String, flow: String, assessment: String, homework: String) {
    let objectives = extractSection(named: "Цели урока", from: text)
    let flow = extractSection(named: "Ход урока", from: text)
    let assessment = extractSection(named: "Оценивание", from: text)
    let homework = extractSection(named: "Домашнее задание", from: text)
    return (objectives, flow, assessment, homework)
}
