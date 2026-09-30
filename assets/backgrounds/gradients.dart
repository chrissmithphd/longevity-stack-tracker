import 'package:flutter/material.dart';

/// Background gradients for Forest Night visual system
/// These provide subtle depth without harsh contrast
class ForestNightGradients {
  // Primary app background - very subtle gradient
  static const LinearGradient primaryBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A2419), // Primary background
      Color(0xFF1D2720), // Slightly lighter
      Color(0xFF1A2419), // Back to primary
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Card/elevated surface background - gentle lift
  static const LinearGradient cardSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF252F24), // Slightly lighter than card base
      Color(0xFF242F23), // Card base
      Color(0xFF232E22), // Slightly darker
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Completed task gentle glow
  static const RadialGradient completedGlow = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      Color(0xFF2D4032), // Success background
      Color(0xFF242F23), // Fades to card
    ],
    stops: [0.0, 1.0],
  );

  // Active/in-progress subtle pulse
  static const LinearGradient activeState = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2E3A2D), // Tertiary background
      Color(0xFF242F23), // Card base
    ],
    stops: [0.0, 1.0],
  );

  // Header/section background - very subtle separation
  static const LinearGradient sectionHeader = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF1A2419), // Primary background
      Color(0xFF1E2820), // Slightly elevated
      Color(0xFF1A2419), // Back to primary
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Overlay for modal/dialog backgrounds
  static const LinearGradient overlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xDD1A2419), // Semi-transparent primary
      Color(0xEE1A2419), // More opaque at bottom
    ],
    stops: [0.0, 1.0],
  );
}
