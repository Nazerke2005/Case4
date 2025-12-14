//
//  MessageTimeFormatter.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Foundation

enum MessageTimeFormatter {
    static let shared: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.dateFormat = "HH:mm"
        return f
    }()
}
