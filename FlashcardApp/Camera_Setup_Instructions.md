# 📷 Camera Scanner - Setup Instructions

## ⚙️ Required: Add Camera Permission to Info.plist

To use the camera scanner feature, you **must** add the camera usage description to your `Info.plist` file.

---

## 🔧 Setup Steps (Xcode)

### Method 1: Using Xcode UI

1. **Open your project in Xcode**
2. **Select your app target** (FlashcardApp)
3. **Go to Info tab**
4. **Click the "+" button** to add a new key
5. **Type**: `Privacy - Camera Usage Description`
6. **Value**: `Wir brauchen Kamera-Zugriff um Vokabellisten aus deinem Lehrbuch zu scannen.`

### Method 2: Edit Info.plist Directly

1. **Right-click `Info.plist`** in Project Navigator
2. **Open As → Source Code**
3. **Add this before the closing `</dict>`**:

```xml
<key>NSCameraUsageDescription</key>
<string>Wir brauchen Kamera-Zugriff um Vokabellisten aus deinem Lehrbuch zu scannen.</string>
```

---

## 📝 English Version (Optional)

If you want an English description:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan vocabulary lists from your textbook.</string>
```

---

## ✅ Verify It Works

1. **Build and run** your app on a device (camera doesn't work in Simulator)
2. **Tap "+" button** on dashboard
3. **Tap camera icon** (📷) in top-right
4. **First time**: iOS will show permission alert
5. **Grant permission** → Camera opens
6. **Scan some text** to test!

---

## 🐛 Troubleshooting

### "Camera permission denied"
**Fix**: 
1. Go to Settings → FlashcardApp → Camera
2. Turn on Camera access
3. Restart app

### "Camera not available"
**Possible causes**:
- Running in Simulator (camera not supported)
- iPhone X or older (DataScannerViewController requires A12+)
- iOS 15 or earlier (needs iOS 16+)

**Solution**: Test on real device with iOS 16+ and iPhone XS or newer

### Permission alert doesn't appear
**Fix**:
1. Check Info.plist has `NSCameraUsageDescription`
2. Clean build folder (Cmd+Shift+K)
3. Delete app from device
4. Rebuild and reinstall

---

## 📱 Device Requirements

### ✅ Supported
- **iOS**: 16.0 or later
- **Devices**: 
  - iPhone XS and newer
  - iPad Pro (2018) and newer
  
### ❌ Not Supported
- iPhone X and older
- iOS 15 and earlier
- Simulator (no camera hardware)

---

## 🔒 Privacy Notes

- Camera is **only used** when user opens scanner
- No images are saved to device
- Text recognition happens **on-device** (VisionKit)
- No data sent to servers
- Permission can be revoked anytime in Settings

---

## 🎉 You're Done!

Once the permission is added, the camera scanner will work perfectly! 📸✨

**Next**: Build on device and test with real textbook!
