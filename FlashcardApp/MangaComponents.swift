//
//  MangaComponents.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import SwiftUI

// MARK: - Shared Button Style

struct MangaButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Halftone Pattern Background

struct HalftonePattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let columns = 20
                let rows = 40
                let dotSize: CGFloat = 8
                let spacing = geometry.size.width / CGFloat(columns)
                
                for row in 0..<rows {
                    for col in 0..<columns {
                        let x = CGFloat(col) * spacing
                        let y = CGFloat(row) * spacing
                        path.addEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
                    }
                }
            }
            .fill(Color.white)
        }
    }
}
