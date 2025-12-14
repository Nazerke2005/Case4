//
//  TypingDotsView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import Combine

struct TypingDotsView: View {
    @State private var phase = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(String(repeating: "•", count: (phase % 3) + 1))
            .font(.headline)
            .onReceive(timer) { _ in
                phase += 1
            }
    }
}
