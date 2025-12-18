//
//  FilterSheetView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//
import Combine
import SwiftUI

struct FilterSheetView: View {
    let subjects: [String]
    @Binding var selection: Set<String>

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("Фильтры")
                .font(.title2.bold())

            Text("Предметы")
                .font(.headline)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        toggle(subject)
                    } label: {
                        Text(subject)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                selection.contains(subject)
                                ? Color.purple.opacity(0.25)
                                : Color.white.opacity(0.2)
                            )
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding()
    }

    private func toggle(_ subject: String) {
        if selection.contains(subject) {
            selection.remove(subject)
        } else {
            selection.insert(subject)
        }
    }
}
