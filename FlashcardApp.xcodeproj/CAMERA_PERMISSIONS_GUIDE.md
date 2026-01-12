# Camera Permissions Setup Guide

## Adding Camera Permission to Your iOS App

In modern Xcode projects, you don't need to manually edit an Info.plist file. Instead, you add permissions through the Xcode project settings.

### Step-by-Step Instructions:

1. **Open your project in Xcode**

2. **Select your project** in the Project Navigator (left sidebar)

3. **Select your app target** (FlashcardApp)

4. **Go to the "Info" tab**

5. **Locate or add these privacy keys:**
   - Look for "Custom iOS Target Properties" or "Custom macOS Properties" section
   - Click the **+** button to add a new entry
   
6. **Add Camera Permission:**
   - **Key**: `Privacy - Camera Usage Description`
   - **Value**: `This app needs camera access to scan vocabulary from your textbook`
   
7. **Optional: Add Photo Library Permission (if needed):**
   - **Key**: `Privacy - Photo Library Usage Description`
   - **Value**: `This app needs photo access to import vocabulary images`

### Alternative Method (if Info.plist file exists):

If you can find an `Info.plist` file in your project (usually in the project root folder):

1. Right-click on `Info.plist` and select "Open As" → "Source Code"
2. Add these lines inside the `<dict>` tags:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan vocabulary from your textbook</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo access to import vocabulary images</string>
```

### Where to Find Info.plist:

In newer Xcode projects (Xcode 13+):
- The Info.plist is often **generated automatically**
- You manage it through **Target Settings → Info tab**
- You won't see a physical Info.plist file in your project navigator

### Testing Camera Access:

After adding permissions:
1. **Clean Build Folder**: Product → Clean Build Folder (Shift+Cmd+K)
2. **Rebuild the app**: Cmd+B
3. **Run on a real device** (camera features don't work in Simulator)
4. When you tap the camera button, iOS will show a permission dialog

### Troubleshooting:

**If camera still doesn't work:**
- Make sure you're testing on a **physical device** (not Simulator)
- Check iOS Settings → Privacy & Security → Camera → FlashcardApp (enable it)
- Delete the app and reinstall to reset permissions

**If permission dialog doesn't appear:**
- Delete the app from your device
- Clean build folder in Xcode
- Rebuild and reinstall

---

## What Was Fixed in the Code:

The build error `Ambiguous use of 'init'` was caused by using an unavailable parameter in `DataScannerViewController` initialization. 

**Removed parameter:**
- `isHighlightingEnabled: true` (not available in all iOS versions)

The app should now build successfully! 🎉
