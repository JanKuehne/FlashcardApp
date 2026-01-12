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
/// Uses AVSpeechSynthesizer for offline, free audio playback
class AudioService: ObservableObject {
    static let shared = AudioService()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var delegate: SpeechDelegate?
    
    @Published var isSpeaking = false
    
    // MARK: - Auto-Play Settings
    
    /// Auto-play modes for review sessions
    enum AutoPlayMode: String, CaseIterable, Identifiable {
        case disabled = "Aus"
        case frontOnly = "Nur Vorderseite"
        case backOnly = "Nur Rückseite"
        case bothSides = "Beide Seiten"
        
        var id: String { rawValue }
    }
    
    /// Current auto-play mode
    var autoPlayMode: AutoPlayMode {
        get {
            let raw = UserDefaults.standard.string(forKey: "audioAutoPlayMode") ?? AutoPlayMode.backOnly.rawValue
            return AutoPlayMode(rawValue: raw) ?? .backOnly
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "audioAutoPlayMode")
        }
    }
    
    /// Delay before auto-playing audio (in seconds)
    var autoPlayDelay: TimeInterval {
        get {
            let delay = UserDefaults.standard.double(forKey: "audioAutoPlayDelay")
            return delay > 0 ? delay : 0.5 // Default 0.5 seconds
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "audioAutoPlayDelay")
        }
    }
    
    // MARK: - Speech Settings
    
    /// Speech rate for AVSpeechSynthesizer (0.0 - 1.0)
    /// Note: AVSpeechUtterance's default rate is approximately 0.5
    /// Values are mapped for user-friendly display:
    ///   Langsam (Slow) = 0.3
    ///   Normal = 0.5 (AVSpeechUtterance default)
    ///   Schnell (Fast) = 0.65
    var speechRate: Float {
        get {
            let rate = UserDefaults.standard.float(forKey: "audioSpeechRate")
            // Default to 0.5 (normal speed) if not set
            return rate > 0 ? rate : 0.5
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "audioSpeechRate")
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // Set up audio session for playback
        configureAudioSession()
        
        // Set up delegate for speaking state tracking
        delegate = SpeechDelegate(audioService: self)
        synthesizer.delegate = delegate
        
        // Initialize default settings if needed
        if UserDefaults.standard.object(forKey: "audioSpeechRate") == nil {
            speechRate = 0.5  // Normal speed (AVSpeechUtterance default)
        }
        if UserDefaults.standard.object(forKey: "audioAutoPlayMode") == nil {
            autoPlayMode = .backOnly
        }
        if UserDefaults.standard.object(forKey: "audioAutoPlayDelay") == nil {
            autoPlayDelay = 0.5
        }
    }
    
    // MARK: - Audio Session Configuration
    
    private func configureAudioSession() {
        do {
            // Configure audio session to allow speech without interrupting background audio
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    // MARK: - Text-to-Speech Methods
    
    /// Speak text in specified language
    /// - Parameters:
    ///   - text: Text to speak
    ///   - language: Language code (e.g., "de-DE", "en-US", "es-ES")
    func speak(_ text: String, language: String) {
        // Validate text
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            print("Cannot speak empty text")
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
        
        // Adjust pitch and volume for better quality
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Haptic feedback on start
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        // Update speaking state
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
        
        // Speak the utterance
        synthesizer.speak(utterance)
    }
    
    /// Speak German text
    func speakGerman(_ text: String) {
        speak(text, language: "de-DE")
    }
    
    /// Speak English text (US accent)
    func speakEnglish(_ text: String) {
        speak(text, language: "en-US")
    }
    
    /// Speak Spanish text (Spain accent)
    func speakSpanish(_ text: String) {
        speak(text, language: "es-ES")
    }
    
    /// Speak text for target language based on language code
    /// - Parameters:
    ///   - text: Text to speak
    ///   - targetLanguage: Language code ("en", "es")
    func speakTargetLanguage(_ text: String, targetLanguage: String) {
        switch targetLanguage {
        case "es":
            speakSpanish(text)
        case "en":
            speakEnglish(text)
        default:
            speakEnglish(text)
        }
    }
    
    /// Stop current speech immediately
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    // MARK: - Available Voices
    
    /// Get available voices for a language
    func availableVoices(for languageCode: String) -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: languageCode) }
    }
}

// MARK: - Speech Delegate

/// Delegate to track speech synthesis state
private class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate {
    weak var audioService: AudioService?
    
    init(audioService: AudioService) {
        self.audioService = audioService
        super.init()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.audioService?.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.audioService?.isSpeaking = false
        }
    }
}
