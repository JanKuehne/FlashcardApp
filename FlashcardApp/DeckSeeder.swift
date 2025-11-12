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
        
        // TIERE (Animals) - 10 cards
        let animals = [
            ("der Hund", "the dog", "Der Hund bellt laut."),
            ("die Katze", "the cat", "Die Katze ist sehr süß."),
            ("der Vogel", "the bird", "Der Vogel fliegt hoch."),
            ("der Fisch", "the fish", "Der Fisch schwimmt im Wasser."),
            ("das Pferd", "the horse", "Das Pferd läuft schnell."),
            ("die Maus", "the mouse", "Die Maus ist klein."),
            ("der Elefant", "the elephant", "Der Elefant ist groß."),
            ("die Kuh", "the cow", "Die Kuh gibt Milch."),
            ("das Schwein", "the pig", "Das Schwein ist rosa."),
            ("der Löwe", "the lion", "Der Löwe ist stark.")
        ]
        
        // FARBEN (Colors) - 10 cards
        let colors = [
            ("rot", "red", "Das Auto ist rot."),
            ("blau", "blue", "Der Himmel ist blau."),
            ("grün", "green", "Das Gras ist grün."),
            ("gelb", "yellow", "Die Sonne ist gelb."),
            ("schwarz", "black", "Die Nacht ist schwarz."),
            ("weiß", "white", "Der Schnee ist weiß."),
            ("braun", "brown", "Der Baum ist braun."),
            ("orange", "orange", "Die Orange ist orange."),
            ("rosa", "pink", "Die Blume ist rosa."),
            ("lila", "purple", "Die Pflaume ist lila.")
        ]
        
        // ZAHLEN (Numbers) - 10 cards
        let numbers = [
            ("eins", "one", "Ich habe einen Apfel."),
            ("zwei", "two", "Ich habe zwei Brüder."),
            ("drei", "three", "Drei Äpfel sind auf dem Tisch."),
            ("vier", "four", "Vier Jahreszeiten gibt es."),
            ("fünf", "five", "Ich habe fünf Finger."),
            ("sechs", "six", "Sechs Eier sind im Karton."),
            ("sieben", "seven", "Sieben Tage hat die Woche."),
            ("acht", "eight", "Acht Beine hat die Spinne."),
            ("neun", "nine", "Neun Planeten gibt es."),
            ("zehn", "ten", "Zehn Finger habe ich.")
        ]
        
        // FAMILIE (Family) - 10 cards
        let family = [
            ("die Mutter", "the mother", "Meine Mutter ist nett."),
            ("der Vater", "the father", "Mein Vater arbeitet."),
            ("der Bruder", "the brother", "Mein Bruder spielt Fußball."),
            ("die Schwester", "the sister", "Meine Schwester liest gern."),
            ("die Oma", "the grandmother", "Meine Oma backt Kuchen."),
            ("der Opa", "the grandfather", "Mein Opa erzählt Geschichten."),
            ("das Kind", "the child", "Das Kind spielt im Garten."),
            ("der Sohn", "the son", "Der Sohn ist jung."),
            ("die Tochter", "the daughter", "Die Tochter singt schön."),
            ("die Eltern", "the parents", "Meine Eltern sind lieb.")
        ]
        
        // ESSEN (Food) - 10 cards
        let food = [
            ("das Brot", "the bread", "Ich esse Brot zum Frühstück."),
            ("das Wasser", "the water", "Wasser ist gesund."),
            ("die Milch", "the milk", "Die Milch ist weiß."),
            ("der Apfel", "the apple", "Der Apfel ist rot."),
            ("die Banane", "the banana", "Die Banane ist gelb."),
            ("der Käse", "the cheese", "Der Käse schmeckt gut."),
            ("das Ei", "the egg", "Das Ei ist zum Frühstück."),
            ("der Fisch", "the fish", "Der Fisch schwimmt im Meer."),
            ("das Fleisch", "the meat", "Das Fleisch ist auf dem Teller."),
            ("der Kuchen", "the cake", "Der Kuchen ist süß.")
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
