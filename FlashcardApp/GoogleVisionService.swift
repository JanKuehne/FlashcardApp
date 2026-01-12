//
//  GoogleVisionService.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 31.12.25.
//

import Foundation
import UIKit

/// Service for performing OCR using Google Cloud Vision API
/// Provides more accurate text detection than Apple's Vision framework,
/// especially for multi-language and complex layouts
struct GoogleVisionService {
    
    // MARK: - Properties
    
    private let apiKey: String
    private let endpoint = "https://vision.googleapis.com/v1/images:annotate"
    
    // MARK: - Errors
    
    enum VisionError: LocalizedError {
        case invalidImage
        case networkError(String)
        case apiError(String)
        case noTextFound
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Konnte Bild nicht verarbeiten"
            case .networkError(let message):
                return "Netzwerkfehler: \(message)"
            case .apiError(let message):
                return "Google Vision Fehler: \(message)"
            case .noTextFound:
                return "Kein Text im Bild gefunden"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - OCR Methods
    
    /// Perform text detection on an image using Google Cloud Vision API
    /// - Parameters:
    ///   - image: The image to analyze
    ///   - languageHints: Optional language hints for better detection (e.g., ["es", "de"])
    /// - Returns: Extracted text from the image
    func detectText(in image: UIImage, languageHints: [String] = ["es", "de", "en"]) async throws -> String {
        print("🔵 GoogleVision: Starting text detection...")
        print("🔵 GoogleVision: API Key: \(apiKey.prefix(10))...")
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ GoogleVision: Failed to convert image to JPEG")
            throw VisionError.invalidImage
        }
        
        print("🔵 GoogleVision: Image data size: \(imageData.count) bytes")
        
        let base64Image = imageData.base64EncodedString()
        print("🔵 GoogleVision: Base64 image size: \(base64Image.count) chars")
        
        // Build request payload
        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": [
                        "content": base64Image
                    ],
                    "features": [
                        [
                            "type": "DOCUMENT_TEXT_DETECTION",  // Most accurate for text documents
                            "maxResults": 1
                        ]
                    ],
                    "imageContext": [
                        "languageHints": languageHints
                    ]
                ]
            ]
        ]
        
        print("🔵 GoogleVision: Building request payload...")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ GoogleVision: Failed to serialize JSON")
            throw VisionError.networkError("Could not serialize request")
        }
        
        // Build URL with API key
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("❌ GoogleVision: Invalid endpoint URL")
            throw VisionError.networkError("Invalid endpoint URL")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            print("❌ GoogleVision: Could not build URL")
            throw VisionError.networkError("Could not build request URL")
        }
        
        print("🔵 GoogleVision: Request URL: \(url.absoluteString.prefix(100))...")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("🔵 GoogleVision: Sending request to Google Cloud...")
        
        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("🔵 GoogleVision: Got response, status checking...")
        
        // Check HTTP status
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ GoogleVision: Invalid HTTP response")
            throw VisionError.networkError("Invalid response")
        }
        
        print("🔵 GoogleVision: HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ GoogleVision: API Error: \(errorMessage)")
            throw VisionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        print("🔵 GoogleVision: Parsing response...")
        
        // Parse response
        let visionResponse = try parseResponse(data)
        
        print("🔵 GoogleVision: ✅ Success! Extracted \(visionResponse.count) characters")
        
        guard !visionResponse.isEmpty else {
            print("⚠️ GoogleVision: No text found in image")
            throw VisionError.noTextFound
        }
        
        return visionResponse
    }
    
    // MARK: - Response Parsing
    
    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responses = json["responses"] as? [[String: Any]],
              let firstResponse = responses.first else {
            throw VisionError.apiError("Invalid response format")
        }
        
        // Check for API errors
        if let error = firstResponse["error"] as? [String: Any],
           let message = error["message"] as? String {
            throw VisionError.apiError(message)
        }
        
        // Extract full text annotation (best for structured text)
        if let fullTextAnnotation = firstResponse["fullTextAnnotation"] as? [String: Any],
           let text = fullTextAnnotation["text"] as? String {
            return text
        }
        
        // Fallback: Extract from text annotations
        if let textAnnotations = firstResponse["textAnnotations"] as? [[String: Any]],
           let firstAnnotation = textAnnotations.first,
           let text = firstAnnotation["description"] as? String {
            return text
        }
        
        throw VisionError.noTextFound
    }
    
    // MARK: - Cost Estimation
    
    /// Estimate cost for Google Cloud Vision API call
    /// Pricing: $1.50 per 1000 images for DOCUMENT_TEXT_DETECTION
    /// See: https://cloud.google.com/vision/pricing
    func estimateCost() -> Double {
        return 0.0015  // $0.0015 per image
    }
}

// MARK: - Response Models (for reference)

/*
 Example Google Vision API Response:
 
 {
   "responses": [
     {
       "textAnnotations": [
         {
           "locale": "es",
           "description": "la montaña Berg\nel sol Sonne\nla luna Mond",
           "boundingPoly": { ... }
         }
       ],
       "fullTextAnnotation": {
         "pages": [...],
         "text": "la montaña Berg\nel sol Sonne\nla luna Mond"
       }
     }
   ]
 }
*/
