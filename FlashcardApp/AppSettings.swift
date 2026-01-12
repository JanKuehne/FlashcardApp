//
//  AppSettings.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import Foundation
import Observation

/// App-wide settings and configuration
@Observable
class AppSettings {
    
    // MARK: - Singleton
    
    static let shared = AppSettings()
    
    // MARK: - Properties
    
    /// User's name for personalized messages
    var userName: String {
        get {
            UserDefaults.standard.string(forKey: "userName") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userName")
        }
    }
    
    /// Last selected target language (for AddCardView)
    var lastTargetLanguage: String {
        get {
            UserDefaults.standard.string(forKey: "lastTargetLanguage") ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastTargetLanguage")
        }
    }
    
    // MARK: - Language Helpers
    
    /// Available target languages
    let availableLanguages = ["en", "es"]
    
    /// Get flag emoji for language code
    func languageFlag(_ code: String) -> String {
        switch code {
        case "es": return "🇪🇸"
        case "en": return "🇬🇧"
        default: return "🇬🇧"
        }
    }
    
    /// Get language name
    func languageName(_ code: String) -> String {
        switch code {
        case "es": return "Español"
        case "en": return "English"
        default: return "English"
        }
    }
    
    /// Get success message in target language
    func successMessage(for language: String, userName: String) -> String {
        let name = userName.isEmpty ? "" : ", \(userName.uppercased())"
        
        switch language {
        case "es":
            return "¡MUY BIEN\(name)!"
        case "en":
            return "WELL DONE\(name)!"
        default:
            return "WELL DONE\(name)!"
        }
    }
    
    /// OpenAI API Key (stored in UserDefaults)
    var openAIAPIKey: String {
        get {
            UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "openAIAPIKey")
        }
    }
    
    /// Whether LLM features are enabled
    var isLLMEnabled: Bool {
        !openAIAPIKey.isEmpty && openAIAPIKey.starts(with: "sk-")
    }
    
    /// Use mock LLM service for testing (doesn't require API key)
    var useMockLLM: Bool {
        get {
            UserDefaults.standard.bool(forKey: "useMockLLM")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "useMockLLM")
        }
    }
    
    /// Google Cloud Vision API Key (stored in UserDefaults)
    var googleVisionAPIKey: String {
        get {
            UserDefaults.standard.string(forKey: "googleVisionAPIKey") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "googleVisionAPIKey")
        }
    }
    
    /// Whether Google Vision OCR is available
    var isGoogleVisionEnabled: Bool {
        !googleVisionAPIKey.isEmpty && googleVisionAPIKey.starts(with: "AIza")
    }
    
    // MARK: - Initialization
    
    private init() {
        // Enable mock by default for development
        if openAIAPIKey.isEmpty && !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            useMockLLM = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    // MARK: - LLM Service Factory
    
    func createLLMService() -> LLMService {
        if useMockLLM {
            return MockLLMService()
        } else if !openAIAPIKey.isEmpty {
            return LLMService(apiKey: openAIAPIKey)
        } else {
            // Fallback to mock if no API key
            return MockLLMService()
        }
    }
}
