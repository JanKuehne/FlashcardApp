//
//  DeckSeeder.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import Foundation
import SwiftData

class DeckSeeder {
    
    static func seedDemoData(modelContext: ModelContext) {
        // Check if already seeded
        let descriptor = FetchDescriptor<Deck>()
        let existingDecks = try? modelContext.fetch(descriptor)
        
        // Check for old "Grundwortschatz" demo deck and remove it
        if let decks = existingDecks,
           let oldDemoDeck = decks.first(where: { $0.name == "Grundwortschatz" }) {
            print("🔄 Found old demo deck 'Grundwortschatz', migrating to new starter decks...")
            
            // Delete old demo cards
            let cardDescriptor = FetchDescriptor<Flashcard>()
            if let allCards = try? modelContext.fetch(cardDescriptor) {
                let oldCards = allCards.filter { $0.deckId == oldDemoDeck.id }
                for card in oldCards {
                    modelContext.delete(card)
                }
                print("🗑️ Deleted \(oldCards.count) old demo cards")
            }
            
            // Delete old demo deck
            modelContext.delete(oldDemoDeck)
            print("🗑️ Deleted old 'Grundwortschatz' deck")
            
            // Continue to create new starter decks below...
        } else if let decks = existingDecks, 
                  !decks.isEmpty,
                  decks.contains(where: { $0.name == "English Starter" || $0.name == "Spanish Starter" }) {
            // New starter decks already exist, skip
            print("✅ Starter decks already exist, skipping seed")
            return
        } else if let decks = existingDecks, !decks.isEmpty {
            // User has custom decks, don't add starters
            print("✅ User has existing decks, skipping starter seed")
            return
        }
        
        // Create English starter deck
        let englishDeck = Deck(
            name: "English Starter",
            description: "5 essential words to get started",
            color: "#00B050",  // Green for English
            targetLanguage: "en"
        )
        modelContext.insert(englishDeck)
        
        // Create Spanish starter deck
        let spanishDeck = Deck(
            name: "Spanish Starter",
            description: "5 palabras esenciales para empezar",
            color: "#FF6B35",  // Orange for Spanish
            targetLanguage: "es"
        )
        modelContext.insert(spanishDeck)
        
        // Create starter cards for each language
        let englishCards = createEnglishStarterCards(deckId: englishDeck.id)
        let spanishCards = createSpanishStarterCards(deckId: spanishDeck.id)
        
        for card in englishCards + spanishCards {
            modelContext.insert(card)
        }
        
        // Create initial UserProgress
        let progress = UserProgress()
        modelContext.insert(progress)
        
        // Save everything
        try? modelContext.save()
        
        print("✅ Starter decks created: \(englishCards.count) English + \(spanishCards.count) Spanish cards")
    }
    
    // MARK: - English Starter Cards (5 essential words)
    
    private static func createEnglishStarterCards(deckId: UUID) -> [Flashcard] {
        let starterWords = [
            ("Hallo", "hello", "Hello! How are you?"),
            ("danke", "thank you", "Thank you very much!"),
            ("Wasser", "water", "Water is essential."),
            ("gut", "good", "This is very good."),
            ("Freund", "friend", "You are my friend.")
        ]
        
        return starterWords.map { german, english, example in
            Flashcard(
                front: german,
                back: english,
                deckId: deckId,
                exampleSentence: example
            )
        }
    }
    
    // MARK: - Spanish Starter Cards (5 essential words)
    
    private static func createSpanishStarterCards(deckId: UUID) -> [Flashcard] {
        let starterWords = [
            ("Hallo", "hola", "¡Hola! ¿Cómo estás?"),
            ("danke", "gracias", "¡Muchas gracias!"),
            ("Wasser", "agua", "El agua es esencial."),
            ("gut", "bueno", "Esto es muy bueno."),
            ("Freund", "amigo", "Tú eres mi amigo.")
        ]
        
        return starterWords.map { german, spanish, example in
            Flashcard(
                front: german,
                back: spanish,
                deckId: deckId,
                exampleSentence: example
            )
        }
    }
}
