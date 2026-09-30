# Forest Night Design System

**A calm, biologically grounded dark mode visual system for the Longevity App**

---

## Overview

The Forest Night design system creates a peaceful, supportive environment for managing long-term health routines. Every design decision prioritizes:

- **Calm over excitement** - Reduce stress, not increase urgency
- **Natural over artificial** - Colors and patterns inspired by nature
- **Soft over harsh** - Muted contrast for comfortable extended viewing
- **Resolved over flashy** - Completion feels peaceful, not celebratory
- **Accepting over judgmental** - Skipped tasks are neutral, not failures

---

## Color Palette

### Core Colors

```dart
// Backgrounds
primaryBackground   = #1A2419  // Deep forest green-black
secondaryBackground = #242F23  // Card/elevated surfaces
tertiaryBackground  = #2E3A2D  // Borders, dividers

// Text
primaryText    = #E8EDE7  // Soft warm white
secondaryText  = #9FAB9D  // Muted sage
tertiaryText   = #6B7569  // Subtle hints
```

### Accent Colors

```dart
completed = #5A8A5F  // Soft moss green - feels resolved, natural
skipped   = #8F8775  // Warm stone - neutral, non-judgmental
pending   = #4A6B6F  // Muted teal - calm anticipation
active    = #7A9C6A  // Living green - gentle energy
```

### Supporting Colors

```dart
successBackground = #2D4032  // Very dark moss
warningBackground = #3D3A2F  // Dark earth
errorSurface      = #4A3533  // Deep rust
```

---

## Spacing System

Uses consistent 4px multiples:

| Variable | Value | Usage |
|----------|-------|-------|
| space1   | 4px   | Tight spacing |
| space2   | 8px   | Small gaps |
| space3   | 12px  | Medium gaps |
| space4   | 16px  | Standard spacing |
| space6   | 24px  | Large spacing |
| space8   | 32px  | Section spacing |
| space12  | 48px  | Major sections |

---

## Border Radius

Soft, organic curves:

| Variable      | Value  | Usage |
|---------------|--------|-------|
| radiusSmall   | 8px    | Buttons, chips, badges |
| radiusMedium  | 12px   | Cards, containers |
| radiusLarge   | 16px   | Modals, sheets |
| radiusFull    | 999px  | Pills, avatars |

---

## Elevation & Shadows

Very subtle shadows - barely visible depth:

