# Bredenbook Visual Style Guide

**App Name**: Bredenbook  
**Purpose**: Manga-style language learning flashcard app  
**Target Audience**: Kids aged 8-10 (twin boys learning German)  
**Design Aesthetic**: Authentic manga/anime (Naruto-inspired)

---

## 🎨 Core Visual Identity

### Primary Style Keywords
```
Bold manga aesthetic
High contrast
Thick black outlines
Vibrant gradients
Dynamic energy
Comic book panels
Japanese influence
Action-packed
Kid-friendly
```

---

## 🖼️ Image Generation Prompts

### For App Icons & Branding

```
Style: Bold manga/anime aesthetic with thick black outlines
- High contrast colors
- Vibrant gradients (red, orange, purple, blue)
- Thick black manga outlines (3-5px)
- Dynamic composition
- Japanese influence (kanji, manga panels)
- Comic book energy
- Must work at small sizes (20x20 to 1024x1024 pixels)
- Simple, bold, instantly recognizable
- Black or dark background
```

### For Character Illustrations

```
Style: Chibi/cute anime characters with manga aesthetic
- Large expressive eyes
- Spiky or dynamic hair
- Bold black outlines around everything
- Vibrant colors with gradients
- Simple, iconic poses
- Kid-friendly appearance (ages 8-10)
- Action/energy lines (speed lines)
- Dramatic shadows with black outlines
- High contrast for visibility
- Comic book/manga panel style
```

### For Background Assets

```
Style: Manga/comic book backgrounds
- Geometric diagonal panels
- Bold speed lines
- Halftone dot patterns (optional)
- Dramatic lighting
- High contrast
- Black base with red/orange/purple accents
- Comic panel aesthetic
- Abstract and dynamic (not realistic)
```

---

## 🎨 Color Palette

### Primary Colors
```
Tsuki Red:    RGB(230, 51, 70)   / #E63346 / HSB(354°, 78%, 90%)
Tsuki Orange: RGB(255, 128, 56)  / #FF8038 / HSB(22°, 78%, 100%)
```

### Secondary Colors
```
Manga Blue:   RGB(0, 122, 255)   / #007AFF (iOS blue)
Manga Purple: RGB(175, 82, 222)  / #AF52DE
Manga Green:  RGB(52, 199, 89)   / #34C759
Warning Red:  RGB(255, 59, 48)   / #FF3B30
```

### Background Colors
```
Primary Black: RGB(0, 0, 0)      / #000000
Dark Gray:     RGB(28, 28, 30)   / #1C1C1E (rarely used)
```

### Text Colors
```
White Text:       RGB(255, 255, 255) / #FFFFFF
Orange Accent:    Tsuki Orange (for Japanese text)
Gray Secondary:   RGB(142, 142, 147) / #8E8E93 (60% opacity white)
```

### Gradients
```
Primary Action:   Blue → Purple (top-left to bottom-right)
Fire/Energy:      Red → Orange (top to bottom)
Success:          Green → Green 70% (left to right)
Manga Background: Tsuki Red 40% → Tsuki Orange 30%
```

---

## 📐 Design Specifications

### Borders & Outlines
```
Thick borders:     3-5px black strokes
Text outlines:     4-6px black shadow offset
Card borders:      3-4px solid black
Button borders:    3px solid black
Icon borders:      2-3px black outlines
```

### Corner Radius
```
Cards:            16px
Buttons (large):  16-20px
Buttons (small):  12px
Stats boxes:      16px
Modal sheets:     20px (top corners only)
```

### Shadows
```
Buttons:          Black 50% opacity, 8-12px radius, 4-6px y-offset
Success effects:  Orange 80% opacity, 20px radius
Cards:            Subtle black 30% opacity, 10px radius
```

### Spacing
```
Section spacing:  24px
Card spacing:     16px
Button spacing:   12px
Text spacing:     4-8px
Padding (cards):  16-20px
Padding (buttons): 12-16px vertical, 16-20px horizontal
```

