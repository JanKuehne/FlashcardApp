# 🧪 Bilingual Testing Quick Reference

## 🎯 10 Mock Words - Test These!

### 🇬🇧 **English Examples**
```
1. Sonne  → sun      → "The sun shines brightly."
2. Mond   → moon     → "The moon is round."
3. Apfel  → apple    → "The apple is red."
4. Hund   → dog      → "The dog barks loudly."
5. Katze  → cat      → "The cat sleeps quietly."
6. Haus   → house    → "The house is big."
7. Baum   → tree     → "The tree is old."
8. Blume  → flower   → "The flower blooms."
9. Auto   → car      → "The car drives fast."
10. Buch  → book     → "The book is interesting."
```

### 🇪🇸 **Spanish Examples**
```
1. Sonne  → sol       → "El sol brilla."
2. Mond   → luna      → "La luna es redonda."
3. Apfel  → manzana   → "La manzana es roja."
4. Hund   → perro     → "El perro ladra."
5. Katze  → gato      → "El gato duerme."
6. Haus   → casa      → "La casa es grande."
7. Baum   → árbol     → "El árbol es viejo."
8. Blume  → flor      → "La flor es bonita."
9. Auto   → coche     → "El coche es rápido."
10. Buch  → libro     → "El libro es interesante."
```

---

## ✅ Testing Checklist

### **Basic Flow (5 min)**

**English Card:**
- [ ] Tap +
- [ ] See 🇬🇧 selected
- [ ] Type: Sonne → sun
- [ ] Tap AI 🪄
- [ ] See: "The sun shines brightly."
- [ ] Save
- [ ] "English" deck appears

**Spanish Card:**
- [ ] Tap +
- [ ] Switch to 🇪🇸
- [ ] Type: Sonne → sol
- [ ] Tap AI 🪄
- [ ] See: "El sol brilla."
- [ ] Save
- [ ] "Español" deck appears

**Review Both:**
- [ ] Review English deck
- [ ] Complete → "WELL DONE!"
- [ ] Review Spanish deck
- [ ] Complete → "¡MUY BIEN!"

---

### **With Username (2 min)**

- [ ] Settings → Name: "Henri"
- [ ] Review English → "WELL DONE, HENRI!"
- [ ] Review Spanish → "¡MUY BIEN, HENRI!"

---

### **Edge Cases (3 min)**

**Language Switching:**
- [ ] Start adding English card
- [ ] Switch to Spanish mid-way
- [ ] Target field clears ✓
- [ ] Add Spanish card ✓

**Unknown Words:**
- [ ] Add: Blitz → lightning
- [ ] AI generates fallback ✓
- [ ] English: "The lightning is nice."
- [ ] Spanish: "El/La lightning es bonito/a."

**Deck Auto-Creation:**
- [ ] Delete all decks
- [ ] Add first card → deck created ✓

---

## 🎨 UI Elements to Verify

### **Language Picker:**
```
┌──────────────────────┐
│   ZIELSPRACHE        │
│  🇬🇧 EN  │  🇪🇸 ES  │  ← Segmented control
└──────────────────────┘
```

### **Dynamic Labels:**
- English: `🇬🇧 ENGLISH`
- Spanish: `🇪🇸 ESPAÑOL`

### **Dynamic Placeholders:**
- English: `e.g. sun`
- Spanish: `p.ej. sol`

### **Dynamic Tips:**
- English: `"...für englische Beispielsätze!"`
- Spanish: `"...für spanische Beispielsätze!"`

---

## 🐛 What to Watch For

### **✅ Should Work:**
- Switch languages → fields clear
- Add multiple cards per language
- Review keeps languages separate
- Stats combine across languages
- Username in both success messages
- Deck flags display correctly

### **❌ Should NOT Happen:**
- Cards mixed in same deck
- Wrong language example
- Lost cards when switching
- Crash when switching languages
- Stats reset

---

## 📱 Demo Script (60 seconds)

**For Showing to Kids:**

