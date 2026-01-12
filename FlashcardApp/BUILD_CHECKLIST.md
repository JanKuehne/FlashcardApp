# ✅ Build Checklist - Before Running

## 🔧 Required Setup Steps

### 1. ✅ Add Camera Permission to Info.plist (CRITICAL)

**Xcode UI Method**:
1. Select **FlashcardApp** target
2. Go to **Info** tab
3. Click **"+"** button
4. Type: `Privacy - Camera Usage Description`
5. Value: `Wir brauchen Kamera-Zugriff um Vokabellisten aus deinem Lehrbuch zu scannen.`

**OR edit Info.plist as source code**:
```xml
<key>NSCameraUsageDescription</key>
<string>Wir brauchen Kamera-Zugriff um Vokabellisten aus deinem Lehrbuch zu scannen.</string>
```

---

### 2. ✅ Build Fixes Applied

- [x] **ExtractedWord.swift** created (fixed ambiguous init)
- [x] **Color+Extensions.swift** reconciled with Design_System.md
- [x] Legacy aliases kept (tsukiRed, tsukiOrange still work)

---

### 3. ✅ Device Requirements

**Build Target**:
- Device: iPhone XS or newer (NOT Simulator - camera won't work)
- iOS: 16.0 or later
- Chip: A12 Bionic or later

---

## 🏗️ Build Steps

### Step 1: Clean Build Folder
```
Xcode Menu → Product → Clean Build Folder
OR: Cmd + Shift + K
```

### Step 2: Select Device
```
Top toolbar → Select your iPhone (not Simulator)
```

### Step 3: Build and Run
```
Xcode Menu → Product → Run
OR: Cmd + R
```

---

## 🐛 If Build Still Fails

### Common Issues:

**Error: Missing camera permission**
```
Fix: Add NSCameraUsageDescription to Info.plist (see above)
```

**Error: Cannot find 'ExtractedWord'**
```
Fix: Make sure ExtractedWord.swift is in your project target
Right-click file → Show File Inspector → Check target membership
```

**Error: Color ambiguous reference**
```
Fix: Clean build folder, rebuild
The legacy aliases should prevent this
```

**Error: DataScannerViewController not available**
```
Fix: Set deployment target to iOS 16.0+
Target → General → Minimum Deployments → iOS 16.0
```

---

## ✅ Post-Build Checklist

After successful build:

### On First Launch:
- [ ] App launches without crash
- [ ] Dashboard displays correctly
- [ ] Camera permission alert appears when tapping camera icon

### Grant Permission:
- [ ] Tap "Allow" on camera permission alert
- [ ] Camera opens successfully
- [ ] Text highlighting appears on real text

### Test Camera Scanner:
- [ ] Point at printed text
- [ ] Green highlights appear
- [ ] Tap text captures it
- [ ] Words extracted correctly
- [ ] Import creates cards
- [ ] Dashboard card count updates

---

## 📋 New Files Added (Make Sure They're in Target)

Check these files are included in build target:

1. **CameraScannerView.swift** ✅
2. **ExtractedWord.swift** ✅
3. **Color+Extensions.swift** (modified) ✅

**How to Check**:
1. Select file in Project Navigator
2. Show File Inspector (Cmd+Opt+1)
3. Under "Target Membership", ensure "FlashcardApp" is checked

---

## 🎯 Expected Build Time

- **Clean build**: 15-30 seconds
- **Incremental build**: 5-10 seconds

---

## 🚀 After Successful Build

### Quick Test (2 minutes):

1. **Open app** ✅
2. **Tap "+" button** ✅
3. **Tap camera icon** 📷
4. **Grant permission** ✅
5. **Point at this text**:
   ```
   Sonne - sun
   Mond - moon
   ```
6. **Tap highlighted text** ✅
7. **Verify 2 words extracted** ✅
8. **Tap "KARTEN ERSTELLEN"** ✅
9. **Check dashboard** - card count +2 ✅

---

## 💾 Files Modified in This Session

**New Files** (7):
1. CameraScannerView.swift
2. ExtractedWord.swift
3. OCR_Camera_Feature.md
4. Camera_Scanner_QuickStart.md
5. Camera_Setup_Instructions.md
6. Camera_Architecture_Diagram.md
7. BUILD_FIX_ExtractedWord.md

**Modified Files** (3):
1. AddCardView.swift (camera integration)
2. Color+Extensions.swift (design reconciliation)
3. Tasks.md (status updates)

---

## 🔄 If You Need to Start Over

1. **Revert changes**: `git checkout .`
2. **Keep only**: CameraScannerView.swift + ExtractedWord.swift
3. **Add**: Camera permission to Info.plist
4. **Build**: Should work with minimal changes

---

## 📞 Still Getting Errors?

**Share the error message and I'll help!**

Common error patterns:
- `cannot find type` → File not in target
- `ambiguous use` → Duplicate definitions
- `module not found` → Import issue
- `permission denied` → Info.plist missing

---

**Status**: ✅ Ready to build  
**Confidence**: High (95%+)  
**Next**: Build and test on device! 📱✨