---

## ✍️ Typography Style

### Font Characteristics
```
Font Family:      SF Rounded (system .rounded design)
Weights Used:     Black (900), Bold (700), Semibold (600)
Transform:        UPPERCASE for emphasis
Tracking:         1-2px for small caps text
Line Height:      1.2-1.4 (tight for manga feel)
```

### Font Sizes
```
Mega Title:       42-48pt (splash screen)
Hero Title:       32-36pt (dashboard title)
Title:            24-28pt (section headers)
Large Button:     20-24pt (main CTA)
Body:             16-18pt (card content)
Caption:          12-14pt (Japanese accents)
```

### Text Styling Technique
```
Manga Text Effect (layered):
1. Black shadow: Offset 4px right, 4px down
2. White stroke: Optional, 2px
3. Main text: Gradient (white → color)
4. Glow: Colored blur, 20px radius, 80% opacity
```

---

## 🎌 Japanese Text Usage

### When to Include Japanese Characters
```
✅ Always:
- Level indicators: "Lv" or "レベル"
- Completion: "完了" (complete)
- Start: "開始" (start)
- Learning: "学習" (learning)
- Success: "完!" (done!)

✅ Sometimes:
- Fire emoji: 🔥 (for streaks)
- Flags: 🇬🇧 🇪🇸 🇩🇪 (for languages)

❌ Never:
- Replace all English with Japanese (confusing for kids)
- Use kanji for main instructions
```

### Japanese Text Styling
```
Color:            Orange (Tsuki Orange)
Font Size:        Smaller than English (caption/caption2)
Weight:           Bold or Black
Placement:        Above or beside English text
Opacity:          60-100% (never too faint)
```

---

## 🎭 Manga Visual Elements

### Speed Lines
```
Usage:            Card flips, button presses, success moments
Style:            Diagonal white/light lines radiating outward
Opacity:          5-15% (subtle)
Width:            2-3px
Angle:            -15° to -25° (diagonal)
Distribution:     Evenly spaced, 40-60px apart
```

### Halftone Patterns
```
Usage:            Backgrounds (very subtle)
Style:            Circular dots in grid pattern
Dot Size:         3-5px diameter
Spacing:          6-10px between centers
Color:            White
Opacity:          3-8% (barely visible)
Note:             Use sparingly - can look messy if too strong
```

### Impact Stars/Bursts
```
Usage:            Success moments, correct answers, level-ups
Style:            4-point or 8-point stars radiating from center
Color:            Yellow, orange, white
Glow:             Heavy blur, 80% opacity
Animation:        Scale in + rotate + fade out
Duration:         0.3-0.6 seconds
```

### Comic Panel Lines
```
Usage:            Dashboard background, section dividers
Style:            Diagonal geometric shapes
Thickness:        Full sections (25-50% of screen width)
Fill:             Gradient (red-orange, opacity 30-60%)
Edges:            Sharp diagonal angles (not rounded)
```

### Sound Effect Text
```
Examples:         "SWOOSH!" "CORRECT!" "POW!" "BOOM!"
Font Size:        60-80pt
Weight:           Black (900)
Outline:          Thick black shadow (6px offset)
Glow:             Strong colored blur (20px radius)
Animation:        Scale in 0.3→1.2 + rotate -10°→+10° + fade out
Duration:         0.6-0.8 seconds
```

---

## 🖼️ Asset Requirements

### App Icon
```
Sizes Needed:     1024x1024 (App Store)
                  180x180, 120x120, 80x80, 60x60, 40x40, 29x29, 20x20 (iOS)
Format:           PNG, no transparency
Style:            Bold, simple, high contrast
Background:       Solid color or simple gradient
Content:          Icon/symbol/character (recognizable at 20px)
Border:           None (iOS adds automatically)
```