```
1. "Let's learn English!"
   → Add: Hund → dog
   → AI: "The dog barks loudly."
   → Save ✓

2. "Now let's try Spanish!"
   → Switch to 🇪🇸
   → Add: Hund → perro
   → AI: "El perro ladra."
   → Save ✓

3. "Look, two decks!"
   → English 🇬🇧 (1 card)
   → Español 🇪🇸 (1 card)

4. "Let's test English!"
   → Start review
   → Flip cards
   → Complete
   → "WELL DONE, HENRI!" 🎉

5. "Now Spanish!"
   → Start review
   → Flip cards
   → Complete
   → "¡MUY BIEN, HENRI!" 🎉
```

---

## 💾 Data Verification

### **After Adding 5 English + 5 Spanish Cards:**

**Check Decks:**
```swift
decks.count == 2
decks[0].name == "English"
decks[0].targetLanguage == "en"
decks[0].languageFlag == "🇬🇧"

decks[1].name == "Español"
decks[1].targetLanguage == "es"
decks[1].languageFlag == "🇪🇸"
```

**Check Cards:**
```swift
englishCards.count == 5
spanishCards.count == 5

englishCards.allSatisfy { $0.deckId == englishDeck.id }
spanishCards.allSatisfy { $0.deckId == spanishDeck.id }
```

**Check Stats:**
```swift
progress.totalCardsReviewed == 10  // Combined!
progress.totalXP > 0               // Global
```

---

## 🎬 Recording Tips

**If Making a Demo Video:**

1. **Clean Start:**
   - Delete all decks
   - Set username to "Demo"
   - Enable demo mode

2. **Show English:**
   - Add 3 English cards
   - Use: Sonne, Hund, Katze
   - Show AI generation
   - Review session
   - Show "WELL DONE!"

3. **Show Spanish:**
   - Switch to Spanish
   - Add 3 Spanish cards
   - Same words: Sonne, Hund, Katze
   - Show AI generation
   - Review session
   - Show "¡MUY BIEN!"

4. **Highlight:**
   - Two separate decks with flags
   - Different success messages
   - Personalized with username
   - Smooth language switching

---

## 🎯 Success Metrics

**Feature is working if:**
- ✅ Can add English cards
- ✅ Can add Spanish cards
- ✅ Decks stay separate
- ✅ AI generates correct language
- ✅ Success messages match language
- ✅ No crashes or data loss
- ✅ UI updates dynamically

---

## 🚨 Troubleshooting

### **Problem: Language picker not showing**
- Check: AddCardView loaded correctly
- Solution: Rebuild app

### **Problem: Wrong language example**
- Check: targetLanguage passed correctly
- Check: MockLLMService has Spanish dict
- Solution: Verify generateExample() call

### **Problem: Success message in German**
- Check: reviewedDeck is set
- Check: successMessage computed property
- Solution: Verify deck.targetLanguage

### **Problem: Cards mixed in deck**
- Check: createDeckForLanguage() logic
- Check: Deck.targetLanguage saved
- Solution: Verify deck finding logic

---

## 📊 Expected Results

### **After Full Test:**

**Dashboard:**
```
📚 English 🇬🇧       📚 Español 🇪🇸
   10 cards             10 cards
   85% accuracy         70% accuracy
```

**Progress:**
```
Level: 5
XP: 1250
Streak: 3 days
Total Cards: 20  ← Combined!
```

**Settings:**
```
Profile: Henri
Last Language: es  ← Remembered
Demo Mode: On
```

---

## ✅ Final Verification

**All must pass:**
- [ ] 10 English mock examples work
- [ ] 10 Spanish mock examples work
- [ ] Segmented picker switches cleanly
- [ ] Labels update dynamically
- [ ] Decks auto-create per language
- [ ] Reviews stay language-specific
- [ ] Success messages localized
- [ ] Username personalizes messages
- [ ] No data loss on language switch
- [ ] Stats combine correctly
- [ ] App remembers last language
- [ ] UI remains in German
- [ ] No crashes
- [ ] Smooth animations

---

**If all ✅ → Feature Complete!** 🎉

---

**Quick Test Time:** 10 minutes  
**Full Test Time:** 20 minutes  
**Demo Time:** 60 seconds  

---

**¡Viel Spaß beim Testen!** (Have fun testing!) 🧪✨
