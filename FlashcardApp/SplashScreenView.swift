//
//  SplashScreenView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 27.12.25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Twin characters asset
                    Image("twin_start")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 300)
                        .scaleEffect(scale)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // App Name with Manga Style
                    VStack(spacing: 8) {
                        // Japanese subtitle
                        Text("学習")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .opacity(0.8)
                        
                        // Main app name with manga outline
                        ZStack {
                            // Shadow/outline
                            Text("BREDENBOOK")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 4, y: 4)
                            
                            // Main text with gradient
                            Text("BREDENBOOK")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: .orange.opacity(0.8), radius: 20)
                        }
                        
                        // Tagline - Random Monty Python phrase
                        Text(randomHovercraftPhrase())
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .tracking(1)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                    
                    // Loading indicator (optional)
                    ProgressView()
                        .tint(.orange)
                        .scaleEffect(0.8)
                        .padding(.bottom, 60)
                }
                .opacity(opacity)
            }
            .onAppear {
                // Scale in animation
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    scale = 1.0
                }
                
                // Fade out and transition after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isActive = true
                    }
                }
            }
        }
    }
    
    // Random Monty Python phrase selector
    private func randomHovercraftPhrase() -> String {
        let phrases = [
            "My hovercraft is full of eels",
            "Mein Luftkissenboot ist voller Aale",
            "Mi aerodeslizador está lleno de anguilas"
        ]
        return phrases.randomElement() ?? phrases[0]
    }
}

#Preview {
    SplashScreenView()
}
