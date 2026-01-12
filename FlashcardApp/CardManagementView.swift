//
//  CardManagementView.swift
//  FlashcardApp
//
//  Created by Assistant on 29.12.25.
//

import SwiftUI
import SwiftData

struct CardManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var decks: [Deck]
    @Query private var flashcards: [Flashcard]
    
    @State private var selectedLanguage: String = "en"
    @State private var searchText = ""
    @State private var showDeleteAlert = false
    @State private var cardToDelete: Flashcard?
    @State private var showDeleteAllAlert = false
    
    // NEW: Sorting and display options
    @State private var sortOption: SortOption = .frontAlphabetical
    @State private var showFrontFirst: Bool = true
    
    enum SortOption: String, CaseIterable, Identifiable {
        case frontAlphabetical = "A→Z (Deutsch)"
        case frontReverse = "Z→A (Deutsch)"
        case backAlphabetical = "A→Z (Übersetzung)"
        case backReverse = "Z→A (Übersetzung)"
        case dateNewest = "Neueste zuerst"
        case dateOldest = "Älteste zuerst"
        
        var id: String { rawValue }
    }
    
    // Get active deck and flashcards for selected language
    var activeDeck: Deck? {
        decks.first { $0.targetLanguage == selectedLanguage }
    }
    
    var activeFlashcards: [Flashcard] {
        guard let deck = activeDeck else { return [] }
        let cards = flashcards.filter { $0.deckId == deck.id }
        
        // Filter by search text if present
        let filteredCards: [Flashcard]
        if searchText.isEmpty {
            filteredCards = cards
        } else {
            filteredCards = cards.filter {
                $0.front.localizedCaseInsensitiveContains(searchText) ||
                $0.back.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .frontAlphabetical:
            return filteredCards.sorted { $0.front.lowercased() < $1.front.lowercased() }
        case .frontReverse:
            return filteredCards.sorted { $0.front.lowercased() > $1.front.lowercased() }
        case .backAlphabetical:
            return filteredCards.sorted { $0.back.lowercased() < $1.back.lowercased() }
        case .backReverse:
            return filteredCards.sorted { $0.back.lowercased() > $1.back.lowercased() }
        case .dateNewest:
            return filteredCards.sorted { $0.createdDate > $1.createdDate }
        case .dateOldest:
            return filteredCards.sorted { $0.createdDate < $1.createdDate }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Language selector
                    languageSelectorView
                    
                    // Search bar
                    searchBarView
                    
                    // Card count
                    cardCountView
                    
                    // Card list
                    if activeFlashcards.isEmpty {
                        emptyStateView
                    } else {
                        cardListView
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("📚 KARTEN VERWALTEN")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        // Sort menu
                        Menu {
                            ForEach(SortOption.allCases) { option in
                                Button {
                                    sortOption = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Front/Back toggle
                        Button {
                            showFrontFirst.toggle()
                        } label: {
                            Image(systemName: showFrontFirst ? "character.textbox" : "textformat.abc")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        // Delete all button
                        if !activeFlashcards.isEmpty {
                            Button {
                                showDeleteAllAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .alert("Karte löschen?", isPresented: $showDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                }
            } message: {
                if let card = cardToDelete {
                    Text("Möchtest du '\(card.front)' wirklich löschen?")
                }
            }
            .alert("Alle Karten löschen?", isPresented: $showDeleteAllAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Alle löschen", role: .destructive) {
                    deleteAllCards()
                }
            } message: {
                Text("Möchtest du wirklich alle \(activeFlashcards.count) Karten für \(selectedLanguage == "en" ? "English" : "Español") löschen? Dies kann nicht rückgängig gemacht werden.")
            }
        }
    }
    
    // MARK: - View Components
    
    private var languageSelectorView: some View {
        HStack(spacing: 12) {
            // English
            Button {
                withAnimation {
                    selectedLanguage = "en"
                }
            } label: {
                HStack(spacing: 8) {
                    Text("🇬🇧")
                        .font(.system(size: 24))
                    Text("English")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedLanguage == "en" ? Color.green.opacity(0.3) : Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedLanguage == "en" ? Color.green : Color.white.opacity(0.2), lineWidth: 2)
                )
            }
            
            // Spanish
            Button {
                withAnimation {
                    selectedLanguage = "es"
                }
            } label: {
                HStack(spacing: 8) {
                    Text("🇪🇸")
                        .font(.system(size: 24))
                    Text("Español")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(selectedLanguage == "es" ? Color.orange.opacity(0.3) : Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selectedLanguage == "es" ? Color.orange : Color.white.opacity(0.2), lineWidth: 2)
                )
            }
        }
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Suchen...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
                .autocorrectionDisabled()
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var cardCountView: some View {
        HStack {
            Text("\(activeFlashcards.count) KARTEN")
                .font(.system(.headline, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
            
            Spacer()
            
            if !searchText.isEmpty {
                Text("gefiltert")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var cardListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(activeFlashcards) { card in
                    CardRowView(
                        card: card,
                        showFrontFirst: showFrontFirst,  // Pass the toggle state
                        onDelete: {
                            cardToDelete = card
                            showDeleteAlert = true
                        }
                    )
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text("Keine Karten")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
            
            Text("Füge Karten hinzu, um loszulegen!")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - Actions
    
    private func deleteCard(_ card: Flashcard) {
        withAnimation {
            modelContext.delete(card)
            try? modelContext.save()
        }
        
        // Notify ContentView to refresh
        NotificationCenter.default.post(name: NSNotification.Name("CardsDidChange"), object: nil)
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func deleteAllCards() {
        let count = activeFlashcards.count
        
        withAnimation {
            for card in activeFlashcards {
                modelContext.delete(card)
            }
            try? modelContext.save()
        }
        
        // Notify ContentView to refresh
        NotificationCenter.default.post(name: NSNotification.Name("CardsDidChange"), object: nil)
        
        print("🗑️ Deleted \(count) cards for language: \(selectedLanguage)")
        
        // Haptic feedback
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
}

// MARK: - Card Row View
struct CardRowView: View {
    let card: Flashcard
    let showFrontFirst: Bool  // NEW: Get from parent
    let onDelete: () -> Void
    
    @State private var showEditCard = false
    
    // Compute what to display based on parent toggle
    private var primaryText: String {
        showFrontFirst ? card.front : card.back
    }
    
    private var secondaryText: String {
        showFrontFirst ? card.back : card.front
    }
    
    private var primaryLabel: String {
        showFrontFirst ? "DEUTSCH" : "ÜBERSETZUNG"
    }
    
    private var secondaryLabel: String {
        showFrontFirst ? "ÜBERSETZUNG" : "DEUTSCH"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row with label and edit button
            HStack {
                Text(primaryLabel)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(showFrontFirst ? .blue : .green)
                
                Spacer()
                
                // Edit button (top right)
                Button {
                    showEditCard = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
            
            // Primary content
            Text(primaryText)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Secondary text (arrow + translation)
            Text("→ \(secondaryText)")
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(showFrontFirst ? .green : .blue)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Example sentence if available
            if let example = card.exampleSentence, !example.isEmpty {
                Text("📝 \(example)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.purple.opacity(0.8))
                    .italic()
            }
            
            // Bottom row with stats and delete button
            HStack(spacing: 12) {
                // Stats (reviews/accuracy)
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("\(card.timesCorrect)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        Text("\(card.timesReviewed - card.timesCorrect)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Delete button (compact)
                Button(action: onDelete) {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
        )
        .sheet(isPresented: $showEditCard) {
            EditCardView(card: card)
        }
    }
}

#Preview {
    CardManagementView()
        .modelContainer(for: [Flashcard.self, Deck.self])
}
