//
//  LessonPlanCardView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import Combine
import SwiftUI

struct LessonPlanCardView: View {
    let title: String
    let subtitle: String
    var isSample: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSample {
                Text("Образец")
                    .font(.caption)
                    .padding(8)
                    .background(Color.purple.opacity(0.15), in: Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}