### Character Illustrations
```
Size:             300-600px square (for UI elements)
Format:           PNG with transparency OR solid background
Style:            Chibi/cute anime, manga outlines
Background:       Transparent or solid color
Usage:            Dashboard mascot, achievement badges, celebrations
```

### Background Images
```
Size:             1170x2532 (iPhone 14 Pro Max) or larger
Format:           PNG or JPG
Style:            Abstract manga panels, geometric shapes
Opacity:          Will be reduced to 30-60% in app
Details:          Keep simple - fine details will be lost
```

### Splash Screen Assets
```
Size:             600-800px square (centered)
Format:           PNG with transparency preferred
Style:            Main branding image (twin characters)
Background:       Transparent (app adds black background)
Usage:            Displays for 2.5 seconds on app launch
```

---

## 🎨 Asset Examples for AI Prompts

### Example 1: App Icon
```
Create an app icon for "Bredenbook", a manga-style flashcard app.

Style: Bold manga aesthetic
- Two chibi anime twins (boy and girl) side by side
- Large expressive eyes, spiky hair
- Thick black manga outlines (4px)
- One holds a flashcard, other gives thumbs up
- Vibrant red-orange gradient background
- Black border around characters
- Simple composition (works at 20x20 pixels)
- High contrast, bold colors
- Comic book energy

Colors: Black outlines, red (#E63346), orange (#FF8038), white, blue
Size: 1024x1024px
Format: PNG
Must be simple and instantly recognizable.
```

### Example 2: Character Mascot
```
Create a chibi anime character for a kids' learning app.

Style: Cute manga mascot
- Age 8-10 appearance (kid-friendly)
- Large eyes, happy expression
- Spiky anime hair (blue or purple)
- Wearing casual clothes (t-shirt, shorts)
- Dynamic pose (celebrating or studying)
- Thick black manga outlines (3-4px)
- Vibrant colors with gradients
- Manga-style energy lines behind character
- Simple iconic design
- Transparent background

Colors: Blue/purple theme, black outlines, colorful accents
Size: 400x400px
Format: PNG with transparency
For use: Dashboard mascot, shows user's learning progress
```

### Example 3: Background Asset
```
Create a manga-style background for a mobile app dashboard.

Style: Abstract manga panels
- Diagonal geometric shapes (left and right sides)
- Red-orange gradient fills
- Comic book panel aesthetic
- Sharp angular lines (not curves)
- Dynamic composition suggesting energy
- High contrast against black
- Speed lines radiating diagonally
- Abstract (not realistic)

Colors: Red (#E63346), orange (#FF8038), black background
Size: 1170x2532px (iPhone proportions)
Format: PNG or JPG
Usage: Background layer (will be overlaid with UI at 40% opacity)
Keep it simple - fine details will be lost
```

### Example 4: Achievement Badge
```
Create an achievement badge icon for a language learning app.

Achievement: "Week Warrior" (7-day streak)
Style: Manga badge icon
- Centered flame emoji or fire symbol 🔥
- Thick black manga outlines
- Orange-red gradient background
- Circular or star-shaped badge border
- Bold black border (4px)
- Number "7" incorporated subtly
- High contrast, vibrant
- Comic book style

Colors: Orange (#FF8038), red (#E63346), yellow, black outlines, white accents
Size: 256x256px
Format: PNG with transparency or solid background
Must be recognizable at 60x60px size
```

---

## 🚫 What to Avoid

### Visual Don'ts
```
❌ Realistic/photographic style
❌ Pastels or muted colors
❌ Thin or delicate lines
❌ White or light backgrounds
❌ Gradients without solid colors
❌ Fine details that won't scale down
❌ Low contrast
❌ Serif fonts
❌ Rounded cute fonts (use bold instead)
❌ Too much text in images
❌ Complex patterns (keep it simple)
```

### Style Don'ts
```
❌ Kawaii/cute anime (we want cool action manga)
❌ Shojo manga style (too soft)
❌ Chibi only for mascots (other art more dynamic)
❌ Excessive Japanese text (kids can't read it)
❌ American comic book style (want Japanese manga)
❌ Pixar/Disney style (too Western)
❌ Minimalist flat design (needs more energy)
```

