# Google Cloud Vision API Setup Guide

## Overview

Google Cloud Vision API has been integrated as an optional OCR provider for the camera scanner. It provides significantly better text recognition than Apple's Vision framework, especially for:
- Multi-language text (Spanish/German vocabulary lists)
- Complex layouts (textbook columns)
- Low-quality images
- Handwritten or stylized text

## Getting Started

### Step 1: Enable Google Cloud Vision API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select an existing one
3. Navigate to **APIs & Services** → **Library**
4. Search for "Cloud Vision API"
5. Click **Enable**

### Step 2: Create API Credentials

1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Copy the generated API key (starts with `AIza...`)
4. **(Recommended)** Restrict the API key:
   - Click on the key to edit it
   - Under "API restrictions", select "Restrict key"
   - Choose only "Cloud Vision API"
   - Save

### Step 3: Set Up Billing

Google Cloud Vision requires billing to be enabled:
- Go to **Billing** in the console
- Link a credit card
- Don't worry: First 1,000 requests per month are **FREE**
- After that: $1.50 per 1,000 images

### Step 4: Add API Key to App

1. Open the app and go to **Settings** (⚙️)
2. Scroll to **KAMERA-OCR** section
3. Paste your API key into the "Google Cloud API Key" field
4. Look for the green checkmark: "Google Vision aktiv"

## Using Google Vision in Camera Scanner

1. Open Camera Scanner (📷)
2. Toggle **"Google Cloud Vision OCR"** (blue toggle)
3. Take a photo or upload from gallery
4. Google Vision will process the image instead of Apple Vision

## Cost Breakdown

| Volume | Cost |
|--------|------|
| First 1,000 images/month | **FREE** 🎉 |
| 100 images | ~$0.15 |
| 1,000 images | ~$1.50 |
| 10,000 images | ~$15.00 |

**Typical Student Use:** ~5-20 images per month = **FREE**

## Comparison: Google vs Apple Vision

### Apple Vision (Built-in)
✅ **Pros:**
- Free
- Works offline
- Completely private
- Fast

❌ **Cons:**
- Less accurate on complex layouts
- Struggles with multi-language text
- May miss words in textbooks

### Google Cloud Vision
✅ **Pros:**
- **Much more accurate** (especially for textbooks)
- Better multi-language support
- Handles complex layouts well
- Document-optimized OCR

❌ **Cons:**
- Costs money (after 1,000 requests)
- Requires internet connection
- Sends images to Google temporarily

## Recommendation

**For textbook scanning:** Use Google Vision
- More reliable word extraction
- Worth the small cost for better results

**For occasional use:** Stick with Apple Vision
- Free and good enough for simple text

## Troubleshooting

### "Google Vision Fehler: HTTP 403"
- Your API key is restricted. Check "API restrictions" in Cloud Console
- Make sure "Cloud Vision API" is allowed

### "Netzwerkfehler"
- Check your internet connection
- Google Vision requires network access

### No text detected
- Try better lighting
- Hold camera steady
- Make sure text is in focus
- Consider taking photo from gallery instead of live camera

## Privacy Note

When using Google Vision:
- Images are sent to Google Cloud for processing
- Text is extracted and returned
- **Images are NOT stored permanently** by Google
- Your API key is stored only on your device
- You control your own API usage and billing

## API Key Security

⚠️ **Best Practices:**
1. Never share your API key publicly
2. Use API restrictions in Cloud Console
3. Monitor usage in Cloud Console
4. Regenerate key if compromised

## Support

If you have issues:
1. Check Cloud Console for error messages
2. Verify billing is enabled
3. Ensure Vision API is enabled for your project
4. Check API key restrictions

---

**Happy scanning! 📸🎓**
