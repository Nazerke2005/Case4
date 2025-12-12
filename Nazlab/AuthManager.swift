//
//  AuthManager.swift
//  Nazlab
//
//  Created by Nazerke Turganбек on 11.12.2025.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class AuthManager {
    // Prevent Observation from generating tracking storage for this AppStorage-backed property.
    @ObservationIgnored
    @AppStorage("currentUserEmail") private var storedEmail: String = ""

    var currentUserEmail: String? {
        get { storedEmail.isEmpty ? nil : storedEmail }
        set {
            let normalized = newValue?.lowercased() ?? ""
            storedEmail = normalized
            // Принудительно синхронизируем UserDefaults, чтобы исключить задержки
            UserDefaults.standard.set(normalized, forKey: "currentUserEmail")
            UserDefaults.standard.synchronize()
        }
    }

    var isAuthenticated: Bool {
        currentUserEmail != nil
    }

    func signIn(as email: String) {
        currentUserEmail = email.lowercased()
        #if DEBUG
        print("[Auth] signIn -> email set to:", currentUserEmail ?? "nil")
        #endif
    }

    func signOut() {
        #if DEBUG
        print("[Auth] signOut called. Old email:", currentUserEmail ?? "nil")
        #endif
        currentUserEmail = nil
        // Дополнительно очищаем ключ на всякий случай
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        UserDefaults.standard.synchronize()
        #if DEBUG
        print("[Auth] signOut -> email now:", currentUserEmail ?? "nil")
        #endif
    }
}
