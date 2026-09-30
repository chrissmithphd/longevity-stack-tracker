# Background Assets - Forest Night System

## Gradient Definitions

All gradients are defined in `gradients.dart` and follow these principles:
- **Very subtle** transitions (avoid harsh contrast)
- **Multi-stop gradients** for organic feel
- **Radial and linear** patterns for different use cases
- **Opacity variants** for layering

## Available Gradients

### 1. Primary Background
**Usage**: Main app background, scaffold
**Type**: Linear gradient (diagonal)
**Effect**: Barely visible depth, prevents flatness

### 2. Card Surface
**Usage**: Elevated cards, containers
**Type**: Linear gradient (diagonal)
**Effect**: Gentle dimensional lift

### 3. Completed Glow
**Usage**: Background for completed tasks
**Type**: Radial gradient
**Effect**: Soft, resolved feeling without being bright

### 4. Active State
**Usage**: Tasks in progress, selected items
**Type**: Linear gradient (vertical)
**Effect**: Gentle energy, present moment

### 5. Section Header
**Usage**: Date headers, section dividers
**Type**: Linear gradient (horizontal)
**Effect**: Subtle separation from content

### 6. Overlay
**Usage**: Modals, dialogs, bottom sheets
**Type**: Linear gradient (vertical)
**Effect**: Semi-transparent depth

## Texture Overlay

`noise_texture.svg` provides:
- Subtle organic grain
- Very low opacity (2-4%)
- Tileable pattern
- Adds tactile quality without distraction

### Usage in Flutter

```dart
// Background with gradient
Container(
  decoration: BoxDecoration(
    gradient: ForestNightGradients.primaryBackground,
  ),
  child: child,
)

// Card with gradient + subtle shadow
Container(
  decoration: BoxDecoration(
    gradient: ForestNightGradients.cardSurface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)

// Add noise texture overlay (optional)
Stack(
  children: [
    // Your content
    Container(...),
    // Subtle noise overlay
    Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: SvgPicture.asset(
          'assets/backgrounds/noise_texture.svg',
          fit: BoxFit.cover,
        ),
      ),
    ),
  ],
)
```

## Design Philosophy

Backgrounds should:
- **Enhance** content, not compete with it
- Provide **subtle depth** without drawing attention
- Feel **organic and natural**, not digital
- Support **long reading sessions** without eye strain
- Create **peaceful atmosphere** for focus

## Notes

- Gradients are intentionally subtle (5-10% variation)
- All colors stay within Forest Night palette
- No bright gradients or neon effects
- Textures are extremely low opacity
- Everything is designed for dark mode comfort
