//
//  AddCardView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import SwiftUI
import SwiftData

struct AddCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var decks: [Deck]
    
    @State private var germanWord = ""
    @State private var englishWord = ""
    @State private var exampleSentence = ""
    @State private var showSuccess = false
    @State private var cardsSaved = 0
    @State private var isLoadingAI = false
    @State private var aiErrorMessage: String?
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case german, english, example
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Manga black background
                Color.black.ignoresSafeArea()
                
                // Subtle halftone pattern
                HalftonePattern()
                    .opacity(0.02)
                    .allowsHitTesting(false)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Japanese text
                        VStack(spacing: 8) {
                            Text("追加")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.blue.opacity(0.8))
                            
                            Text("NEUE KARTE")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                            
                            Text("Add vocabulary to your deck")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // German Word Input
                        MangaInputField(
                            title: "🇩🇪 DEUTSCH",
                            placeholder: "z.B. Sonne",
                            text: $germanWord,
                            color: .blue,
                            focused: $focusedField,
                            field: .german
                        )
                        .onSubmit {
                            focusedField = .english
                        }
                        
                        // English Word Input
                        MangaInputField(
                            title: "🇬🇧 ENGLISH",
                            placeholder: "e.g. sun",
                            text: $englishWord,
                            color: .green,
                            focused: $focusedField,
                            field: .english
                        )
                        .onSubmit {
                            focusedField = .example
                        }
                        .onChange(of: englishWord) { oldValue, newValue in
                            // Clear error when user starts typing
                            if !newValue.isEmpty && aiErrorMessage != nil {
                                aiErrorMessage = nil
                            }
                        }
                        
                        // AI Magic Wand Button (appears when both German and English filled)
                        if canUseAI {
                            Button(action: generateExampleWithAI) {
                                HStack(spacing: 12) {
                                    if isLoadingAI {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                            .font(.title3)
                                    }
                                    
                                    VStack(spacing: 2) {
                                        Text("魔法")
                                            .font(.system(.caption2, design: .rounded))
                                            .fontWeight(.bold)
                                        
                                        Text(isLoadingAI ? "GENERIERE..." : "BEISPIEL GENERIEREN")
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.black)
                                    }
                                    
                                    Image(systemName: "wand.and.stars")
                                        .font(.title3)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.purple, Color.pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                                .shadow(color: .purple.opacity(0.5), radius: 8, y: 4)
                            }
                            .disabled(isLoadingAI)
                            .buttonStyle(MangaButtonStyle())
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Error message banner
                        if let errorMessage = aiErrorMessage {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI FEHLER")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.orange)
                                    
                                    Text(errorMessage)
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        aiErrorMessage = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.orange.opacity(0.6))
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                            )
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Example Sentence Input (Optional) - in English
                        MangaInputField(
                            title: "📝 BEISPIEL IN ENGLISH (Optional)",
                            placeholder: "The sun shines brightly",
                            text: $exampleSentence,
                            color: .purple,
                            focused: $focusedField,
                            field: .example,
                            isMultiline: true
                        )
                        .onSubmit {
                            if canSave {
                                saveCard()
                            }
                        }
                        
                        // Info box
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TIPP")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.yellow)
                                
                                Text("Nutze die AI 🪄 für englische Beispielsätze!")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.yellow.opacity(0.4), lineWidth: 2)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Save and Add Another
                            Button(action: saveAndContinue) {
                                VStack(spacing: 4) {
                                    Text("保存")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("SPEICHERN & WEITER")
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .textCase(.uppercase)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .shadow(color: .blue.opacity(0.5), radius: 12, y: 6)
                            }
                            .disabled(!canSave)
                            .opacity(canSave ? 1.0 : 0.5)
                            .buttonStyle(MangaButtonStyle())
                            
                            // Save and Close
                            Button(action: saveAndClose) {
                                VStack(spacing: 4) {
                                    Text("完了")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("SPEICHERN & FERTIG")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .textCase(.uppercase)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.green)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .shadow(color: .green.opacity(0.4), radius: 8, y: 4)
                            }
                            .disabled(!canSave)
                            .opacity(canSave ? 1.0 : 0.5)
                            .buttonStyle(MangaButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        
                        // Counter for cards added this session
                        if cardsSaved > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                
                                Text("\(cardsSaved) KARTE\(cardsSaved == 1 ? "" : "N") HINZUGEFÜGT!")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                // Success animation overlay
                if showSuccess {
                    SuccessBurstView()
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(100)
                }
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
                    Text("ADD CARD")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    var canSave: Bool {
        !germanWord.trimmingCharacters(in: .whitespaces).isEmpty &&
        !englishWord.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var canUseAI: Bool {
        !germanWord.trimmingCharacters(in: .whitespaces).isEmpty &&
        !englishWord.trimmingCharacters(in: .whitespaces).isEmpty &&
        !isLoadingAI
    }
    
    // MARK: - AI Example Generation
    
    func generateExampleWithAI() {
        // Clear previous error
        aiErrorMessage = nil
        
        // Start loading
        isLoadingAI = true
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Dismiss keyboard
        focusedField = nil
        
        Task {
            do {
                let llmService = AppSettings.shared.createLLMService()
                
                if let example = try await llmService.generateExample(
                    germanWord: germanWord.trimmingCharacters(in: .whitespaces),
                    englishWord: englishWord.trimmingCharacters(in: .whitespaces)
                ) {
                    await MainActor.run {
                        // Animate the fill
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            exampleSentence = example
                            isLoadingAI = false
                        }
                        
                        // Success haptic
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        
                        // Auto-focus example field for review
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            focusedField = .example
                        }
                    }
                } else {
                    await MainActor.run {
                        isLoadingAI = false
                        aiErrorMessage = "Keine Antwort von AI erhalten"
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingAI = false
                    aiErrorMessage = "AI Fehler: \(error.localizedDescription)"
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
    
    // MARK: - Card Saving
    
    func saveCard() {
        guard canSave, let deck = decks.first else { return }
        
        let card = Flashcard(
            front: germanWord.trimmingCharacters(in: .whitespaces),
            back: englishWord.trimmingCharacters(in: .whitespaces),
            deckId: deck.id,
            exampleSentence: exampleSentence.trimmingCharacters(in: .whitespaces).isEmpty ? nil : exampleSentence.trimmingCharacters(in: .whitespaces)
        )
        
        modelContext.insert(card)
        
        do {
            try modelContext.save()
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // Show success animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showSuccess = true
                cardsSaved += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    showSuccess = false
                }
            }
            
        } catch {
            print("Error saving card: \(error)")
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
    
    func saveAndContinue() {
        saveCard()
        
        // Clear fields for next card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            germanWord = ""
            englishWord = ""
            exampleSentence = ""
            focusedField = .german
        }
    }
    
    func saveAndClose() {
        saveCard()
        
        // Dismiss after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            dismiss()
        }
    }
}

// MARK: - Manga Input Field Component

struct MangaInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let color: Color
    var focused: FocusState<AddCardView.Field?>.Binding
    let field: AddCardView.Field
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(color)
                .textCase(.uppercase)
                .padding(.leading, 4)
            
            Group {
                if isMultiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(2...4)
                        .focused(focused, equals: field)
                } else {
                    TextField(placeholder, text: $text)
                        .focused(focused, equals: field)
                }
            }
            .font(.system(.title3, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        focused.wrappedValue == field ? color : Color.white.opacity(0.2),
                        lineWidth: focused.wrappedValue == field ? 3 : 2
                    )
            )
            .cornerRadius(12)
            .autocapitalization(.none)
            .autocorrectionDisabled()
            .submitLabel(isMultiline ? .done : .next)
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: focused.wrappedValue == field)
    }
}

// MARK: - Success Burst Animation

struct SuccessBurstView: View {
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Radiating circles
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.green, lineWidth: 4)
                    .frame(width: 100, height: 100)
                    .scaleEffect(scale * (1.0 + CGFloat(i) * 0.3))
                    .opacity(opacity / Double(i + 1))
            }
            
            // Stars
            ForEach(0..<8) { i in
                Text("★")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                    .offset(
                        x: cos(Double(i) * .pi / 4) * 80 * scale,
                        y: sin(Double(i) * .pi / 4) * 80 * scale
                    )
                    .rotationEffect(.degrees(rotation))
            }
            
            // Center checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                scale = 1.5
            }
            
            withAnimation(.linear(duration: 0.6)) {
                rotation = 360
                opacity = 0
            }
        }
    }
}

#Preview {
    AddCardView()
        .modelContainer(for: [Flashcard.self, Deck.self])
}
