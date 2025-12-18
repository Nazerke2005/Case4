//
//  FilterChipsView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import Combine

struct FilterChipsView: View {
    let options: [String]
    @Binding var selection: Set<String>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selection.contains(option)

                    Text(option)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            isSelected
                            ? Color.purple.opacity(0.7)
                            : Color.white.opacity(0.25)
                        )
                        .foregroundStyle(isSelected ? .white : .primary)
                        .clipShape(Capsule())
                        .onTapGesture {
                            if isSelected {
                                selection.remove(option)
                            } else {
                                selection.insert(option)
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}
