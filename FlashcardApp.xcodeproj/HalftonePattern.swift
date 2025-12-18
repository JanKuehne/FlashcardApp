//
//  HalftonePattern.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import SwiftUI

/// Manga-style halftone dot pattern for background texture
struct HalftonePattern: View {
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let dotSpacing: CGFloat = 8
                let dotSize: CGFloat = 3
                
                let cols = Int(size.width / dotSpacing) + 1
                let rows = Int(size.height / dotSpacing) + 1
                
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * dotSpacing
                        let y = CGFloat(row) * dotSpacing
                        
                        // Create subtle variation in dot size for organic feel
                        let variation = sin(CGFloat(row + col) * 0.5) * 0.3 + 0.7
                        let radius = dotSize * variation / 2
                        
                        let rect = CGRect(
                            x: x - radius,
                            y: y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )
                        
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(.white)
                        )
                    }
                }
            }
        }
    }
}

/// Manga-style speed lines for action effects
struct SpeedLines: View {
    let lineCount: Int
    let color: Color
    let opacity: Double
    
    init(lineCount: Int = 20, color: Color = .white, opacity: Double = 0.3) {
        self.lineCount = lineCount
        self.color = color
        self.opacity = opacity
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<lineCount, id: \.self) { index in
                    Path { path in
                        let angle = Double(index) * (360.0 / Double(lineCount))
                        let radians = angle * .pi / 180
                        
                        let startRadius = geometry.size.width * 0.3
                        let endRadius = geometry.size.width * 1.5
                        
                        let centerX = geometry.size.width / 2
                        let centerY = geometry.size.height / 2
                        
                        let startX = centerX + cos(radians) * startRadius
                        let startY = centerY + sin(radians) * startRadius
                        let endX = centerX + cos(radians) * endRadius
                        let endY = centerY + sin(radians) * endRadius
                        
                        path.move(to: CGPoint(x: startX, y: startY))
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(color.opacity(opacity), lineWidth: 2)
                }
            }
        }
    }
}

/// Impact star burst effect
struct ImpactStars: View {
    let starCount: Int
    let color: Color
    let size: CGFloat
    
    init(starCount: Int = 8, color: Color = .yellow, size: CGFloat = 30) {
        self.starCount = starCount
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<starCount, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: size))
                    .foregroundColor(color)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(starCount))))
                    .offset(y: -size * 1.5)
            }
        }
        .rotationEffect(.degrees(22.5))
    }
}

#Preview("Halftone Pattern") {
    ZStack {
        Color.black
        HalftonePattern()
            .opacity(0.1)
    }
    .ignoresSafeArea()
}

#Preview("Speed Lines") {
    ZStack {
        Color.black
        SpeedLines(lineCount: 30, color: .blue, opacity: 0.5)
    }
    .ignoresSafeArea()
}

#Preview("Impact Stars") {
    ZStack {
        Color.black
        ImpactStars(starCount: 12, color: .yellow, size: 40)
    }
    .ignoresSafeArea()
}
