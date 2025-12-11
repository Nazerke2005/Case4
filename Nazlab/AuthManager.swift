//
//  AuthManager.swift
//  Nazlab
//
//  Created by Nazerke Turganbek on 11.12.2025.
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
        set { storedEmail = newValue?.lowercased() ?? "" }
    }

    var isAuthenticated: Bool {
        currentUserEmail != nil
    }

    func signIn(as email: String) {
        currentUserEmail = email.lowercased()
    }

    func signOut() {
        currentUserEmail = nil
    }
}
