// FlowLayout.swift
import SwiftUI

/// A simple flow layout that arranges views horizontally and wraps to the next line when needed.
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    private let items: Data
    private let spacing: CGFloat
    private let alignment: HorizontalAlignment
    private let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    init(
        _ items: Data,
        spacing: CGFloat = 8,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: Alignment(horizontal: alignment, vertical: .top)) {
            ForEach(Array(items), id: \.self) { item in
                content(item)
                    .alignmentGuide(.leading) { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0
                            height -= d.height + spacing
                        }
                        let result = width
                        if item == items.last {
                            width = 0 // last item, reset
                        } else {
                            width -= d.width + spacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last {
                            height = 0 // last item, reset
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear { totalHeight = -height }
                    .onChange(of: items.count) { _, _ in
                        DispatchQueue.main.async {
                            totalHeight = -height
                        }
                    }
            }
        )
    }
}
