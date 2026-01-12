//
//  CameraScannerView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 29.12.25.
//

import SwiftUI
import VisionKit
import Vision
import SwiftData

// MARK: - Camera Scanner View
struct CameraScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showScanner = false
    @State private var scannedText = ""
    @State private var extractedWords: [ExtractedWord] = []
    @State private var isProcessing = false
    @State private var showingResults = false
    @State private var useAdvancedModel = false  // Toggle for GPT-4o vs GPT-4o-mini
    @State private var generateExamples = true   // Toggle for example sentences
    @State private var showImagePicker = false   // New: for photo upload
    @State private var selectedImage: UIImage?   // New: uploaded photo
    @State private var accumulationMode = true   // NEW: Accumulate across multiple scans
    @State private var capturedPhoto: UIImage?   // Store photo for reprocessing
    @State private var processCount = 0          // Track how many times processed
    @State private var useDirectVision = false   // NEW: Send image directly to GPT-4o Vision
    @State private var useGoogleVision = false   // NEW: Use Google Cloud Vision for OCR
    
    var onWordsExtracted: ([ExtractedWord]) -> Void
    let deckId: UUID  // To check for duplicates
    let targetLanguage: String  // Deck's target language (e.g., "en" or "es")
    
    // Convert language code to full name for LLM
    private var targetLanguageFullName: String {
        switch targetLanguage {
        case "es": return "Spanish"
        case "en": return "English"
        default: return "English"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Manga black background
                Color.black.ignoresSafeArea()
                
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 24) {
                            // Add top spacing to prevent overlap with toolbar
                            Spacer()
                                .frame(height: 20)
                            
                            if isProcessing {
                                // Processing state
                                processingView
                            } else if extractedWords.isEmpty {
                                // Initial state - show camera button
                                cameraPromptView
                            } else {
                                // Results view
                                wordsListView
                            }
                            
                            // Extra bottom padding for scrolling
                            Spacer()
                                .frame(height: 60)
                        }
                        .padding()
                    }
                } else {
                    // Fallback for unsupported devices
                    unsupportedView
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
                    Text("📷 KAMERA SCANNER")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.white)
                }
                
                if !extractedWords.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Fertig") {
                            onWordsExtracted(extractedWords)
                            dismiss()
                        }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                ZStack {
                    DataScannerRepresentable { result in
                        handleScanResult(result)
                    }
                    .ignoresSafeArea()
                    
                    // Capture button overlay
                    VStack {
                        Spacer()
                        
                        Button {
                            // Trigger capture and close scanner
                            NotificationCenter.default.post(name: NSNotification.Name("CaptureScannedText"), object: nil)
                            showScanner = false  // Close the camera
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                
                                Text("TEXT ERFASSEN")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .shadow(color: .green.opacity(0.5), radius: 12, y: 6)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
                    .onDisappear {
                        if let image = selectedImage {
                            processImage(image)
                        }
                    }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("📸")
                .font(.system(size: 60))
            
            Text("TEXTBUCH SCANNEN")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text("Fotografiere Vokabelliste aus deinem Lehrbuch")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }
    
    private var cameraPromptView: some View {
        VStack(spacing: 32) {
            // Model selection
            VStack(spacing: 12) {
                Text("KI-Modell")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 20)  // Reduced from 60 to 20 - just enough clearance
                
                HStack(spacing: 12) {
                    modelButton(
                        title: "GPT-4o-mini",
                        subtitle: "Schnell & Günstig",
                        isSelected: !useAdvancedModel,
                        color: .blue
                    ) {
                        useAdvancedModel = false
                    }
                    
                    modelButton(
                        title: "GPT-4o",
                        subtitle: "Genauer (~10x teurer)",
                        isSelected: useAdvancedModel,
                        color: .purple
                    ) {
                        useAdvancedModel = true
                    }
                }
                
                // Example sentence toggle
                Toggle(isOn: $generateExamples) {
                    HStack(spacing: 8) {
                        Image(systemName: generateExamples ? "text.bubble.fill" : "text.bubble")
                            .foregroundColor(generateExamples ? .green : .white.opacity(0.5))
                        Text("Beispielsätze generieren")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .tint(.green)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))  // Increased from 0.05
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .cornerRadius(10)
                
                // NEW: Direct Vision toggle
                Toggle(isOn: $useDirectVision) {
                    HStack(spacing: 8) {
                        Image(systemName: useDirectVision ? "eye.circle.fill" : "eye.circle")
                            .foregroundColor(useDirectVision ? .orange : .white.opacity(0.5))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GPT-4o Vision (Bild direkt)")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Überspringt OCR - besser aber teurer")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .tint(.orange)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))  // Increased from orange.opacity(0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                )
                .cornerRadius(10)
                
                // NEW: Google Vision toggle
                Toggle(isOn: $useGoogleVision) {
                    HStack(spacing: 8) {
                        Image(systemName: useGoogleVision ? "g.circle.fill" : "g.circle")
                            .foregroundColor(useGoogleVision ? .blue : .white.opacity(0.5))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Google Cloud Vision OCR")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text("Genauer als Apple Vision (~$0.0015/Bild)")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .tint(.blue)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.15))  // Increased from blue.opacity(0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.4), lineWidth: 2)
                )
                .cornerRadius(10)
                .disabled(!AppSettings.shared.isGoogleVisionEnabled)
                .opacity(AppSettings.shared.isGoogleVisionEnabled ? 1.0 : 0.5)
                
                // Show warning if Google Vision not configured
                if !AppSettings.shared.isGoogleVisionEnabled && useGoogleVision {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Google API-Schlüssel in Einstellungen erforderlich")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.orange.opacity(0.8))
                    .padding(.horizontal)
                }
            }
            
            // Instructions
            VStack(alignment: .leading, spacing: 16) {
                instructionRow(number: "1", text: "📱 Halte Handy im HOCHFORMAT (Portrait)")
                instructionRow(number: "2", text: "⏱️ Warte 3-4 Sekunden über dem Text")
                instructionRow(number: "3", text: "📏 Halte Abstand ~20-30cm zur Seite")
                instructionRow(number: "4", text: "💡 Gutes Licht - keine Schatten")
                instructionRow(number: "5", text: "✅ Warte bis VIELE gelbe Boxen erscheinen")
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            
            // Camera Button - NEW: Photo Upload (Better!)
            Button(action: { showImagePicker = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                    
                    VStack(spacing: 4) {
                        Text("FOTO HOCHLADEN")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.black)
                        
                        Text("Empfohlen! Bessere Ergebnisse")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .opacity(0.8)
                    }
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black, lineWidth: 4)
                )
                .shadow(color: .green.opacity(0.5), radius: 12, y: 6)
            }
            .buttonStyle(MangaButtonStyle())
            
            // Live Camera Button (Secondary option)
            Button(action: { showScanner = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                    
                    VStack(spacing: 4) {
                        Text("LIVE KAMERA")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Funktioniert nicht immer")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .opacity(0.7)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
            }
            
            // Pro Tips
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("PRO TIPPS")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    tipRow(icon: "⭐", text: "'Erneut' senkt Konfidenz-Schwelle → findet unsichere Wörter")
                    tipRow(icon: "🔄", text: "Scan #1: 50% | #2: 30% | #3: 10% Konfidenz")
                    tipRow(icon: "✅", text: "Mehrfach scannen fängt zuvor ignorierte Wörter!")
                    tipRow(icon: "📱", text: "2-3 Scans nötig um alle Wörter zu erfassen")
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
            
            // TEST BUTTON - Bypass camera, test LLM directly
            Button {
                // FOR TESTING: Add your API key here temporarily
                // Replace "YOUR_KEY_HERE" with your actual OpenAI API key
                if AppSettings.shared.openAIAPIKey.isEmpty {
                    print("⚠️ Setting API key from code for testing...")
                    // UNCOMMENT AND ADD YOUR KEY:
                    // AppSettings.shared.openAIAPIKey = "sk-your-actual-api-key-here"
                }
                
                handleScanResult("la montaña Berg el sol Sonne la luna Mond")
            } label: {
                HStack(spacing: 12) {
                    Text("🧪")
                        .font(.title2)
                    
                    VStack(spacing: 4) {
                        Text("TEST LLM (Skip Camera)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                        
                        Text("Teste mit Beispiel-Text")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .opacity(0.8)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 3)
                )
                .shadow(color: .orange.opacity(0.5), radius: 8, y: 4)
            }
        }
        .padding(.top, 40)
    }
    
    private var wordsListView: some View {
        VStack(spacing: 16) {
            // Success banner
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ERFOLG!")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.black)
                        .foregroundColor(.green)
                    
                    Text("\(extractedWords.count) Wörter • Scan #\(processCount)")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Show different options based on context
                if capturedPhoto != nil {
                    // Can reprocess same photo
                    Button {
                        if let photo = capturedPhoto {
                            processCount += 1
                            processImage(photo)
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title3)
                            Text("Erneut")
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.blue)
                } else {
                    // Take new photo
                    Button("Mehr hinzufügen") {
                        showImagePicker = true
                    }
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.green.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green.opacity(0.5), lineWidth: 2)
            )
            
            // Words list
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 12) {
                    ForEach($extractedWords) { $word in
                        ExtractedWordRow(
                            word: $word,
                            onRemove: {
                                withAnimation {
                                    extractedWords.removeAll(where: { $0.id == word.id })
                                }
                            }
                        )
                    }
                }
            }
            
            // Action button
            Button(action: {
                onWordsExtracted(extractedWords)
                dismiss()
            }) {
                HStack(spacing: 12) {
                    Text("\(extractedWords.count)")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.black)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("KARTEN ERSTELLEN")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.black)
                        
                        Text("Füge alle zur Lernliste hinzu")
                            .font(.system(.caption2, design: .rounded))
                            .fontWeight(.semibold)
                            .opacity(0.8)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title)
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .green.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 4)
                )
                .shadow(color: .green.opacity(0.5), radius: 12, y: 6)
            }
            .buttonStyle(MangaButtonStyle())
            .disabled(extractedWords.isEmpty)
        }
    }
    
    private var unsupportedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("KAMERA NICHT VERFÜGBAR")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
            
            Text("Dein Gerät unterstützt keine Texterkennung mit der Kamera.")
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Manuelle Eingabe") {
                dismiss()
            }
            .font(.system(.headline, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 32) {
            // Animated processing indicator
            ProgressView()
                .scaleEffect(2.0)
                .tint(.blue)
            
            VStack(spacing: 12) {
                Text("🤖 KI VERARBEITET...")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text(useAdvancedModel ? "GPT-4o analysiert die Vokabeln" : "GPT-4o-mini analysiert die Vokabeln")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(useAdvancedModel ? "~1 Sekunde" : "~0.5 Sekunden")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Cost estimate (if available)
            if !scannedText.isEmpty {
                let estimatedCost = VocabularyExtractionService(apiKey: "dummy", useAdvancedModel: useAdvancedModel)
                    .estimateCost(ocrText: scannedText, generateExamples: generateExamples)
                
                VStack(spacing: 4) {
                    Text("Kosten: ~$\(String(format: "%.6f", estimatedCost))")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.green.opacity(0.8))
                    
                    Text(useAdvancedModel ? "Modell: GPT-4o" : "Modell: GPT-4o-mini")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private func modelButton(title: String, subtitle: String, isSelected: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .opacity(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? color : Color.white.opacity(0.2), lineWidth: isSelected ? 3 : 1)
            )
        }
        .foregroundColor(.white)
    }
    
    private func instructionRow(number: String, text: String) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(.title, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.caption)
            Text(text)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
            Spacer()
        }
    }
    
    // MARK: - Scan Result Handling
    
    private func handleScanResult(_ text: String) {
        scannedText = text
        isProcessing = true
        
        // Debug: Print what OCR extracted
        print("📸 OCR Extracted Text:")
        print("---")
        print(text)
        print("---")
        
        // Process text with LLM to extract vocabulary words
        Task {
            do {
                // Get API key from settings
                let apiKey = AppSettings.shared.openAIAPIKey
                guard !apiKey.isEmpty else {
                    await MainActor.run {
                        showLLMError("OpenAI API-Schlüssel fehlt. Bitte in Einstellungen konfigurieren.")
                        isProcessing = false
                    }
                    return
                }
                
                // Create LLM service with selected model
                let llmService = VocabularyExtractionService(apiKey: apiKey, useAdvancedModel: useAdvancedModel)
                
                // Estimate cost
                let estimatedCost = llmService.estimateCost(ocrText: text, generateExamples: generateExamples)
                print("💰 Estimated cost: $\(String(format: "%.6f", estimatedCost)) (\(llmService.currentModel))")
                
                // Extract vocabulary pairs using selected model
                let pairs = try await llmService.extractVocabulary(
                    from: text,
                    sourceLanguage: targetLanguageFullName,
                    targetLanguage: "German",
                    generateExamples: generateExamples
                )
                
                // Convert to ExtractedWord format
                var words = pairs.map { pair in
                    ExtractedWord(
                        german: pair.target,      // German on front
                        translation: pair.source,  // Spanish on back
                        exampleSentence: pair.example
                    )
                }
                
                // Check for duplicates
                words = await filterDuplicates(words)
                
                // Debug: Print parsed words
                print("📝 LLM extracted \(words.count) pairs (after duplicate removal):")
                for word in words {
                    let exampleInfo = word.exampleSentence.map { " (example: \($0))" } ?? ""
                    print("  German: '\(word.german)' → Spanish: '\(word.translation)'\(exampleInfo)")
                }
                
                await MainActor.run {
                    if accumulationMode {
                        // APPEND new words to existing list
                        extractedWords.append(contentsOf: words)
                        print("📊 Total words in session: \(extractedWords.count)")
                    } else {
                        // REPLACE (normal behavior)
                        extractedWords = words
                    }
                    isProcessing = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                
            } catch let error as ExtractionError {
                await MainActor.run {
                    showLLMError(error.localizedDescription)
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    showLLMError("Fehler bei der Verarbeitung: \(error.localizedDescription)")
                    isProcessing = false
                }
            }
        }
    }
    
    /// Filters out words that already exist as flashcards in the deck
    private func filterDuplicates(_ words: [ExtractedWord]) async -> [ExtractedWord] {
        // Capture deckId in local variable for predicate
        let currentDeckId = self.deckId
        
        // In accumulation mode, check against BOTH saved cards AND current extracted words
        if accumulationMode {
            // Get existing words in this session (not yet saved)
            let existingSessionWords = Set(extractedWords.map {
                $0.german.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            })
            
            // Filter out session duplicates first
            var sessionFiltered = words.filter { word in
                let normalized = word.german.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return !existingSessionWords.contains(normalized)
            }
            
            // Then check against saved cards
            let descriptor = FetchDescriptor<Flashcard>(
                predicate: #Predicate<Flashcard> { card in
                    card.deckId == currentDeckId
                }
            )
            
            guard let existingCards = try? modelContext.fetch(descriptor) else {
                print("⚠️ Could not fetch existing cards for duplicate check")
                let newCount = sessionFiltered.count
                print("✨ ACCUMULATION MODE: Adding \(newCount) new words to session")
                return sessionFiltered
            }
            
            let existingFronts = Set(existingCards.map {
                $0.front.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            })
            
            sessionFiltered = sessionFiltered.filter { word in
                let normalized = word.german.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return !existingFronts.contains(normalized)
            }
            
            let newCount = sessionFiltered.count
            print("✨ ACCUMULATION MODE: Adding \(newCount) new words to session (total: \(extractedWords.count + newCount))")
            
            return sessionFiltered
        }
        
        // Normal mode: Only check against saved cards
        let descriptor = FetchDescriptor<Flashcard>(
            predicate: #Predicate<Flashcard> { card in
                card.deckId == currentDeckId
            }
        )
        
        guard let existingCards = try? modelContext.fetch(descriptor) else {
            print("⚠️ Could not fetch existing cards for duplicate check")
            return words
        }
        
        let existingFronts = Set(existingCards.map {
            $0.front.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        })
        
        let filtered = words.filter { word in
            let normalized = word.german.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return !existingFronts.contains(normalized)
        }
        
        let duplicateCount = words.count - filtered.count
        if duplicateCount > 0 {
            print("🔍 Filtered out \(duplicateCount) duplicate(s)")
        }
        
        return filtered
    }
    
    private func showLLMError(_ message: String) {
        print("❌ LLM Error: \(message)")
        // For now, fall back to empty list
        // TODO: Show error alert to user
        extractedWords = []
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    // MARK: - Image Processing (Photo Upload)
    
    private func processImage(_ image: UIImage) {
        // Store photo for potential reprocessing
        if capturedPhoto == nil {
            capturedPhoto = image
            processCount = 1
        }
        
        isProcessing = true
        
        print("📸 Processing photo (attempt #\(processCount))...")
        
        Task {
            do {
                let recognizedText: String
                
                // Check which OCR method to use
                if useGoogleVision && AppSettings.shared.isGoogleVisionEnabled {
                    // Use Google Cloud Vision API
                    print("🔵 Using Google Cloud Vision API for OCR...")
                    let googleService = GoogleVisionService(apiKey: AppSettings.shared.googleVisionAPIKey)
                    recognizedText = try await googleService.detectText(in: image, languageHints: ["es", "de", "en"])
                    
                    let cost = googleService.estimateCost()
                    print("💰 Google Vision cost: ~$\(String(format: "%.4f", cost))")
                } else {
                    // Use Apple Vision Framework (existing code)
                    print("🍎 Using Apple Vision Framework for OCR...")
                    recognizedText = try await performAppleVisionOCR(on: image)
                }
                
                print("📝 Vision extracted text:")
                print("---")
                print(recognizedText)
                print("---")
                
                if recognizedText.isEmpty {
                    await MainActor.run {
                        showLLMError("Kein Text erkannt. Versuche ein schärferes Foto.")
                        isProcessing = false
                    }
                    return
                }
                
                // Process with LLM (same as camera scan)
                await MainActor.run {
                    handleScanResult(recognizedText)
                }
                
            } catch let error as GoogleVisionService.VisionError {
                await MainActor.run {
                    showLLMError(error.localizedDescription)
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    showLLMError("Fehler beim Lesen des Bildes: \(error.localizedDescription)")
                    isProcessing = false
                }
            }
        }
    }
    
    /// Perform OCR using Apple's Vision framework
    private func performAppleVisionOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw GoogleVisionService.VisionError.invalidImage
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest()
        
        // Configure for better accuracy
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["de-DE", "es-ES", "en-US"]
        
        // KEY CHANGE: Lower minimum confidence to catch more words
        // Default is 0.5, we try progressively lower on each attempt
        let confidenceThreshold: Float = {
            switch processCount {
            case 1: return 0.5  // Normal confidence
            case 2: return 0.3  // Lower confidence (catches more uncertain words)
            case 3: return 0.1  // Very low confidence (catches almost everything)
            default: return 0.05 // Desperate mode - include everything!
            }
        }()
        
        request.minimumTextHeight = 0.0  // Don't filter by size
        
        print("🎯 Using confidence threshold: \(confidenceThreshold) (attempt #\(processCount))")
        
        try requestHandler.perform([request])
        
        guard let observations = request.results, !observations.isEmpty else {
            return ""
        }
        
        // Extract text with varying strategies based on attempt count
        let recognizedText: String
        
        if processCount == 1 {
            // First attempt: High confidence only
            recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
        } else {
            // Subsequent attempts: Include lower confidence AND more candidates
            var allText: [String] = []
            for observation in observations {
                // Get top 3 candidates instead of just 1
                let candidates = observation.topCandidates(3)
                for candidate in candidates where candidate.confidence >= confidenceThreshold {
                    if !allText.contains(candidate.string) {
                        allText.append(candidate.string)
                    }
                }
            }
            recognizedText = allText.joined(separator: "\n")
        }
        
        print("📝 Apple Vision extracted \(observations.count) text regions (attempt #\(processCount), threshold: \(confidenceThreshold))")
        
        return recognizedText
    }
    
    // MARK: - Old Regex-Based Extraction (Fallback - kept for reference)
    /*
    private func extractVocabulary(from text: String) async -> [ExtractedWord] {
        var words: [ExtractedWord] = []
        
        // Split text into lines
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty lines
            guard !trimmed.isEmpty else { continue }
            
            // Textbook formats we handle:
            // Format: "Spanish German" (two columns)
            // Result: german=German (front), translation=Spanish (back)
            
            var firstWord: String? = nil
            var secondWord: String? = nil
            
            // Pattern 1: Separator-based (dash, arrow, colon)
            // Example: "sol - Sonne" or "sol → Sonne"
            if let match = try? /^(.+?)[\s]*[-–→:]\s*(.+)$/.firstMatch(in: trimmed) {
                firstWord = String(match.1).trimmingCharacters(in: .whitespaces)
                secondWord = String(match.2).trimmingCharacters(in: .whitespaces)
            }
            // Pattern 2: Parentheses
            // Example: "sol (Sonne)"
            else if let match = try? /^(.+?)\s*\((.+?)\)$/.firstMatch(in: trimmed) {
                firstWord = String(match.1).trimmingCharacters(in: .whitespaces)
                secondWord = String(match.2).trimmingCharacters(in: .whitespaces)
            }
            // Pattern 3: Two columns with multiple spaces (most common for textbooks)
            // Example: "sol       Sonne" (OCR reads columns with spaces between)
            else if let match = try? /^(\S+)\s{2,}(\S+)/.firstMatch(in: trimmed) {
                firstWord = String(match.1).trimmingCharacters(in: .whitespaces)
                secondWord = String(match.2).trimmingCharacters(in: .whitespaces)
            }
            // Pattern 4: Tab-separated (some OCR engines use tabs for columns)
            else if trimmed.contains("\t") {
                let parts = trimmed.components(separatedBy: "\t")
                if parts.count >= 2 {
                    firstWord = parts[0].trimmingCharacters(in: .whitespaces)
                    secondWord = parts[1].trimmingCharacters(in: .whitespaces)
                }
            }
            // Pattern 5: Space-separated two words (less reliable, only if exactly 2 words)
            else {
                let parts = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if parts.count == 2 {
                    firstWord = parts[0]
                    secondWord = parts[1]
                }
            }
            
            // If we found a word pair, add it
            if let first = firstWord, let second = secondWord,
               !first.isEmpty, !second.isEmpty {
                // IMPORTANT: Textbook format is typically "Spanish German"
                // So first=Spanish (target), second=German (front of card)
                words.append(ExtractedWord(german: second, translation: first))
            }
            // Fallback: Single word with no translation
            else if firstWord == nil && secondWord == nil {
                let cleanWord = trimmed.trimmingCharacters(in: CharacterSet.letters.inverted)
                if !cleanWord.isEmpty && cleanWord.count > 1 {
                    // Single word - mark as missing translation
                    words.append(ExtractedWord(german: cleanWord, translation: ""))
                }
            }
        }
        
        // Remove duplicates (by German word)
        var uniqueWords: [ExtractedWord] = []
        var seenGerman = Set<String>()
        
        for word in words {
            let key = word.german.lowercased()
            if !seenGerman.contains(key) {
                seenGerman.insert(key)
                uniqueWords.append(word)
            }
        }
        
        return uniqueWords
    }
    */
}

