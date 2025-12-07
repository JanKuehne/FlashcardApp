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
    @State private var useMockLLM: Bool = false
    @State private var showingAPIKeyInfo = false
    @State private var dailyGoal: Int = 20
    
    private let settings = AppSettings.shared
    
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
                    // Daily Goal Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("TAGESZIEL")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("\(dailyGoal) Karten")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(dailyGoal) },
                                set: { dailyGoal = Int($0) }
                            ), in: 5...50, step: 5)
                            .tint(.blue)
                            
                            Text("Wie viele Karten möchtest du täglich lernen?")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("LERNZIELE")
                            .foregroundColor(.white.opacity(0.7))
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
        useMockLLM = settings.useMockLLM
        dailyGoal = progress.dailyGoal
    }
    
    func saveSettings() {
        settings.openAIAPIKey = apiKey
        settings.useMockLLM = useMockLLM
        progress.dailyGoal = dailyGoal
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

#Preview {
    SettingsView()
        .modelContainer(for: [UserProgress.self])
}
