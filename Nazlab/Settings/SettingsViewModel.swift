//
//  SettingsViewModel.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    @AppStorage("app.theme") var theme: Int = 0 {
        willSet { objectWillChange.send() }
    }
    @AppStorage("app.language") var language: String = "ru" {
        willSet { objectWillChange.send() }
    }
    @AppStorage("app.notifications") var notificationsEnabled = true {
        willSet { objectWillChange.send() }
    }
}
