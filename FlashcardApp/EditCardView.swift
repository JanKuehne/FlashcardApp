//
//  EditCardView.swift
//  FlashcardApp
//
//  Created by Assistant on 06.01.26.
//

import SwiftUI
import SwiftData
import UIKit

struct EditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: Flashcard
    
    @State private var frontText: String
    @State private var backText: String
    @State private var exampleText: String
    @State private var showSuccess = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case front, back, example
    }
    
    init(card: Flashcard) {
        self.card = card
        _frontText = State(initialValue: card.front)
        _backText = State(initialValue: card.back)
        _exampleText = State(initialValue: card.exampleSentence ?? "")
    }
    
    var hasChanges: Bool {
        frontText != card.front ||
        backText != card.back ||
        exampleText != (card.exampleSentence ?? "")
    }
    
    var canSave: Bool {
        !frontText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !backText.trimmingCharacters(in: .whitespaces).isEmpty
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
                        // Header
                        VStack(spacing: 8) {
                            Text("編集")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.blue.opacity(0.8))
                            
                            Text("KARTE BEARBEITEN")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                            
                            Text("Edit your flashcard")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)
                        
                        // Front side (German)
                        MangaEditField(
                            title: "🇩🇪 DEUTSCH",
                            placeholder: "z.B. Sonne",
                            text: $frontText,
                            color: .blue,
                            focused: $focusedField,
                            field: .front
                        )
                        .onSubmit {
                            focusedField = .back
                        }
                        
                        // Back side (Target language)
                        MangaEditField(
                            title: "🌍 ÜBERSETZUNG",
                            placeholder: "e.g. sun / sol",
                            text: $backText,
                            color: .green,
                            focused: $focusedField,
                            field: .back
                        )
                        .onSubmit {
                            focusedField = .example
                        }
                        
                        // Example sentence
                        MangaEditField(
                            title: "📝 BEISPIELSATZ (Optional)",
                            placeholder: "The sun shines brightly.",
                            text: $exampleText,
                            color: .purple,
                            focused: $focusedField,
                            field: .example,
                            isMultiline: true
                        )
                        .onSubmit {
                            if canSave && hasChanges {
                                saveChanges()
                            }
                        }
                        
                        // Info box
                        if hasChanges {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ÄNDERUNGEN")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.yellow)
                                    
                                    Text("Du hast ungespeicherte Änderungen")
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
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Save button
                            Button(action: saveChanges) {
                                VStack(spacing: 4) {
                                    Text("保存")
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("ÄNDERUNGEN SPEICHERN")
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .textCase(.uppercase)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: hasChanges ? [Color.blue, Color.purple] : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .shadow(color: hasChanges ? .blue.opacity(0.5) : .clear, radius: 12, y: 6)
                            }
                            .disabled(!canSave || !hasChanges)
                            .opacity(canSave && hasChanges ? 1.0 : 0.5)
                            .buttonStyle(MangaButtonStyle())
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                
                // Success animation overlay
                if showSuccess {
                    SaveSuccessView()
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(100)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if hasChanges {
                            // Could add unsaved changes alert here
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("EDIT CARD")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    // MARK: - Actions
    
    func saveChanges() {
        guard canSave && hasChanges else { return }
        
        // Update card properties
        card.front = frontText.trimmingCharacters(in: .whitespaces)
        card.back = backText.trimmingCharacters(in: .whitespaces)
        
        let trimmedExample = exampleText.trimmingCharacters(in: .whitespaces)
        card.exampleSentence = trimmedExample.isEmpty ? nil : trimmedExample
        
        // Save to database
        do {
            try modelContext.save()
            
            // Notify other views to refresh
            NotificationCenter.default.post(name: NSNotification.Name("CardsDidChange"), object: nil)
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // Show success animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showSuccess = true
            }
            
            // Dismiss after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }
            
        } catch {
            print("Error saving card: \(error)")
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

// MARK: - Manga Edit Field Component

struct MangaEditField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let color: Color
    var focused: FocusState<EditCardView.Field?>.Binding
    let field: EditCardView.Field
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

// MARK: - Save Success Animation

struct SaveSuccessView: View {
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Radiating circles
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.blue, lineWidth: 4)
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
                .foregroundColor(.blue)
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

// Note: MangaButtonStyle and HalftonePattern are imported from MangaComponents.swift

#Preview {
    let schema = Schema([
        Flashcard.self,
        Deck.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    
    let card = Flashcard(
        front: "Hallo",
        back: "hello",
        deckId: UUID(),
        exampleSentence: "Hello! How are you?"
    )
    container.mainContext.insert(card)
    
    return EditCardView(card: card)
        .modelContainer(container)
}
