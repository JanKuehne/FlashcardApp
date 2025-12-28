
# Design System - Manga Aesthetic

## Color Palette

### Primary Colors
- **Primary Red**: `#EF4444` - Actions, positive feedback, main theme
- **Primary Orange**: `#F97316` - Secondary actions, warm accents
- **Gradient**: Red→Orange (buttons, XP bars, primary interactions)

### Accent Colors
- **Orange (Streak)**: `#F97316` - Streak, fire theme
- **Purple**: `#8B5CF6` - Keep for variety, special elements
- **Green**: `#10B981` - Correct answers, success
- **Yellow**: `#FBBF24` - Achievements, celebration

### Background
- **Black**: `#000000` - Main background (manga paper)
- **Dark Card**: `#111827` - Card backgrounds
- **Border**: `rgba(255, 255, 255, 0.08)` - Subtle borders

### Text
- **Primary**: `#FFFFFF` - Main text
- **Secondary**: `#9CA3AF` - Subtitles
- **Muted**: `#6B7280` - Less important info

## Typography

### Font System
- **Primary**: SF Rounded (Apple system font)
- **Style**: Black weight (900), bold outlines
- **Fallback**: Monaco for monospace (XP, stats)

### Hierarchy
- **Hero Numbers**: 48-80pt, black weight
- **Titles**: 28-36pt, black weight, uppercase
- **Body**: 16-18pt, semibold
- **Captions**: 12-14pt, bold, uppercase

### Text Effects
- **Always use**: Black outline/shadow (4-6px offset)
- **White text**: Black shadow for depth
- **Colored text**: White stroke + black shadow

## Manga Elements

### Japanese Text Usage
- **日** (day) - Streak indicator
- **Lv** - Level prefix
- **完** (complete) - Daily goal achieved
- **開始** (start) - Begin button
- **今日** (today) - Today's goal
- **正解** (correct) - Correct count

### Manga Visual Effects
1. **Speed Lines**: Red/orange gradients, diagonal motion
2. **Impact Stars**: Yellow stars radiating from center
3. **Halftone Dots**: Subtle background texture (3% opacity)
4. **Sound Effects**: Bold text with outlines (SWOOSH!, CORRECT!)
5. **Starburst**: Yellow/orange rays for celebrations

### Card Design
- **Front (Question)**: White card, black text, thick black border (6px)
- **Back (Answer)**: Green card, white text, black border
- **Flip Animation**: 3D rotation on Y-axis
- **Shadow**: Heavy drop shadow (20px blur)

## Animation Principles

### Timing
- **Quick feedback**: 0.2-0.3s spring animations
- **Card flip**: 0.5s with damping 0.7
- **Sound effects**: 0.6s total (appear + fade)
- **Celebration**: 1.5s complex animations

### Spring Physics
- **Response**: 0.3-0.5s
- **Damping**: 0.6-0.8
- **Bounce**: Minimal (controlled energy)

### Haptic Feedback
- **Tap**: Medium impact
- **Correct**: Success notification
- **Wrong**: Error notification
- **Level up**: Heavy impact

## Component Library

### MangaStatCard
- Border: 4px colored stroke
- Background: Gradient with 20% opacity
- Corner radius: 16px
- Padding: 20px vertical

### MangaGradeButton
- Symbol: 40pt black weight with white fill + black shadow
- Border: 4px black stroke
- Corner radius: 12px
- Shadow: 8px blur with 40% opacity

### Progress Bars
- Background: White 10% opacity
- Fill: Gradient (red→orange or green for complete)
- Border: 3px black stroke
- Height: 20-24px
- Corner radius: 8px

## Layout Grid
- **Margin**: 20-24px horizontal
- **Spacing**: 12-20px between elements
- **Card aspect**: ~1.4:1 ratio
- **Touch targets**: Minimum 44x44pt