// MARK: - Extracted Word Row
struct ExtractedWordRow: View {
    @Binding var word: ExtractedWord
    let onRemove: () -> Void
    
    @State private var isEditing = false
    @State private var editGerman: String
    @State private var editTranslation: String
    @State private var editExample: String
    
    init(word: Binding<ExtractedWord>, onRemove: @escaping () -> Void) {
        self._word = word
        self.onRemove = onRemove
        self._editGerman = State(initialValue: word.wrappedValue.german)
        self._editTranslation = State(initialValue: word.wrappedValue.translation)
        self._editExample = State(initialValue: word.wrappedValue.exampleSentence ?? "")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                // Edit mode
                VStack(spacing: 8) {
                    // Edit German
                    TextField("Deutsch", text: $editGerman)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Edit Translation
                    TextField("Übersetzung", text: $editTranslation)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Edit Example
                    TextField("Beispielsatz (optional)", text: $editExample)
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                    
                    // Save/Cancel buttons
                    HStack(spacing: 8) {
                        Button {
                            // Cancel editing
                            isEditing = false
                            editGerman = word.german
                            editTranslation = word.translation
                            editExample = word.exampleSentence ?? ""
                        } label: {
                            Text("Abbrechen")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        }
                        
                        Button {
                            // Save changes
                            word.german = editGerman
                            word.translation = editTranslation
                            word.exampleSentence = editExample.isEmpty ? nil : editExample
                            isEditing = false
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Text("Speichern")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            } else {
                // Display mode
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(word.german)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if !word.translation.isEmpty {
                            Text("→ \(word.translation)")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        } else {
                            Text("→ Übersetzung fehlt")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        // Show example sentence if available
                        if let example = word.exampleSentence, !example.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "text.bubble")
                                    .font(.caption2)
                                    .foregroundColor(.blue.opacity(0.7))
                                
                                Text(example)
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white.opacity(0.7))
                                    .italic()
                            }
                            .padding(.top, 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Edit button
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    
                    // Remove button
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(isEditing ? 0.08 : 0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.blue.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 2)
        )
    }
}

// MARK: - Data Scanner Representable
struct DataScannerRepresentable: UIViewControllerRepresentable {
    var onTextScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        // Create recognized data types set with explicit type
        var recognizedDataTypes = Set<DataScannerViewController.RecognizedDataType>()
        recognizedDataTypes.insert(.text())
        