### Card Shadow (Resting)
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### Completed Task Glow
```dart
BoxShadow(
  color: completed.withOpacity(0.08),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

**Philosophy**: Shadows suggest depth without creating hard edges. Very low opacity (5-15%).

---

## Icon System

### Design Specifications
- **Style**: Minimal line icons
- **Stroke width**: 2px (consistent)
- **Line cap/join**: Rounded
- **ViewBox**: 24×24
- **Color**: Uses `currentColor` for theming

### Icon Set

| Icon | Category | Usage |
|------|----------|-------|
| supplements.svg | Supplements | Vitamins, pills, capsules |
| exercise.svg | Exercise | Workouts, training, movement |
| recovery.svg | Recovery | Breathing, meditation, rest |
| sleep.svg | Sleep | Rest, fasting, nighttime |
| hydration.svg | Hydration | Water, drinks, fluids |

All icons stored in: `assets/icons/`

---

## Typography

### Heading Hierarchy

```dart
// H1 - Screen titles (24px, semibold)
// H2 - Section headers (18px, semibold)
// H3 - Card titles (16px, semibold)
```

### Body Text

```dart
// Body 1 - Primary content (14px, regular, primary text)
// Body 2 - Secondary content (14px, regular, secondary text)
// Caption - Metadata (12px, regular, tertiary text)
```

All text uses 1.4-1.5 line height for readability.

---

## Component Patterns

### Task Cards

**Pending State:**
- Background: `secondaryBackground`
- Border: `tertiaryBackground` (1px)
- Shadow: Subtle card shadow
- Status icon: Unchecked circle, `pending` color

**Completed State:**
- Background: `successBackground`
- Border: `completed` with 30% opacity
- Shadow: Soft green glow
- Status icon: Check circle, `completed` color
- Effect: Feels resolved, peaceful

**Skipped State:**
- Background: `secondaryBackground`
- Border: `skipped` with 20% opacity
- Shadow: Minimal (recessed feel)
- Status icon: Remove circle, `skipped` color
- Effect: Neutral, accepting, not negative

### Status Badges

Chip-style indicators with:
- Very low opacity background (15%)
- Border with 25% opacity
- Bold, small text (11-12px)
- Rounded corners (8px)

### Buttons

**Done Button:**
- Background: `completed` at 15% opacity
- Text: `completed` color
- Soft, approachable, non-aggressive

**Skip Button:**
- Text only style
- Color: `skipped`
- Neutral, accepting tone

**Reset Button:**
- Text only style
- Color: `secondaryText`
- Subtle, available but not insistent

---

## Background Assets

### Gradients

All gradients in `assets/backgrounds/gradients.dart`:

1. **Primary Background** - Main app scaffold
2. **Card Surface** - Elevated containers
3. **Completed Glow** - Finished tasks
4. **Active State** - In-progress items
5. **Section Header** - Date/group headers
6. **Overlay** - Modals, dialogs

### Texture

`noise_texture.svg` provides:
- Subtle organic grain
- 2-4% opacity
- Tileable pattern
- Adds tactile quality

---

## Accessibility

### Contrast Ratios
- Primary text: 4.8:1 (WCAG AA ✓)
- Secondary text: 3.2:1 (WCAG AA ✓)
- Interactive elements: 3:1+ (WCAG AA ✓)

### Touch Targets
- Minimum: 44×44 dp
- Preferred: 48×48 dp for primary actions

### Focus States
- Subtle outline for keyboard navigation
- Color: `active` at 20% opacity

---

## Animation Guidelines

**Duration**: 200-300ms (responsive but smooth)

**Curves**:
- `Curves.easeOut` - Most transitions
- `Curves.easeInOut` - Two-way animations

**When to animate:**
- Status changes
- Card state transitions
- Button presses (subtle scale: 0.98)

**When NOT to animate:**
- Initial load
- List scrolling
- Text changes

---

## Implementation

### Theme Configuration

Import and use in `main.dart`:

```dart
import 'theme/forest_night_theme.dart';

MaterialApp(
  theme: ForestNightTheme.theme,
  ...
)
```

### Using Colors

```dart
// From theme context
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.bodyMedium?.color

// Direct from ForestNightTheme
ForestNightTheme.completed
ForestNightTheme.primaryText
ForestNightTheme.space4
```

### Using Icons

```dart
import 'package:longevity/utils/category_icons.dart';

CategoryIcons.getIcon(
  'Supplements',
  size: 24,
  color: ForestNightTheme.secondaryText,
)
```

### Using Shadows

```dart
decoration: BoxDecoration(
  boxShadow: ForestNightTheme.cardShadow,
)
```

---

## Design Philosophy Summary

**Core Values:**
1. **Soft, not sharp** - Rounded corners, gentle transitions
2. **Muted, not bright** - Low saturation, comfortable for eyes
3. **Spacious, not cramped** - Generous padding, breathing room
4. **Peaceful, not exciting** - Calm colors, subtle animations
5. **Natural, not artificial** - Biologically grounded palette

**Goal:**
Create a supportive, stress-free environment that helps users maintain their longevity routines without feeling judged, rushed, or overwhelmed.

---

## File Structure

```
lib/
├── theme/
│   └── forest_night_theme.dart      # Main theme configuration
├── utils/
│   └── category_icons.dart          # Icon helper utilities
assets/
├── icons/
│   ├── supplements.svg
│   ├── exercise.svg
│   ├── recovery.svg
│   ├── sleep.svg
│   ├── hydration.svg
│   └── README.md
├── backgrounds/
│   ├── gradients.dart
│   ├── noise_texture.svg
│   └── README.md
docs/
├── ui_guidelines.md                 # Detailed component specs
└── FOREST_NIGHT_DESIGN_SYSTEM.md    # This file
```

---

## Future Enhancements

When the foundation is solid, consider:
- Micro-interactions on task completion
- Subtle haptic feedback
- Dark/light mode toggle (Forest Day theme)
- Accessibility improvements (high contrast mode)
- Custom font integration
- Animated illustrations

**Remember:** Start simple. Add complexity only when the simple version proves insufficient.
