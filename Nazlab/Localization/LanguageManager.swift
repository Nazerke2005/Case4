//
//  Untitled.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case kk = "kk"
    case ru = "ru"
    case en = "en"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .kk: return "Қазақша"
        case .ru: return "Русский"
        case .en: return "English"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

@MainActor
final class LanguageManager: ObservableObject {

    // When this changes, views observing LanguageManager should update.
    @AppStorage("app.language") var languageCode: String = AppLanguage.kk.rawValue {
        didSet {
            // Notify observers when language changes, so environment updates propagate.
            objectWillChange.send()
        }
    }

    var current: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .kk
    }

    func set(_ lang: AppLanguage) {
        languageCode = lang.rawValue
    }

    init() { }
}
