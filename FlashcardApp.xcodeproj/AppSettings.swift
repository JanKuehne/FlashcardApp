//
//  AppSettings.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import Foundation

/// Centralized app settings and configuration
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // MARK: - User Defaults Keys
    private enum Keys {
        static let apiKey = "openai_api_key"
        static let openAIAPIKey = "openai_api_key" // Alias for compatibility
        static let useMockLLM = "use_mock_llm"
        static let userName = "user_name"
        static let lastTargetLanguage = "last_target_language"
    }
    
    // MARK: - Published Properties
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: Keys.apiKey)
        }
    }
    
    // Alias for compatibility with SettingsView
    var openAIAPIKey: String {
        get { apiKey }
        set { apiKey = newValue }
    }
    
    @Published var useMockLLM: Bool {
        didSet {
            UserDefaults.standard.set(useMockLLM, forKey: Keys.useMockLLM)
        }
    }
    
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: Keys.userName)
        }
    }
    
    @Published var lastTargetLanguage: String {
        didSet {
            UserDefaults.standard.set(lastTargetLanguage, forKey: Keys.lastTargetLanguage)
        }
    }
    
    // Computed property for LLM availability
    var isLLMEnabled: Bool {
        !useMockLLM && !apiKey.isEmpty
    }
    
    // MARK: - Initialization
    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: Keys.apiKey) ?? ""
        self.useMockLLM = UserDefaults.standard.bool(forKey: Keys.useMockLLM)
        self.userName = UserDefaults.standard.string(forKey: Keys.userName) ?? ""
        self.lastTargetLanguage = UserDefaults.standard.string(forKey: Keys.lastTargetLanguage) ?? "en"
    }
    
    // MARK: - Helper Methods
    
    /// Get language flag emoji for a language code
    func languageFlag(_ code: String) -> String {
        switch code {
        case "es": return "🇪🇸"
        case "en": return "🇬🇧"
        default: return "🇬🇧"
        }
    }
    
    /// Get language name for a language code
    func languageName(_ code: String) -> String {
        switch code {
        case "es": return "Español"
        case "en": return "English"
        default: return "English"
        }
    }
    
    /// Get localized success message
    func successMessage(for language: String, userName: String) -> String {
        let name = userName.isEmpty ? "Champion" : userName
        
        switch language {
        case "es":
            return "¡Excelente, \(name)!"
        case "en":
            return "Well done, \(name)!"
        default:
            return "Great job, \(name)!"
        }
    }
    
    /// Create LLM service based on current settings
    func createLLMService() -> LLMService {
        if useMockLLM || apiKey.isEmpty {
            return MockLLMService()
        } else {
            return OpenAIService(apiKey: apiKey)
        }
    }
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        apiKey = ""
        useMockLLM = false
        userName = ""
        lastTargetLanguage = "en"
    }
}
