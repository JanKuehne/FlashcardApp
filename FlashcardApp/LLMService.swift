//
//  LLMService.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import Foundation

/// Service for enriching flashcards using LLM APIs
class LLMService {
    
    // MARK: - Configuration
    
    /// Set this to your OpenAI API key
    /// Get one at: https://platform.openai.com/api-keys
    private let apiKey: String
    
    /// API endpoint
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    /// Model to use (gpt-4o-mini is cheap and fast)
    private let model = "gpt-4o-mini"
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    /// Generate ONLY an example sentence for a vocabulary pair
    /// - Parameters:
    ///   - germanWord: The German word (native language)
    ///   - targetWord: The target language word (English/Spanish)
    ///   - targetLanguage: Language code ("en" or "es")
    /// - Returns: Example sentence in target language, or nil if failed
    func generateExample(germanWord: String, targetWord: String, targetLanguage: String = "en") async throws -> String? {
        
        let languageName = targetLanguage == "es" ? "Spanish" : "English"
        
        // Optimized prompt: short, clear, minimal tokens
        let prompt = """
        Create a simple \(languageName) sentence using "\(targetWord)" for an 8-year-old German learner. Max 8 words, A1 level.
        
        JSON only:
        {"example": "Your sentence here"}
        """
        
        let request = try createRequest(prompt: prompt)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ LLM API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw LLMError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let apiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = apiResponse.choices.first?.message.content else {
            throw LLMError.noContent
        }
        
        // Parse the JSON response from the LLM
        guard let jsonData = content.data(using: .utf8),
              let result = try? JSONDecoder().decode(ExampleResponse.self, from: jsonData) else {
            print("❌ Failed to parse LLM response: \(content)")
            throw LLMError.invalidJSON
        }
        
        return result.example
    }
    
    /// Enrich a flashcard with translation and example sentence
    /// - Parameters:
    ///   - germanWord: The German word to translate
    ///   - language: Target language (default: English)
    /// - Returns: Translation and example sentence, or nil if failed
    /// - Note: DEPRECATED - Use generateExample() for textbook accuracy
    @available(*, deprecated, message: "Use generateExample(germanWord:englishWord:) for textbook accuracy")
    func enrichCard(germanWord: String, targetLanguage: String = "English") async throws -> CardEnrichment? {
        
        let prompt = """
        You are a language learning assistant for children aged 8-10.
        
        Given the German word "\(germanWord)", provide:
        1. The \(targetLanguage) translation (single word or short phrase)
        2. A simple example sentence in German using the word (max 6 words)
        
        Respond ONLY with valid JSON in this exact format:
        {
          "translation": "the \(targetLanguage) word",
          "example": "German sentence using \(germanWord)"
        }
        
        Keep it simple and appropriate for young learners.
        Do not include any other text, explanations, or markdown.
        """
        
        let request = try createRequest(prompt: prompt)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ LLM API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw LLMError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let apiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = apiResponse.choices.first?.message.content else {
            throw LLMError.noContent
        }
        
        // Parse the JSON response from the LLM
        guard let jsonData = content.data(using: .utf8),
              let enrichment = try? JSONDecoder().decode(CardEnrichment.self, from: jsonData) else {
            print("❌ Failed to parse LLM response: \(content)")
            throw LLMError.invalidJSON
        }
        
        return enrichment
    }
    
    // MARK: - Private Methods
    
    private func createRequest(prompt: String) throws -> URLRequest {
        guard let url = URL(string: endpoint) else {
            throw LLMError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Optimized for cost: shorter system message, lower max_tokens, higher temperature for variety
        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": "Return JSON only."  // Minimal system message = fewer tokens
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "temperature": 0.8,  // Higher = more creative, natural sentences
            "max_tokens": 40     // Reduced from 150 (we only need ~10-15 tokens for response)
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return request
    }
}

// MARK: - Models

struct CardEnrichment: Codable {
    let translation: String
    let example: String
}

struct ExampleResponse: Codable {
    let example: String
}

// MARK: - OpenAI API Response Models

private struct OpenAIResponse: Codable {
    let choices: [Choice]
}

private struct Choice: Codable {
    let message: Message
}

private struct Message: Codable {
    let content: String
}

// MARK: - Errors

enum LLMError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case noContent
    case invalidJSON
    case noAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let statusCode, let message):
            return "API Error (\(statusCode)): \(message)"
        case .noContent:
            return "No content in API response"
        case .invalidJSON:
            return "Could not parse response as JSON"
        case .noAPIKey:
            return "API key not configured"
        }
    }
}

// MARK: - OpenAI Service for Production

class OpenAIService: LLMService {
    // Inherits all functionality from LLMService
    // This is the production implementation using the actual OpenAI API
}

// MARK: - Mock Service for Testing

class MockLLMService: LLMService {
    init() {
        super.init(apiKey: "mock")
    }
    
    override func generateExample(germanWord: String, targetWord: String, targetLanguage: String = "en") async throws -> String? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Select appropriate mock examples based on target language
        let mockExamples: [String: String]
        
        if targetLanguage == "es" {
            // Spanish mock examples (10 words, A1 level)
            mockExamples = [
                "Sonne": "El sol brilla.",
                "Mond": "La luna es redonda.",
                "Apfel": "La manzana es roja.",
                "Hund": "El perro ladra.",
                "Katze": "El gato duerme.",
                "Haus": "La casa es grande.",
                "Baum": "El árbol es viejo.",
                "Blume": "La flor es bonita.",
                "Auto": "El coche es rápido.",
                "Buch": "El libro es interesante."
            ]
        } else {
            // English mock examples (10 words, A1 level)
            mockExamples = [
                "Sonne": "The sun shines brightly.",
                "Mond": "The moon is round.",
                "Apfel": "The apple is red.",
                "Hund": "The dog barks loudly.",
                "Katze": "The cat sleeps quietly.",
                "Haus": "The house is big.",
                "Baum": "The tree is old.",
                "Blume": "The flower blooms.",
                "Auto": "The car drives fast.",
                "Buch": "The book is interesting."
            ]
        }
        
        if let example = mockExamples[germanWord] {
            return example
        }
        
        // Fallback for unknown words - generate simple example in target language
        if targetLanguage == "es" {
            return "El/La \(targetWord) es bonito/a."
        } else {
            return "The \(targetWord) is nice."
        }
    }
    
    override func enrichCard(germanWord: String, targetLanguage: String = "English") async throws -> CardEnrichment? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Mock translations
        let mockTranslations: [String: (translation: String, example: String)] = [
            "Sonne": ("sun", "Die Sonne scheint hell."),
            "Mond": ("moon", "Der Mond ist rund."),
            "Stern": ("star", "Der Stern funkelt schön."),
            "Apfel": ("apple", "Der Apfel ist rot."),
            "Hund": ("dog", "Der Hund bellt laut."),
            "Katze": ("cat", "Die Katze schläft leise."),
            "Haus": ("house", "Das Haus ist groß."),
            "Baum": ("tree", "Der Baum ist alt."),
            "Blume": ("flower", "Die Blume blüht bunt."),
            "Auto": ("car", "Das Auto fährt schnell.")
        ]
        
        if let mock = mockTranslations[germanWord] {
            return CardEnrichment(translation: mock.translation, example: mock.example)
        }
        
        // Fallback for unknown words
        return CardEnrichment(
            translation: "\(germanWord.lowercased()) (translation)",
            example: "Der/Die/Das \(germanWord) ist schön."
        )
    }
}
