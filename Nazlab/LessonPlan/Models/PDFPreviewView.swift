//
//  PDFPreviewView.swift
//  Nazlab
//
//  Created by Sabina Bekkuly on 14.12.2025.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.backgroundColor = .systemBackground

        if let doc = PDFDocument(url: url) {
            pdfView.document = doc
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // no-op
    }
}
