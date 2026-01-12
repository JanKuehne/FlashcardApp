# How to Find and Remove Demo Card Seed Data

## 🎯 **Quick Instructions**

### **Step 1: Find the Main App File**

In Xcode, look for a file named one of these:
- `FlashcardAppApp.swift` (most likely)
- `FlashcardApp.swift`
- `<YourProjectName>App.swift`
- Any file with `@main` at the top

**How to find it:**
1. In Xcode Project Navigator (left sidebar)
2. Look for a file with the app icon next to it
3. OR search for `@main` in the project

---

### **Step 2: Look for Seed Data Code**

Open that file and search (⌘F) for:
- "Demo deck"
- "Demo Deck"  
- "50" (number of demo cards)
- ".onAppear"
- "seedData"
- "initialData"

---

### **Step 3: What the Code Probably Looks Like**

```swift
@main
struct FlashcardAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Flashcard.self, Deck.self])
                .onAppear {
                    seedDemoDataIfNeeded()  // ← REMOVE THIS LINE
                }
        }
    }
    
    // ← REMOVE THIS ENTIRE FUNCTION
    func seedDemoDataIfNeeded() {
        let context = // ...
        
        // Check if demo deck exists
        let descriptor = FetchDescriptor<Deck>(
            predicate: #Predicate { $0.name == "Demo Deck" }
        )
        
        guard let decks = try? context.fetch(descriptor), decks.isEmpty else {
            print("Demo deck already exists, skipping seed")  // ← This is the console message you saw!
            return
        }
        
        // Create demo deck
        let demoDeck = Deck(name: "Demo Deck", targetLanguage: "es")
        context.insert(demoDeck)
        
        // Create 50 demo cards
        for i in 1...50 {  // ← Look for this!
            let card = Flashcard(
                front: "German Word \(i)",
                back: "Spanish Word \(i)",
                deckId: demoDeck.id
            )
            context.insert(card)
        }
        
        try? context.save()
    }
}
```

---

### **Step 4: Remove the Seed Code**

**Option A: Delete the function and its call**
```swift
@main
struct FlashcardAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Flashcard.self, Deck.self])
                // ✅ REMOVED: .onAppear { seedDemoDataIfNeeded() }
        }
    }
    
    // ✅ DELETED: func seedDemoDataIfNeeded() { ... }
}
```

**Option B: Comment it out (for testing)**
```swift
.modelContainer(for: [Flashcard.self, Deck.self])
// .onAppear {
//     seedDemoDataIfNeeded()
// }

// func seedDemoDataIfNeeded() {
//     // ... all the seed code
// }
```

---

### **Step 5: Clean Existing Data**

Since demo cards already exist in your current app installation:

**Method 1: Delete and Reinstall**
1. Delete app from simulator/device
2. Clean Build Folder (⌘⇧K)
3. Build and Run (⌘R)
4. App should start with NO decks/cards

**Method 2: Reset Simulator**
1. Simulator → Device → Erase All Content and Settings...
2. Build and Run
3. App should start with NO decks/cards

**Method 3: Add Reset Code (Temporary)**
```swift
.onAppear {
    // TEMPORARY: Delete all data on launch
    let context = // your model context
    try? context.delete(model: Deck.self)
    try? context.delete(model: Flashcard.self)
    try? context.save()
}
```

---

## 🔍 **Alternative Locations**

If you can't find it in the main app file, check:

### **ContentView.swift**
```swift
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            // ...
        }
        .onAppear {
            seedDataIfNeeded(context: modelContext)  // ← Look here
        }
    }
}
```

### **DeckListView.swift**
```swift
struct DeckListView: View {
    var body: some View {
        // ...
        .onAppear {
            createDemoDataIfNeeded()  // ← Or here
        }
    }
}
```

### **Separate DataManager/DatabaseManager file**
```swift
class DataManager {
    static func seedInitialData(context: ModelContext) {
        // Demo deck creation here
    }
}
```

---

## 🧪 **Verify It's Gone**

After making changes:

1. **Delete app** from device/simulator
2. **Clean build** (⌘⇧K)
3. **Build and run** (⌘R)
4. **Launch app**
5. **Expected result:**
   - ✅ No decks visible
   - ✅ Empty state shows
   - ✅ Console shows NO "Demo deck already exists" message
   - ✅ Can create first deck manually

---

## 📋 **Search Strings to Use in Xcode**

Press **⌘⇧F** (Find in Project) and search for:

1. `"Demo deck already exists"`
2. `"Demo Deck"`
3. `for i in 1...50`
4. `seedData`
5. `seedDemoData`
6. `initialData`
7. `@main`

One of these searches should reveal the location!

---

## 🎯 **Console Message**

You saw this in the console:
```
Demo deck already exists, skipping seed
```

This exact string is in the seed code. Search for:
```swift
print("Demo deck already exists, skipping seed")
```

This will take you RIGHT to the seed function!

---

## 💡 **Quick Tip**

The **fastest way** to find it:

1. Press **⌘⇧F** (Find in Project)
2. Type: `Demo deck already exists`
3. Press Enter
4. Xcode will show you the exact file and line!

---

## ✅ **After You Find It**

Once you locate the seed code:

1. **Take a screenshot** (in case you need to restore it)
2. **Comment out** the function call (don't delete yet)
3. **Build and test**
4. **If everything works**, delete the function entirely
5. **Commit the change** to version control

---

## 🚨 **Don't Delete These**

Make sure you're only removing DEMO/SEED data, not:
- ❌ The ModelContainer setup
- ❌ SwiftData model definitions
- ❌ Actual user data
- ❌ App initialization code

**Only remove:**
- ✅ Demo deck creation
- ✅ Demo card creation (the 50 cards)
- ✅ Seed data functions

---

**Good luck! The seed code is definitely in one of these locations.** 🎯

Use **⌘⇧F** to search for `"Demo deck already exists"` - that's your smoking gun! 🔍
