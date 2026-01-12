//
//  SettingsView.swift
//  FlashcardApp
//
//  Created by Jan Kühne on 30.11.25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var userProgress: [UserProgress]
    
    @State private var apiKey: String = ""
    @State private var googleVisionAPIKey: String = ""
    @State private var useMockLLM: Bool = false
    @State private var showingAPIKeyInfo = false
    @State private var showingGoogleVisionInfo = false
    @State private var dailyGoal: Int = 100
    @State private var cardsPerSession: Int = 20
    @State private var reviewMode: String = "newest"
    @State private var userName: String = ""
    @State private var showAchievements = false
    
    // Audio settings state
    @State private var autoPlayMode: AudioService.AutoPlayMode = .backOnly
    @State private var autoPlayDelay: Double = 0.5
    @State private var speechRate: Float = 1.0  // Default to Normal (1.0x)
    
    private let settings = AppSettings.shared
    private let audioService = AudioService.shared
    
    var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                HalftonePattern()
                    .opacity(0.03)
                    .allowsHitTesting(false)
                
                Form {
                    // User Profile Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("DEIN NAME")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.purple)
                                
                                Spacer()
                            }
                            
                            TextField("z.B. Henri", text: $userName)
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.semibold)
                                .textInputAutocapitalization(.words)
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                            
                            Text("Dein Name wird in Erfolgsmeldungen verwendet, z.B. \"Gut gemacht, Henri!\"")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("PROFIL")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Daily Goal Section
                    Section {
                        VStack(alignment: .leading, spacing: 20) {
                            // Daily Goal (Total cards per day)
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("TAGESZIEL: \(dailyGoal) KARTEN")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(dailyGoal) },
                                    set: { dailyGoal = Int($0) }
                                ), in: 20...200, step: 10)
                                .tint(.blue)
                                
                                HStack {
                                    Text("20")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("200")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Wie viele Karten möchtest du insgesamt pro Tag lernen?")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Cards Per Session
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("KARTEN PRO DURCHLAUF: \(cardsPerSession)")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.purple)
                                    
                                    Spacer()
                                }
                                
                                Slider(value: Binding(
                                    get: { Double(cardsPerSession) },
                                    set: { cardsPerSession = Int($0) }
                                ), in: 5...50, step: 5)
                                .tint(.purple)
                                
                                HStack {
                                    Text("5")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("50")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Wie viele Karten pro Lern-Session? (Anki-Style: neue Karten + Wiederholungen)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Review Mode Selection
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("KARTEN-AUSWAHL")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.orange)
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 8) {
                                    ReviewModeButton(
                                        icon: "sparkles",
                                        title: "Neueste",
                                        subtitle: "Frische Karten",
                                        mode: "newest",
                                        isSelected: reviewMode == "newest",
                                        color: .blue
                                    ) {
                                        reviewMode = "newest"
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                    
                                    ReviewModeButton(
                                        icon: "rectangle.stack",
                                        title: "Alle",
                                        subtitle: "Gesamter Stapel",
                                        mode: "all",
                                        isSelected: reviewMode == "all",
                                        color: .green
                                    ) {
                                        reviewMode = "all"
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                                
                                Text(reviewMode == "newest" 
                                    ? "Fokus auf neue & aktuelle Lernkarten (Anki-Stil)" 
                                    : "Mischt alte und neue Karten gleichmäßig")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("LERNZIELE")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Audio Settings Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            HStack {
                                Image(systemName: "speaker.wave.3")
                                    .foregroundColor(.blue)
                                
                                Text("AUSSPRACHE")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            
                            // Auto-play mode picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Auto-Play Modus")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Picker("Auto-Play Mode", selection: $autoPlayMode) {
                                    ForEach(AudioService.AutoPlayMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .tint(.blue)
                                
                                Text(autoPlayModeDescription)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            // Auto-play delay slider (only if not disabled)
                            if autoPlayMode != .disabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Verzögerung: \(String(format: "%.1fs", autoPlayDelay))")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Slider(value: $autoPlayDelay, in: 0...2, step: 0.1)
                                        .tint(.blue)
                                    
                                    HStack {
                                        Text("0s")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text("2s")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Speech rate buttons (simplified)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Sprechgeschwindigkeit")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 8) {
                                    SpeedButton(
                                        label: "0.5×",
                                        subtitle: "Langsam",
                                        isSelected: abs(speechRate - 0.3) < 0.05,
                                        color: .blue
                                    ) {
                                        speechRate = 0.3
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                    
                                    SpeedButton(
                                        label: "1×",
                                        subtitle: "Normal",
                                        isSelected: abs(speechRate - 0.5) < 0.05,
                                        color: .green
                                    ) {
                                        speechRate = 0.5
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                    
                                    SpeedButton(
                                        label: "2×",
                                        subtitle: "Schnell",
                                        isSelected: abs(speechRate - 0.65) < 0.05,
                                        color: .orange
                                    ) {
                                        speechRate = 0.65
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            // Test pronunciation button
                            Button {
                                testPronunciation()
                            } label: {
                                HStack {
                                    Image(systemName: "speaker.wave.2.circle.fill")
                                        .font(.title3)
                                    
                                    Text("Test Aussprache")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("🔊 AUDIO")
                            .foregroundColor(.white.opacity(0.7))
                    } footer: {
                        Text("Auto-Play spielt Audio automatisch nach \(String(format: "%.1f", autoPlayDelay))s ab. 'Nur Rückseite' empfohlen.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    // AI Features Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.purple)
                                
                                Text("AI AUTO-COMPLETE")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            
                            Toggle(isOn: $useMockLLM) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Demo-Modus")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Benutze Test-Übersetzungen (kostenlos)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .tint(.purple)
                            
                            if !useMockLLM {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("OpenAI API Key")
                                            .font(.system(.subheadline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Button(action: {
                                            showingAPIKeyInfo = true
                                        }) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    SecureField("sk-proj-...", text: $apiKey)
                                        .font(.system(.caption, design: .monospaced))
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .padding()
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                    
                                    if settings.isLLMEnabled {
                                        Label("API-Schlüssel aktiv", systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("KI-FUNKTIONEN")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Google Cloud Vision Section
                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .foregroundColor(.blue)
                                
                                Text("GOOGLE VISION OCR")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Google Cloud API Key")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Button(action: {
                                        showingGoogleVisionInfo = true
                                    }) {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                SecureField("AIza...", text: $googleVisionAPIKey)
                                    .font(.system(.caption, design: .monospaced))
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                
                                if settings.isGoogleVisionEnabled {
                                    Label("Google Vision aktiv", systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                
                                Text("Genauere Texterkennung als Apple Vision (~$0.0015/Bild)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("KAMERA-OCR")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Achievements Section
                    Section {
                        Button(action: {
                            showAchievements = true
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.yellow, Color.orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 50, height: 50)
                                    
                                    Text("🏆")
                                        .font(.system(size: 28))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ACHIEVEMENTS")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                    
                                    Text("Zeige deine Erfolge")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Text("ERFOLGE")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Stats Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            StatRow(label: "Aktueller Streak", value: "\(progress.currentStreak) Tage", color: .orange)
                            StatRow(label: "Längster Streak", value: "\(progress.longestStreak) Tage", color: .orange)
                            StatRow(label: "Gesamt XP", value: "\(progress.totalXP)", color: .purple)
                            StatRow(label: "Karten gelernt", value: "\(progress.totalCardsReviewed)", color: .blue)
                            StatRow(label: "Genauigkeit", value: accuracyPercentage, color: .green)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("STATISTIKEN")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // About Section
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("FlashcardApp")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Manga-style language learning app")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("ÜBER")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fertig") {
                        saveSettings()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingAPIKeyInfo) {
                APIKeyInfoView()
            }
            .sheet(isPresented: $showingGoogleVisionInfo) {
                GoogleVisionInfoView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .onAppear {
                loadSettings()
            }
        }
    }
    
    var accuracyPercentage: String {
        guard progress.totalCardsReviewed > 0 else { return "0%" }
        let percentage = Int(Double(progress.totalCorrectAnswers) / Double(progress.totalCardsReviewed) * 100)
        return "\(percentage)%"
    }
    
    func loadSettings() {
        apiKey = settings.openAIAPIKey
        googleVisionAPIKey = settings.googleVisionAPIKey
        useMockLLM = settings.useMockLLM
        dailyGoal = progress.dailyGoal
        cardsPerSession = progress.cardsPerSession
        // Ensure reviewMode has a valid default if it's empty
        reviewMode = progress.reviewMode.isEmpty ? "newest" : progress.reviewMode
        userName = settings.userName
        
        // Load audio settings
        autoPlayMode = audioService.autoPlayMode
        autoPlayDelay = audioService.autoPlayDelay
        speechRate = audioService.speechRate
    }
    
    func saveSettings() {
        settings.openAIAPIKey = apiKey
        settings.googleVisionAPIKey = googleVisionAPIKey
        settings.useMockLLM = useMockLLM
        settings.userName = userName
        progress.dailyGoal = dailyGoal
        progress.cardsPerSession = cardsPerSession
        progress.reviewMode = reviewMode
        
        // Save audio settings
        audioService.autoPlayMode = autoPlayMode
        audioService.autoPlayDelay = autoPlayDelay
        audioService.speechRate = speechRate
    }
    
    // Helper computed property for mode description
    private var autoPlayModeDescription: String {
        switch autoPlayMode {
        case .disabled:
            return "Audio wird nicht automatisch abgespielt"
        case .frontOnly:
            return "Spielt deutsche Wörter automatisch ab (beim Öffnen der Karte)"
        case .backOnly:
            return "Spielt Übersetzungen automatisch ab (nach dem Umdrehen)"
        case .bothSides:
            return "Spielt beide Seiten automatisch ab (vorne + hinten)"
        }
    }
    
    // Test pronunciation with current rate
    private func testPronunciation() {
        // Apply current speech rate from slider BEFORE playing
        audioService.speechRate = speechRate
        audioService.speakGerman("Hallo, wie geht's dir?")
    }
}

// MARK: - Speed Button Component
struct SpeedButton: View {
    let label: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                isSelected
                ? LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.gray, lineWidth: isSelected ? 3 : 2)
            )
            .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Review Mode Button Component
struct ReviewModeButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let mode: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .background(
                isSelected
                ? LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                : LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? color : Color.gray, lineWidth: isSelected ? 3 : 2)
            )
            .shadow(color: isSelected ? color.opacity(0.5) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct APIKeyInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🪄 Was ist ein API-Schlüssel?")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Ein API-Schlüssel ermöglicht der App, künstliche Intelligenz zu nutzen, um automatisch Übersetzungen und Beispielsätze zu erstellen.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📝 Wie bekomme ich einen?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                StepView(number: 1, text: "Gehe zu platform.openai.com")
                                StepView(number: 2, text: "Erstelle ein kostenloses Konto")
                                StepView(number: 3, text: "Navigiere zu \"API Keys\"")
                                StepView(number: 4, text: "Klicke \"Create new secret key\"")
                                StepView(number: 5, text: "Kopiere den Schlüssel und füge ihn hier ein")
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💰 Was kostet das?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Sehr wenig! Ungefähr $0.01 pro 50 Worte. Für typische Nutzung: ~$1-2 pro Monat.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Demo-Modus ist immer kostenlos!")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔒 Ist das sicher?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Ja! Der Schlüssel wird nur lokal auf deinem Gerät gespeichert und nie weitergegeben.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("API-Schlüssel Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct StepView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.black)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Google Vision Info View
struct GoogleVisionInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔵 Was ist Google Cloud Vision?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Google Cloud Vision API bietet sehr genaue Texterkennung (OCR) für Bilder. Es ist besonders gut bei mehrsprachigen Texten und komplexen Layouts - perfekt für Lehrbücher!")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📝 Wie bekomme ich einen API-Schlüssel?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                StepView(number: 1, text: "Gehe zu console.cloud.google.com")
                                StepView(number: 2, text: "Erstelle ein Projekt (oder wähle ein bestehendes)")
                                StepView(number: 3, text: "Aktiviere \"Cloud Vision API\" in der Bibliothek")
                                StepView(number: 4, text: "Gehe zu \"APIs & Services\" → \"Credentials\"")
                                StepView(number: 5, text: "Klicke \"Create Credentials\" → \"API Key\"")
                                StepView(number: 6, text: "Kopiere den Schlüssel (beginnt mit 'AIza...')")
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💰 Was kostet das?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("$0.0015 pro Bild (~€0.0014)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Das bedeutet: 100 Bilder = ~$0.15 | 1000 Bilder = ~$1.50")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Erste 1000 Anfragen pro Monat sind KOSTENLOS! 🎉")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.top, 4)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🆚 Google Vision vs Apple Vision")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ComparisonRow(
                                    icon: "🍎",
                                    title: "Apple Vision",
                                    pros: "Kostenlos, Offline, Privat",
                                    cons: "Weniger genau bei komplexen Layouts"
                                )
                                
                                ComparisonRow(
                                    icon: "🔵",
                                    title: "Google Vision",
                                    pros: "Sehr genau, Multi-Sprache, Dokumente",
                                    cons: "Kostet Geld, Internet erforderlich"
                                )
                            }
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.2))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🔒 Ist das sicher?")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                            
                            Text("Ja! Der API-Schlüssel wird nur lokal auf deinem Gerät gespeichert. Bilder werden temporär zu Google gesendet für OCR, aber nicht dauerhaft gespeichert.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Google Vision Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct ComparisonRow: View {
    let icon: String
    let title: String
    let pros: String
    let cons: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.title3)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                Text(pros)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            HStack(spacing: 4) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text(cons)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [UserProgress.self])
}
