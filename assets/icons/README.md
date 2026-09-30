# Longevity App Icon System

## Design Specifications

- **Style**: Minimal line icons
- **Stroke width**: 2px (1.5px for small details)
- **Line cap**: Rounded
- **Line join**: Rounded
- **ViewBox**: 24×24
- **Format**: SVG
- **Color**: Uses `currentColor` for easy theming

## Icon Set

### Core Category Icons

1. **supplements.svg** - Pill/capsule bottle representation
2. **exercise.svg** - Active human figure
3. **recovery.svg** - Breath/water flow (calming element)
4. **sleep.svg** - Moon with sparkle (rest/fasting)
5. **hydration.svg** - Water droplet with splash

## Usage in Flutter

Icons use `currentColor` so they adapt to the text color of their context.

```dart
// Example usage with flutter_svg
SvgPicture.asset(
  'assets/icons/supplements.svg',
  width: 24,
  height: 24,
  color: Theme.of(context).textTheme.bodyLarge?.color,
)
```

## Design Philosophy

Icons follow the Forest Night visual system:
- Organic, not geometric
- Soft edges, rounded corners
- Minimal detail
- Calming and approachable
- Consistent stroke weight creates visual rhythm
