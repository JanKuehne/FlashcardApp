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
        
        if let decks = existingDecks, !decks.isEmpty {
            print("Demo deck already exists, skipping seed")
            return
        }
        
        // Create demo deck
        let demoDeck = Deck(
            name: "Grundwortschatz",
            description: "50 wichtige deutsche Wörter für Anfänger",
            color: "#0052FF"
        )
        modelContext.insert(demoDeck)
        
        // Create flashcards
        let cards = createDemoCards(deckId: demoDeck.id)
        for card in cards {
            modelContext.insert(card)
        }
        
        // Create initial UserProgress
        let progress = UserProgress()
        modelContext.insert(progress)
        
        // Save everything
        try? modelContext.save()
        
        print("✅ Demo deck created with \(cards.count) cards")
    }
    
    private static func createDemoCards(deckId: UUID) -> [Flashcard] {
        var cards: [Flashcard] = []
        
        // TIERE (Animals) - 10 cards - Examples in ENGLISH (the foreign language)
        let animals = [
            ("der Hund", "the dog", "The dog barks loudly."),
            ("die Katze", "the cat", "The cat is very cute."),
            ("der Vogel", "the bird", "The bird flies high."),
            ("der Fisch", "the fish", "The fish swims in water."),
            ("das Pferd", "the horse", "The horse runs fast."),
            ("die Maus", "the mouse", "The mouse is small."),
            ("der Elefant", "the elephant", "The elephant is big."),
            ("die Kuh", "the cow", "The cow gives milk."),
            ("das Schwein", "the pig", "The pig is pink."),
            ("der Löwe", "the lion", "The lion is strong.")
        ]
        
        // FARBEN (Colors) - 10 cards - Examples in ENGLISH
        let colors = [
            ("rot", "red", "The car is red."),
            ("blau", "blue", "The sky is blue."),
            ("grün", "green", "The grass is green."),
            ("gelb", "yellow", "The sun is yellow."),
            ("schwarz", "black", "The night is black."),
            ("weiß", "white", "The snow is white."),
            ("braun", "brown", "The tree is brown."),
            ("orange", "orange", "The orange is orange."),
            ("rosa", "pink", "The flower is pink."),
            ("lila", "purple", "The plum is purple.")
        ]
        
        // ZAHLEN (Numbers) - 10 cards - Examples in ENGLISH
        let numbers = [
            ("eins", "one", "I have one apple."),
            ("zwei", "two", "I have two brothers."),
            ("drei", "three", "Three apples are on the table."),
            ("vier", "four", "There are four seasons."),
            ("fünf", "five", "I have five fingers."),
            ("sechs", "six", "Six eggs are in the carton."),
            ("sieben", "seven", "The week has seven days."),
            ("acht", "eight", "The spider has eight legs."),
            ("neun", "nine", "There are nine planets."),
            ("zehn", "ten", "I have ten fingers.")
        ]
        
        // FAMILIE (Family) - 10 cards - Examples in ENGLISH
        let family = [
            ("die Mutter", "the mother", "My mother is nice."),
            ("der Vater", "the father", "My father works."),
            ("der Bruder", "the brother", "My brother plays football."),
            ("die Schwester", "the sister", "My sister likes reading."),
            ("die Oma", "the grandmother", "My grandma bakes cakes."),
            ("der Opa", "the grandfather", "My grandpa tells stories."),
            ("das Kind", "the child", "The child plays in the garden."),
            ("der Sohn", "the son", "The son is young."),
            ("die Tochter", "the daughter", "The daughter sings beautifully."),
            ("die Eltern", "the parents", "My parents are kind.")
        ]
        
        // ESSEN (Food) - 10 cards - Examples in ENGLISH
        let food = [
            ("das Brot", "the bread", "I eat bread for breakfast."),
            ("das Wasser", "the water", "Water is healthy."),
            ("die Milch", "the milk", "The milk is white."),
            ("der Apfel", "the apple", "The apple is red."),
            ("die Banane", "the banana", "The banana is yellow."),
            ("der Käse", "the cheese", "The cheese tastes good."),
            ("das Ei", "the egg", "The egg is for breakfast."),
            ("der Fisch", "the fish", "The fish swims in the sea."),
            ("das Fleisch", "the meat", "The meat is on the plate."),
            ("der Kuchen", "the cake", "The cake is sweet.")
        ]
        
        // Combine all categories
        let allVocab = animals + colors + numbers + family + food
        
        // Create Flashcard objects
        for (german, english, example) in allVocab {
            let card = Flashcard(
                front: german,
                back: english,
                deckId: deckId,
                exampleSentence: example
            )
            cards.append(card)
        }
        
        return cards
    }
}
