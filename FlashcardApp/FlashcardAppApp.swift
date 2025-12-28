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
            Achievement.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If we can't load the container, it's likely due to a schema change
            // For development, we'll delete the old store and create a new one
            print("Error loading ModelContainer: \(error)")
            print("Attempting to delete and recreate store...")
            
            // Get the store URL and delete it
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            print("Deleted old store at: \(url)")
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after cleanup: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .task {
                    // Seed demo data on first launch
                    await MainActor.run {
                        let modelContext = sharedModelContainer.mainContext
                        DeckSeeder.seedDemoData(modelContext: modelContext)
                        
                        // Initialize achievements
                        let achievementManager = AchievementManager(modelContext: modelContext)
                        achievementManager.initializeAchievements()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
