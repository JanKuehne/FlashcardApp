//
//  AppSettings.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import Foundation

/// App-wide settings and configuration
@Observable
class AppSettings {
    
    // MARK: - Singleton
    
    static let shared = AppSettings()
    
    // MARK: - Properties
    
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
