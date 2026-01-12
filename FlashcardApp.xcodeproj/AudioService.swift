//
//  AudioService.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.01.26.
//

import AVFoundation
import UIKit
import Combine

/// Service for managing text-to-speech audio pronunciation
/// Supports German, English, and Spanish with configurable auto-play
class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    
    // MARK: - Auto-Play Mode
    
    enum AutoPlayMode: String, CaseIterable {
        case disabled = "Aus"
        case frontOnly = "Nur Vorderseite"
        case backOnly = "Nur Rückseite"  // Recommended default
        case bothSides = "Beide Seiten"
        
        var localizedName: String {
            return self.rawValue
        }
    }
    
    // MARK: - Settings (UserDefaults backed)
    
    var autoPlayMode: AutoPlayMode {
        get {
            let raw = UserDefaults.standard.string(forKey: "audioAutoPlayMode") ?? AutoPlayMode.backOnly.rawValue
            return AutoPlayMode(rawValue: raw) ?? .backOnly
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "audioAutoPlayMode")
        }
    }
    
    var autoPlayDelay: TimeInterval {
        get {
            let delay = UserDefaults.standard.double(forKey: "audioAutoPlayDelay")
            return delay > 0 ? delay : 0.5 // Default 0.5 seconds
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "audioAutoPlayDelay")
        }
    }
    
    var speechRate: Float {
        get {
            let rate = UserDefaults.standard.float(forKey: "audioSpeechRate")
            return rate > 0 ? rate : 0.5 // Default to 0.5x (normal speed)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "audioSpeechRate")
        }
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        
        // Set default values on first launch
        if UserDefaults.standard.object(forKey: "audioSpeechRate") == nil {
            speechRate = 0.5
        }
        if UserDefaults.standard.object(forKey: "audioAutoPlayDelay") == nil {
            autoPlayDelay = 0.5
        }
        if UserDefaults.standard.object(forKey: "audioAutoPlayMode") == nil {
            autoPlayMode = .backOnly
        }
    }
    
    // MARK: - Public Methods
    
    /// Speak text in specified language
    /// - Parameters:
    ///   - text: The text to speak
    ///   - language: Language code (e.g., "de-DE", "en-US", "es-ES")
    func speak(_ text: String, language: String) {
        // Validate input
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("⚠️ AudioService: Empty text, skipping speech")
            return
        }
        
        // Stop current speech if any
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = speechRate
        
        // Configure for better quality
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        // Update state
        isSpeaking = true
        
        // Speak
        synthesizer.speak(utterance)
        
        print("🔊 AudioService: Speaking '\(text)' in \(language)")
    }
    
    /// Speak German word
    func speakGerman(_ text: String) {
        speak(text, language: "de-DE")
    }
    
    /// Speak English word (US accent)
    func speakEnglish(_ text: String) {
        speak(text, language: "en-US")
    }
    
    /// Speak Spanish word (Spain accent)
    func speakSpanish(_ text: String) {
        speak(text, language: "es-ES")
    }
    
    /// Speak text based on language code
    /// - Parameters:
    ///   - text: The text to speak
    ///   - languageCode: Two-letter language code ("de", "en", "es")
    func speak(_ text: String, languageCode: String) {
        switch languageCode {
        case "de":
            speakGerman(text)
        case "en":
            speakEnglish(text)
        case "es":
            speakSpanish(text)
        default:
            speakEnglish(text) // Fallback to English
        }
    }
    
    /// Stop current speech
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            isSpeaking = false
            print("🔇 AudioService: Speech stopped")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Check if a voice is available for a language
    func isVoiceAvailable(for language: String) -> Bool {
        return AVSpeechSynthesisVoice(language: language) != nil
    }
    
    /// Get all available voices for a language
    func availableVoices(for language: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix(language)
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
        print("✅ AudioService: Speech finished")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
        print("⏹️ AudioService: Speech cancelled")
    }
}
