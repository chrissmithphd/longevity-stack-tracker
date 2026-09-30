# UI Component Guidelines - Forest Night System

## Design Principles

1. **Soft over sharp** - Rounded corners, gentle transitions
2. **Subtle over bold** - Low contrast, muted colors
3. **Spacious over cramped** - Generous padding, breathing room
4. **Resolved over flashy** - Completion feels peaceful, not celebratory
5. **Neutral over negative** - Skipped items are accepting, not judgmental

---

## Spacing System

Use consistent spacing multiples of 4px:

```dart
// Base unit: 4px
static const double space1 = 4.0;   // xs
static const double space2 = 8.0;   // sm
static const double space3 = 12.0;  // md
static const double space4 = 16.0;  // base
static const double space6 = 24.0;  // lg
static const double space8 = 32.0;  // xl
static const double space12 = 48.0; // 2xl
```

**Usage:**
- Element padding: 16px (space4)
- Card padding: 16-24px (space4-space6)
- Section spacing: 24-32px (space6-space8)
- Screen padding: 16px (space4)

---

## Border Radius System

Soft, organic curves throughout:

```dart
static const double radiusSmall = 8.0;   // Buttons, chips, badges
static const double radiusMedium = 12.0; // Cards, containers
static const double radiusLarge = 16.0;  // Modals, sheets
static const double radiusFull = 999.0;  // Pills, avatars
```

---

## Elevation & Shadows

Very subtle shadows - barely visible, just enough for depth:

### Card Shadow (Resting)
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 2),
)
```

### Card Shadow (Hover/Active)
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 12,
  offset: Offset(0, 4),
)
```

### Header/Section Shadow
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 1),
)
```

**Philosophy**: Shadows should suggest depth, not create hard edges. Keep opacity very low (5-15%).

---

## Task Cards

### Default State (Pending)
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: ForestNightGradients.cardSurface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color(0xFF2E3A2D), // Tertiary background
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

### Completed State
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: ForestNightGradients.completedGlow,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color(0xFF5A8A5F).withOpacity(0.3), // Soft moss with opacity
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF5A8A5F).withOpacity(0.08),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

**Effect**: Gentle green glow, feels resolved and peaceful

### Skipped State
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFF242F23), // Card base, no gradient
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color(0xFF8F8775).withOpacity(0.2), // Warm stone with opacity
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 6,
        offset: Offset(0, 1),
      ),
    ],
  ),
)
```

**Effect**: Neutral, slightly recessed, non-judgmental

### Active/In-Progress State
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: ForestNightGradients.activeState,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Color(0xFF7A9C6A).withOpacity(0.4), // Living green
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0xFF7A9C6A).withOpacity(0.1),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

**Effect**: Gentle energy, present moment awareness

---

## Buttons

### Primary Button (Done)
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF5A8A5F).withOpacity(0.15), // Soft moss background
    foregroundColor: Color(0xFF5A8A5F), // Soft moss text
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
  ),
)
```

**Effect**: Soft, approachable, non-aggressive

### Secondary Button (Skip)
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Color(0xFF8F8775), // Warm stone
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

**Effect**: Neutral, accepting, no judgment

### Tertiary Button (Reset)
```dart
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Color(0xFF9FAB9D), // Secondary text
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

**Effect**: Subtle, available but not insistent

---

## Status Indicators

### Status Badge (Chip-style)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.15), // Very low opacity background
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: statusColor.withOpacity(0.25),
      width: 1,
    ),
  ),
  child: Text(
    status,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: statusColor,
    ),
  ),
)
```

**Colors by status:**
- Completed: `#5A8A5F` (soft moss)
- Skipped: `#8F8775` (warm stone)
- Pending: `#4A6B6F` (muted teal)
- Active: `#7A9C6A` (living green)

### Status Icon
```dart
Icon(
  statusIcon,
  size: 20,
  color: statusColor.withOpacity(0.8), // Slightly muted
)
```

**Icons by status:**
- Completed: `Icons.check_circle_outline`
- Skipped: `Icons.remove_circle_outline`
- Pending: `Icons.radio_button_unchecked`
- Active: `Icons.circle` (filled)

---

## Section Headers

```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    gradient: ForestNightGradients.sectionHeader,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
  ),
  child: Text(
    header,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFE8EDE7), // Primary text
      letterSpacing: 0.5,
    ),
  ),
)
```

---

## Typography

### Heading Hierarchy
```dart
// H1 - Screen titles
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: Color(0xFFE8EDE7),
  letterSpacing: 0.5,
)

// H2 - Section headers
TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Color(0xFFE8EDE7),
  letterSpacing: 0.3,
)

// H3 - Card titles
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Color(0xFFE8EDE7),
)
```

### Body Text
```dart
// Body 1 - Primary content
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFFE8EDE7),
  height: 1.5,
)

// Body 2 - Secondary content
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: Color(0xFF9FAB9D),
  height: 1.5,
)

// Caption - Metadata, timestamps
TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: Color(0xFF6B7569),
  height: 1.4,
)
```

---

## Animation Guidelines

**Duration**: 200-300ms (fast enough to feel responsive, slow enough to be smooth)

**Curves**:
- `Curves.easeOut` - For most transitions
- `Curves.easeInOut` - For two-way animations

**When to animate:**
- Status changes
- Card state transitions
- Page transitions
- Button presses (subtle scale: 0.98)

**When NOT to animate:**
- Initial load
- List scrolling
- Text changes

---

## Accessibility

### Contrast Requirements
All text meets WCAG AA:
- Primary text on primary background: 4.8:1
- Secondary text on primary background: 3.2:1
- All interactive elements: minimum 3:1

### Touch Targets
- Minimum: 44×44 dp (iOS/Android standards)
- Preferred: 48×48 dp for primary actions

### Focus States
Add subtle outline for keyboard navigation:
```dart
focusColor: Color(0xFF7A9C6A).withOpacity(0.2),
```

---

## Summary

**Core Values:**
- Soft, not sharp
- Muted, not bright
- Spacious, not cramped
- Peaceful, not exciting
- Natural, not artificial

Every component should feel like it belongs in a calm, supportive environment designed for long-term health and focus.
