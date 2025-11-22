# BrainLand Design System

This directory contains the design system implementation for BrainLand, including colors, typography, and reusable UI components.

## Components

### Colors (`lib/core/constants/colors.dart`)
- Complete color palette with zone-specific gradients
- Math Forest (Green), Logic Mountain (Blue), Memory River (Purple), Shape Valley (Orange)
- UI colors for backgrounds, feedback, and text
- Helper methods for dynamic zone color selection

### Typography (`lib/core/theme/text_styles.dart`)
- Child-friendly text styles with good readability
- Headings (H1-H4), body text, buttons, and game numbers
- Special styles for scores, stats, and labels
- Helper methods for color variations

### Reusable Components (`lib/shared/widgets/`)

#### FancyButton
- Gradient background with shadow
- Press animation (scale down to 0.95)
- Support for icons and custom gradients
- Small and regular sizes

#### FancyCard
- Rounded corners with elevation
- Support for gradients and solid colors
- Optional tap interaction
- AnimatedFancyCard variant with scale animation

#### GradientBackground
- Beautiful gradient backgrounds for screens
- Zone-specific gradient support
- AnimatedGradientBackground variant
- SimpleBackground for solid colors

#### LoadingIndicator
- Gradient circular progress indicator
- Optional loading message
- FullScreenLoadingIndicator with overlay
- PulsingDot for simple animations

### Responsive Utilities (`lib/core/utils/responsive_utils.dart`)
- Breakpoints for mobile (< 600px), tablet (600-900px), desktop (> 900px)
- Responsive value helpers
- Responsive padding and spacing
- Grid column count calculation
- ResponsiveBuilder and OrientationLayoutBuilder widgets
- Context extensions for easy access

## Usage Examples

### Using Colors
```dart
import 'package:adventure_world/core/constants/colors.dart';

Container(
  decoration: BoxDecoration(
    gradient: AppColors.mathForestGradient,
  ),
)
```

### Using Typography
```dart
import 'package:adventure_world/core/theme/text_styles.dart';

Text(
  'Welcome to BrainLand!',
  style: AppTextStyles.heading1,
)
```

### Using FancyButton
```dart
import 'package:adventure_world/shared/widgets/fancy_button.dart';

FancyButton(
  text: 'Start Game',
  onPressed: () => startGame(),
  gradient: AppColors.mathForestGradient,
  icon: Icons.play_arrow,
)
```

### Using Responsive Utilities
```dart
import 'package:adventure_world/core/utils/responsive_utils.dart';

final padding = context.responsivePadding;
final columns = context.gridColumnCount;

if (context.isMobile) {
  // Mobile layout
} else {
  // Tablet/Desktop layout
}
```

## Design Principles

1. **Child-Friendly**: Bright colors, large touch targets, clear typography
2. **Professional**: Smooth animations, proper elevation, consistent spacing
3. **Accessible**: Minimum 48dp touch targets, high contrast, semantic labels
4. **Responsive**: Adapts to mobile, tablet, and landscape orientations
5. **Performant**: Efficient animations, proper widget disposal

## Requirements Validated

- ✅ Requirement 10.1: Pastel color schemes and child-friendly graphics
- ✅ Requirement 10.3: Large buttons for easy touch interaction
- ✅ Requirement 10.4: Simple, smooth transitions with bounce and scale effects
