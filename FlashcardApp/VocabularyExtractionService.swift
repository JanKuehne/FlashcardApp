//
//  VocabularyExtractionService.swift
//  FlashcardApp
//
//  Created by Assistant on 29.12.25.
//

import Foundation

/// Service for extracting vocabulary pairs from OCR text using GPT-4o or GPT-4o-mini
class VocabularyExtractionService {
    
    private let apiKey: String
    private let model: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    /// Initialize with API key and optional model selection
    /// - Parameters:
    ///   - apiKey: OpenAI API key
    ///   - useAdvancedModel: If true, uses GPT-4o (more accurate, ~10x cost). If false, uses GPT-4o-mini (faster, cheaper)
    init(apiKey: String, useAdvancedModel: Bool = false) {
        self.apiKey = apiKey
        self.model = useAdvancedModel ? "gpt-4o" : "gpt-4o-mini"
    }
    
    // MARK: - Main Extraction Method
    
    /// Extracts vocabulary pairs from OCR text using GPT-4o or GPT-4o-mini
    /// - Parameters:
    ///   - ocrText: Raw text from camera OCR
    ///   - sourceLanguage: Language on left side (e.g., "Spanish")
    ///   - targetLanguage: Language on right side (e.g., "German")
    ///   - generateExamples: If true, generates example sentences for each word
    /// - Returns: Array of vocabulary pairs
    func extractVocabulary(
        from ocrText: String,
        sourceLanguage: String = "Spanish",
        targetLanguage: String = "German",
        generateExamples: Bool = true
    ) async throws -> [VocabularyPair] {
        
        // Build the request
        let request = try buildRequest(
            ocrText: ocrText,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            generateExamples: generateExamples
        )
        
        // Send to OpenAI
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ExtractionError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw ExtractionError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        // Parse response
        let pairs = try parseResponse(data)
        
        print("✅ Extracted \(pairs.count) vocabulary pairs")
        return pairs
    }
    
    // MARK: - Request Building
    
