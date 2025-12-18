//
//  ProfileManager.swift
//  Nazlab
//
//  Created by Nazerke Turganбек on 12.12.2025.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class ProfileManager {
    // Persist avatar as Data in UserDefaults via AppStorage.
    // Use ObservationIgnored so @Observable doesn’t try to track the AppStorage wrapper itself.
    @ObservationIgnored
    @AppStorage("profile.avatarData") private var storedAvatarData: Data = Data()

    // Publicly exposed avatar data; reading maps empty Data to nil.
    var avatarData: Data? {
        get { storedAvatarData.isEmpty ? nil : storedAvatarData }
        set { storedAvatarData = newValue ?? Data() }
    }

    // Convenience computed Image for UI that wants a SwiftUI Image
    var avatarImage: Image? {
        guard let data = avatarData, let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }

    // Called by ProfileView when a new image is picked
    func setAvatar(data: Data) {
        avatarData = data
    }

    // Optional helper to clear avatar
    func clearAvatar() {
        avatarData = nil
    }
}

