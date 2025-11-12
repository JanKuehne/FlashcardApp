//
//  FlashcardAppApp.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 10.11.25.
//

import SwiftUI
import SwiftData

@main
struct FlashcardAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Flashcard.self,
            Deck.self,
            UserProgress.self,
            ReviewSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Seed demo data on first launch
                    let modelContext = sharedModelContainer.mainContext
                    DeckSeeder.seedDemoData(modelContext: modelContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