---

## ✅ Design Checklist

### Before Generating Assets:
```
[ ] Checked color palette (using Tsuki Red/Orange)
[ ] Thick black outlines specified (3-5px)
[ ] High contrast confirmed
[ ] Size requirements noted
[ ] Format specified (PNG/JPG)
[ ] Transparency needs determined
[ ] Scaling tested (works at small sizes?)
[ ] Manga aesthetic keywords included in prompt
[ ] References similar to Naruto/action manga
[ ] Kid-friendly confirmed (ages 8-10)
```

### After Receiving Assets:
```
[ ] Outlines are thick enough (visible at small sizes)
[ ] Colors match brand palette
[ ] High contrast achieved
[ ] Works at smallest required size (20x20 for icons)
[ ] Style matches existing app aesthetic
[ ] Energy/dynamism present (not flat/boring)
[ ] Black backgrounds work (or transparent)
[ ] No text unless specifically requested
```

---

## 🎯 Quick Reference Prompts

### For Icons/Badges
```
"Manga style icon, thick black outlines, vibrant [COLOR] gradient, 
high contrast, bold design, works at small sizes, 1024x1024px PNG"
```

### For Characters
```
"Chibi anime character, manga aesthetic, thick black outlines, 
large eyes, dynamic pose, vibrant colors, kid-friendly, 
400x400px PNG with transparency"
```

### For Backgrounds
```
"Abstract manga background, diagonal geometric panels, 
red-orange gradients, speed lines, black background, 
high contrast, 1170x2532px PNG"
```

### For Celebrations/Effects
```
"Manga explosion effect, starburst, impact stars, speed lines, 
vibrant yellow-orange, thick black outlines, transparent background, 
600x600px PNG"
```

---

## 📚 Reference Examples

### Visual Style Inspiration
- **Naruto** (anime/manga) - action-packed, bold outlines
- **Dragon Ball** - dynamic energy, speed lines
- **My Hero Academia** - modern manga aesthetic
- **Duolingo** - gamification (but we're more manga-styled)
- **Japanese manga panels** - geometric layouts, bold text

### Color Inspiration
- **Sunset gradients** (red-orange)
- **Neon signs** (high contrast, vibrant)
- **Comic book covers** (bold, eye-catching)
- **Anime title cards** (dramatic, energetic)

---

## 💡 Tips for AI Image Generation

### Prompting Best Practices
1. **Lead with style keywords**: "Manga style", "thick black outlines", "high contrast"
2. **Specify exact colors**: RGB or HEX values when possible
3. **Define line thickness**: "3-5px black borders"
4. **Mention scale requirements**: "Must work at 20x20 pixels"
5. **Reference comparisons**: "Similar to Naruto manga aesthetic"
6. **Be specific about complexity**: "Simple, bold, iconic" for small assets
7. **Specify background**: "Black background" or "transparent background"
8. **Include technical specs**: "1024x1024px PNG"

### Iterating on Generations
1. First generation: Get overall composition and style
2. Second: Refine colors to match brand palette
3. Third: Adjust line thickness and contrast
4. Fourth: Simplify if needed for small sizes
5. Final: Test at actual usage size before approving

---

## 📞 Contact & Questions

When working with external designers/AI:
- Share this guide as reference
- Provide existing app screenshots for context
- Request multiple variations for review
- Test assets at actual sizes before final approval
- Ensure consistency with existing visual language

---

**Remember**: Bredenbook is all about **bold, energetic, manga aesthetic**. Think Naruto energy, not Kawaii cuteness. Every visual should feel dynamic, high-contrast, and exciting for 8-10 year old boys who love action anime! 🎌⚡✨

---

_This style guide should be referenced for all visual asset creation, whether by AI tools, human designers, or external contractors._
