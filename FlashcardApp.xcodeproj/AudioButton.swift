//
//  AudioButton.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.01.26.
//

import SwiftUI

/// Reusable audio button component for playing pronunciation
/// Shows animated speaker icon and triggers text-to-speech
struct AudioButton: View {
    let text: String
    let language: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    
    @ObservedObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            audioService.speak(text, language: language)
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                Image(systemName: audioService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.white)
                    .symbolEffect(.pulse, options: .repeating, isActive: audioService.isSpeaking)
            }
            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(MangaButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

/// Compact audio button (smaller, for inline use)
struct CompactAudioButton: View {
    let text: String
    let language: String
    
    @ObservedObject private var audioService = AudioService.shared
    
    var body: some View {
        Button {
            audioService.speak(text, language: language)
        } label: {
            Image(systemName: audioService.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(MangaButtonStyle())
        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

// MARK: - Preview

#Preview("Audio Button") {
    VStack(spacing: 20) {
        AudioButton(text: "Hallo", language: "de-DE")
        AudioButton(text: "hello", language: "en-US", size: 60, iconSize: 24)
        CompactAudioButton(text: "hola", language: "es-ES")
    }
    .padding()
    .background(Color.black)
}