        // Create scanner with most basic init
        let scanner: DataScannerViewController = .init(
            recognizedDataTypes: recognizedDataTypes
        )
        
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTextScanned: onTextScanned)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var onTextScanned: (String) -> Void
        var accumulatedText: [String] = []
        
        init(onTextScanned: @escaping (String) -> Void) {
            self.onTextScanned = onTextScanned
            super.init()
            
            // Listen for capture trigger
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(captureAllText),
                name: NSNotification.Name("CaptureScannedText"),
                object: nil
            )
        }
        
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc private func captureAllText() {
            // Capture all accumulated text
            let fullText = accumulatedText.joined(separator: "\n")
            
            print("🔍 DEBUG: Accumulated text items: \(accumulatedText.count)")
            print("🔍 DEBUG: Full text length: \(fullText.count) characters")
            
            guard !fullText.isEmpty else {
                print("⚠️ No text captured yet - keep camera over text")
                print("⚠️ Make sure text is in focus and well-lit")
                return
            }
            
            print("📸 Capturing \(accumulatedText.count) text items")
            print("📸 Text content: \(fullText)")
            onTextScanned(fullText)
            
            // Haptic feedback
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print("👁️ DataScanner didAdd: \(addedItems.count) items, total: \(allItems.count)")
            
            // Collect all recognized text
            for item in allItems {
                switch item {
                case .text(let text):
                    if !accumulatedText.contains(text.transcript) {
                        print("➕ Adding text: '\(text.transcript)'")
                        accumulatedText.append(text.transcript)
                    }
                default:
                    break
                }
            }
            
            print("📝 Total accumulated: \(accumulatedText.count) items")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            // User tapped on specific text - also trigger capture
            captureAllText()
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType = .camera  // Allow configuration
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Use photo library if camera not available
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .photoLibrary
        } else {
            picker.sourceType = sourceType
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CameraScannerView(
        onWordsExtracted: { words in
            print("Extracted words: \(words)")
        },
        deckId: UUID(),
        targetLanguage: "es"
    )
}
