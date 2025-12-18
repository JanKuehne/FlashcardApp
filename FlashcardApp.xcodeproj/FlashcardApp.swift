//
//  FlashcardApp.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 17.12.24.
//

import SwiftUI
import SwiftData

@main
struct FlashcardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Flashcard.self,
            Deck.self,
            UserProgress.self,
            ReviewSession.self,
            Achievement.self
        ])
    }
}