    private func buildRequest(
        ocrText: String,
        sourceLanguage: String,
        targetLanguage: String,
        generateExamples: Bool
    ) throws -> URLRequest {
        
        guard let url = URL(string: baseURL) else {
            throw ExtractionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let systemPrompt = buildSystemPrompt(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            generateExamples: generateExamples
        )
        
        let userPrompt = """
        Extract vocabulary pairs from this OCR text. The text may be messy or out of order.
        
        OCR Text:
        \(ocrText)
        """
        
        let maxTokens = generateExamples ? 2000 : 1000
        
        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "response_format": ["type": "json_object"],
            "temperature": 0.1,
            "max_tokens": maxTokens
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        return request
    }
    
    private func buildSystemPrompt(sourceLanguage: String, targetLanguage: String, generateExamples: Bool) -> String {
        let exampleInstruction = generateExamples ? 
        """
        6. Generate a simple, natural example sentence in \(sourceLanguage) for EACH word
        7. Example sentences should be beginner-friendly (A1-B1 level)
        """ : ""
        
        let exampleJSON = generateExamples ?
        """
        {"source": "\(sourceLanguage) word", "target": "\(targetLanguage) word", "example": "Simple sentence using the word"}
        """ :
        """
        {"source": "\(sourceLanguage) word", "target": "\(targetLanguage) word"}
        """
        
        return """
        You are a vocabulary extraction assistant for language learning textbooks.
        
        Your task:
        1. Extract ALL \(sourceLanguage)-\(targetLanguage) vocabulary pairs from OCR text of a vocabulary list
        2. The text contains two columns: \(sourceLanguage) on the left, \(targetLanguage) on the right
        3. Match words that appear near each other horizontally (same line or close lines)
        4. Include articles (la, el, die, der, das) with nouns when present
        5. Include exclamation marks in greetings (¡Hola!, ¡Buenas tardes!)
        6. Extract EVERY clear pair - be thorough but accurate
        \(exampleInstruction)
        
        IMPORTANT PATTERNS IN TEXTBOOKS:
        - Pairs often appear as: "Spanish word    German word" (with spaces between)
        - Articles and nouns together: "la montaña" → "der Berg"
        - Phrases with punctuation: "¡Hola!" → "Hallo!"
        - Verb forms in parentheses: "me llamo (llamarse)" → just use "me llamo"
        - Gender markers: "el/la amigo/-a" → split into "el amigo" and "la amiga"
        
        VALIDATION:
        - "source" must be in \(sourceLanguage) (look for Spanish characters: ñ, á, é, í, ó, ú, ¡, ¿)
        - "target" must be in \(targetLanguage) (look for German characters: ä, ö, ü, ß)
        - Both sides should NEVER be the same language
        - If unsure, still include it - better to extract more than miss words
        
        Return JSON format:
        {
          "pairs": [
            \(exampleJSON),
            ...
          ]
        }
        
        Example Input:
        ```
        ¡Buenas tardes!  Guten Tag!
        tú               du
        la montaña       der Berg
        ```
        
        Example Output: {
          "pairs": [
            {"source": "¡Buenas tardes!", "target": "Guten Tag!", "example": "¡Buenas tardes! ¿Cómo estás?"},
            {"source": "tú", "target": "du", "example": "Tú eres mi amigo."},
            {"source": "la montaña", "target": "der Berg", "example": "La montaña es muy alta."}
          ]
        }
        
        EXTRACT ALL PAIRS - Don't be conservative!
        """
    }
    
    // MARK: - Response Parsing
    
    private func parseResponse(_ data: Data) throws -> [VocabularyPair] {
        let decoder = JSONDecoder()
        
        // Parse OpenAI response
        let response = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content else {
            throw ExtractionError.noContent
        }
        
        // Parse the JSON content from the message
        guard let contentData = content.data(using: .utf8) else {
            throw ExtractionError.invalidJSON
        }
        
        let vocabularyResponse = try decoder.decode(VocabularyResponse.self, from: contentData)
        
        // Convert to VocabularyPair objects
        return vocabularyResponse.pairs.map { pair in
            VocabularyPair(
                source: pair.source.trimmingCharacters(in: .whitespacesAndNewlines),
                target: pair.target.trimmingCharacters(in: .whitespacesAndNewlines),
                example: pair.example?.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
    
    // MARK: - Cost Tracking
    
    /// Estimates the cost of a request based on token count
    func estimateCost(ocrText: String, generateExamples: Bool = true) -> Double {
        // Rough estimate: 1 token ≈ 4 characters
        let promptSize = generateExamples ? 700 : 500
        let inputTokens = (ocrText.count + promptSize) / 4
        let outputTokens = generateExamples ? 500 : 250
        
        // Pricing (Dec 2024)
        let (inputCost, outputCost): (Double, Double) = {
            if model == "gpt-4o" {
                // GPT-4o: $2.50 / 1M input, $10.00 / 1M output
                return (2.50 / 1_000_000, 10.00 / 1_000_000)
            } else {
                // GPT-4o-mini: $0.150 / 1M input, $0.600 / 1M output
                return (0.150 / 1_000_000, 0.600 / 1_000_000)
            }
        }()
        
        return Double(inputTokens) * inputCost + Double(outputTokens) * outputCost
    }
    
    /// Returns the model name currently in use
    var currentModel: String {
        return model
    }
}

// MARK: - Models

/// Represents a vocabulary pair extracted by the LLM
struct VocabularyPair: Codable, Identifiable {
    let id = UUID()
    let source: String  // Spanish word
    let target: String  // German word
    let example: String?  // Optional example sentence in source language
    
    enum CodingKeys: String, CodingKey {
        case source, target, example
    }
}

/// Response structure from the LLM
private struct VocabularyResponse: Codable {
    let pairs: [PairData]
    
    struct PairData: Codable {
        let source: String
        let target: String
        let example: String?
    }
}

/// OpenAI API response structure
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

// MARK: - Errors

enum ExtractionError: LocalizedError {
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
            return "No content in response"
        case .invalidJSON:
            return "Could not parse JSON response"
        case .noAPIKey:
            return "OpenAI API key not configured"
        }
    }
}
