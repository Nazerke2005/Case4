//
//  SettingsView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        Form {
            Section(
                header: Text(NSLocalizedString("language.title", comment: ""))
            ) {
                Picker("",
                       selection: $languageManager.languageCode) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.title)
                            .tag(lang.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle(
            NSLocalizedString("settings.title", comment: "")
        )
    }
}

