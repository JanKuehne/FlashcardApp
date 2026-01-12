//
//  ExtractedWord.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 29.12.25.
//

import Foundation

/// Model representing a word extracted from camera OCR
/// Used for batch import of vocabulary from textbooks
struct ExtractedWord: Identifiable {
    let id = UUID()
    var german: String              // Changed to var to allow editing
    var translation: String
    var exampleSentence: String?    // Optional example in source language
}
