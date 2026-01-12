//
//  AudioButton.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.01.26.
//

import SwiftUI

/// Reusable audio button component for playing text-to-speech
/// Displays a speaker icon and plays pronunciation when tapped
struct AudioButton: View {
    let text: String
    let language: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var color: Color = .blue
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            audioService.speak(text, language: language)
        } label: {
            ZStack {
                // Background circle
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
                
                // Speaker icon
                Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(color)
                    .symbolEffect(.pulse, options: .repeating, isActive: audioService.isSpeaking)
            }
        }
        .buttonStyle(MangaButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

/// Manga-styled audio button with more visual flair
struct MangaAudioButton: View {
    let text: String
    let language: String
    var size: CGFloat = 60
    
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            audioService.speak(text, language: language)
        } label: {
            ZStack {
                // Manga-style background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                // Black outline
                Circle()
                    .stroke(Color.black, lineWidth: 4)
                    .frame(width: size, height: size)
                
                // Speaker icon with shadow
                ZStack {
                    Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: size * 0.4, weight: .black))
                        .foregroundColor(.black)
                        .offset(x: 2, y: 2)
                    
                    Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: size * 0.4, weight: .black))
                        .foregroundColor(.white)
                        .symbolEffect(.pulse, options: .repeating, isActive: audioService.isSpeaking)
                }
            }
            .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
        }
        .buttonStyle(MangaButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

// MARK: - Preview

#Preview("Simple Audio Button") {
    VStack(spacing: 30) {
        AudioButton(text: "Hallo", language: "de-DE")
        
        AudioButton(text: "Hello", language: "en-US", size: 60, iconSize: 28, color: .green)
        
        AudioButton(text: "Hola", language: "es-ES", size: 80, iconSize: 36, color: .orange)
    }
    .padding()
    .background(Color.black)
}

#Preview("Manga Audio Button") {
    VStack(spacing: 30) {
        MangaAudioButton(text: "Sonne", language: "de-DE")
        
        MangaAudioButton(text: "Sun", language: "en-US", size: 80)
        
        MangaAudioButton(text: "Sol", language: "es-ES", size: 50)
    }
    .padding()
    .background(Color.black)
}
