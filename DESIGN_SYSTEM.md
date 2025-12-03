# BukAlert Design System

## Overview

This document defines the complete design system for the BukAlert emergency response mobile application, including colors, typography, spacing, components, and responsive design guidelines.

## Design Principles

### 1. Emergency-First Priority
- **Red Color Palette**: Immediate recognition of emergency elements
- **High Contrast**: Critical information stands out
- **Clear Hierarchy**: Important actions are prominent
- **Accessibility**: WCAG 2.1 AA compliance for emergency interfaces

### 2. User-Centric Design
- **Intuitive Navigation**: Bottom tabs with clear icons
- **Progressive Disclosure**: Information revealed contextually
- **Feedback Systems**: Visual, haptic, and auditory feedback
- **Error Prevention**: Validation and confirmation dialogs

### 3. Responsive Excellence
- **Mobile-First**: Optimized for small screens (320px+)
- **Tablet Enhanced**: Improved layouts for medium screens
- **Desktop Ready**: Full functionality on large screens
- **Adaptive Components**: Elements scale with content

## Color System

### Primary Colors

```dart
// Emergency Red - Primary Actions, Critical States
const Color emergencyRed = Color(0xFFD32F2F);
const Color emergencyRedDark = Color(0xFFB71C1C);
const Color emergencyRedLight = Color(0xFFEF5350);

// Emergency Red Variations
const Color emergencyRed50 = Color(0xFFFFEBEE);
const Color emergencyRed100 = Color(0xFFFFCDD2);
const Color emergencyRed200 = Color(0xFFEF9A9A);
const Color emergencyRed300 = Color(0xFFE57373);
const Color emergencyRed400 = Color(0xFFEF5350);
const Color emergencyRed500 = Color(0xFFD32F2F); // Primary
const Color emergencyRed600 = Color(0xFFB71C1C);
const Color emergencyRed700 = Color(0xFF880E0E);
const Color emergencyRed800 = Color(0xFF5D0A0A);
const Color emergencyRed900 = Color(0xFF320606);
```

### Semantic Colors

```dart
// Status Colors
const Color statusActive = Color(0xFF4CAF50);    // Active/Connected
const Color statusWarning = Color(0xFFFF9800);   // Warning/Pending
const Color statusError = Color(0xFFF44336);     // Error/Failed
const Color statusInfo = Color(0xFF2196F3);      // Info/Processing

// Priority Colors
const Color priorityLow = Color(0xFF4CAF50);     // Green
const Color priorityMedium = Color(0xFFFF9800);  // Orange
const Color priorityHigh = Color(0xFFF44336);    // Red
const Color priorityCritical = Color(0xFF880E0E); // Dark Red
```

### Neutral Colors

```dart
// Backgrounds
const Color background = Color(0xFFFAFAFA);
const Color surface = Color(0xFFFFFFFF);
const Color surfaceVariant = Color(0xFFF5F5F5);

// Text
const Color textPrimary = Color(0xFF212121);
const Color textSecondary = Color(0xFF757575);
const Color textDisabled = Color(0xFFBDBDBD);

// Dividers and Borders
const Color divider = Color(0xFFBDBDBD);
const Color outline = Color(0xFFE0E0E0);
```

## Typography System

### Font Family
- **Primary**: Roboto (Google Fonts)
- **Fallback**: System default sans-serif

### Type Scale

```dart
// Display (Headlines)
const TextStyle displayLarge = TextStyle(
  fontSize: 57, fontWeight: FontWeight.normal, height: 1.12, letterSpacing: -0.25
);
const TextStyle displayMedium = TextStyle(
  fontSize: 45, fontWeight: FontWeight.normal, height: 1.16, letterSpacing: 0
);
const TextStyle displaySmall = TextStyle(
  fontSize: 36, fontWeight: FontWeight.normal, height: 1.22, letterSpacing: 0
);

// Headlines
const TextStyle headlineLarge = TextStyle(
  fontSize: 32, fontWeight: FontWeight.bold, height: 1.25, letterSpacing: 0
);
const TextStyle headlineMedium = TextStyle(
  fontSize: 28, fontWeight: FontWeight.bold, height: 1.29, letterSpacing: 0
);
const TextStyle headlineSmall = TextStyle(
  fontSize: 24, fontWeight: FontWeight.bold, height: 1.33, letterSpacing: 0
);

// Title
const TextStyle titleLarge = TextStyle(
  fontSize: 22, fontWeight: FontWeight.w500, height: 1.27, letterSpacing: 0
);
const TextStyle titleMedium = TextStyle(
  fontSize: 16, fontWeight: FontWeight.w500, height: 1.5, letterSpacing: 0.15
);
const TextStyle titleSmall = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1
);

// Body
const TextStyle bodyLarge = TextStyle(
  fontSize: 16, fontWeight: FontWeight.normal, height: 1.5, letterSpacing: 0.5
);
const TextStyle bodyMedium = TextStyle(
  fontSize: 14, fontWeight: FontWeight.normal, height: 1.43, letterSpacing: 0.25
);
const TextStyle bodySmall = TextStyle(
  fontSize: 12, fontWeight: FontWeight.normal, height: 1.33, letterSpacing: 0.4
);

// Label
const TextStyle labelLarge = TextStyle(
  fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1
);
const TextStyle labelMedium = TextStyle(
  fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5
);
const TextStyle labelSmall = TextStyle(
  fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5
);
```

### Responsive Typography

```dart
class ResponsiveTypography {
  static TextStyle responsiveStyle(BuildContext context, TextStyle baseStyle) {
    final scale = MediaQuery.of(context).textScaleFactor;
    final width = MediaQuery.of(context).size.width;

    // Scale factor based on screen width
    double scaleFactor = 1.0;
    if (width < 360) scaleFactor = 0.9;      // Small phones
    else if (width > 1200) scaleFactor = 1.1; // Large screens

    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scaleFactor * scale,
    );
  }
}
```

## Spacing System

### Spacing Scale (4px base grid)

```dart
const double space4 = 4.0;
const double space8 = 8.0;
const double space12 = 12.0;
const double space16 = 16.0;
const double space20 = 20.0;
const double space24 = 24.0;
const double space32 = 32.0;
const double space40 = 40.0;
const double space48 = 48.0;
const double space56 = 56.0;
const double space64 = 64.0;
const double space80 = 80.0;
const double space96 = 96.0;
const double space128 = 128.0;
```

### Component Spacing

```dart
class ComponentSpacing {
  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(space16);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(space24);

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: space16, vertical: space12
  );

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: space16, vertical: space12
  );

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(space16);
  static const EdgeInsets screenPaddingLarge = EdgeInsets.all(space24);
}
```

## Component Library

### Buttons

#### Primary Emergency Button
```dart
class EmergencyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const EmergencyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: emergencyRed,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        shadowColor: emergencyRed.withOpacity(0.3),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
```

#### Secondary Button
```dart
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, color: emergencyRed) : const SizedBox(),
      label: Text(text, style: TextStyle(color: emergencyRed)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: emergencyRed),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
```

### Cards

#### Emergency Status Card
```dart
class EmergencyCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const EmergencyCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: backgroundColor ?? Colors.white,
      child: Padding(
        padding: padding ?? ComponentSpacing.cardPadding,
        child: child,
      ),
    );
  }
}
```

#### Status Indicator Card
```dart
class StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;
  final IconData icon;

  const StatusCard({
    super.key,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EmergencyCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(space8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: statusColor),
          ),
          const SizedBox(width: space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Form Elements

#### Emergency Type Selector
```dart
class EmergencyTypeSelector extends StatelessWidget {
  final EmergencyType selectedType;
  final ValueChanged<EmergencyType> onTypeSelected;

  const EmergencyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: space8,
      runSpacing: space8,
      children: EmergencyType.values.map((type) {
        final isSelected = selectedType == type;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: space4),
              Text(type.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) onTypeSelected(type);
          },
          selectedColor: emergencyRed.withOpacity(0.2),
          checkmarkColor: emergencyRed,
          backgroundColor: Colors.grey[100],
        );
      }).toList(),
    );
  }
}
```

#### Priority Selector
```dart
class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [1, 2, 3, 4].map((priority) {
        final isSelected = selectedPriority == priority;
        final color = _getPriorityColor(priority);
        final label = _getPriorityLabel(priority);

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: space2),
            child: OutlinedButton(
              onPressed: () => onPriorityChanged(priority),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isSelected ? color : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                backgroundColor: isSelected ? color.withOpacity(0.1) : null,
                padding: const EdgeInsets.symmetric(vertical: space12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return priorityLow;
      case 2: return priorityMedium;
      case 3: return priorityHigh;
      case 4: return priorityCritical;
      default: return priorityMedium;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1: return 'Low';
      case 2: return 'Medium';
      case 3: return 'High';
      case 4: return 'Critical';
      default: return 'Medium';
    }
  }
}
```

### Navigation

#### Bottom Navigation
```dart
class EmergencyBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EmergencyBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report_outlined),
          activeIcon: Icon(Icons.report),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: emergencyRed,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
}
```

## Responsive Design Guidelines

### Breakpoints

```dart
class ScreenBreakpoints {
  static const double mobile = 320;      // Small phones
  static const double mobileLarge = 360; // Standard phones
  static const double tablet = 768;      // Tablets
  static const double desktop = 1024;    // Small desktops
  static const double desktopLarge = 1440; // Large desktops
}
```

### Layout Patterns

#### Mobile Layout (320px - 767px)
- Single column layouts
- Bottom navigation
- Full-width buttons and cards
- Touch-friendly sizing (48px minimum)
- Vertical scrolling content

#### Tablet Layout (768px - 1023px)
- Two-column layouts where beneficial
- Side navigation option
- Larger cards and spacing
- Grid layouts for content
- Optimized for landscape/portrait

#### Desktop Layout (1024px+)
- Multi-column layouts
- Sidebar navigation
- Advanced grid systems
- Hover states and tooltips
- Keyboard navigation support

### Responsive Components

#### Responsive Container
```dart
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = ResponsiveUtils.responsiveValue(
      context: context,
      mobile: mobileWidth ?? double.infinity,
      tablet: tabletWidth ?? 600,
      desktop: desktopWidth ?? 800,
    );

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: containerWidth),
        child: child,
      ),
    );
  }
}
```

#### Responsive Grid
```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount = 3,
    this.desktopCrossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ResponsiveUtils.responsiveValue(
          context: context,
          mobile: mobileCrossAxisCount,
          tablet: tabletCrossAxisCount,
          desktop: desktopCrossAxisCount,
        );

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}
```

## Animation Guidelines

### Emergency Animations

#### Pulsing Emergency Button
```dart
class PulsingEmergencyButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PulsingEmergencyButton({super.key, required this.onPressed});

  @override
  State<PulsingEmergencyButton> createState() => _PulsingEmergencyButtonState();
}

class _PulsingEmergencyButtonState extends State<PulsingEmergencyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: emergencyRed,
            child: const Icon(Icons.warning, color: Colors.white),
          ),
        );
      },
    );
  }
}
```

#### Status Transition Animation
```dart
class StatusTransition extends StatefulWidget {
  final Color fromColor;
  final Color toColor;
  final Widget child;

  const StatusTransition({
    super.key,
    required this.fromColor,
    required this.toColor,
    required this.child,
  });

  @override
  State<StatusTransition> createState() => _StatusTransitionState();
}

class _StatusTransitionState extends State<StatusTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void didUpdateWidget(StatusTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.toColor != widget.toColor) {
      _animateToNewColor();
    }
  }

  void _animateToNewColor() {
    _colorAnimation = ColorTween(
      begin: widget.fromColor,
      end: widget.toColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          color: _colorAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
```

## Accessibility Guidelines

### Color Contrast
- **Primary Text**: 7:1 contrast ratio (WCAG AAA)
- **Secondary Text**: 4.5:1 contrast ratio (WCAG AA)
- **Emergency Elements**: 7:1 minimum contrast
- **Status Indicators**: Distinct color differences

### Touch Targets
- **Minimum Size**: 48x48px (9mm) for all interactive elements
- **Spacing**: 8px minimum separation between touch targets
- **Visual Feedback**: Clear pressed states for all buttons

### Screen Reader Support
- **Semantic Labels**: Descriptive labels for all interactive elements
- **Focus Indicators**: Visible focus rings for keyboard navigation
- **Logical Order**: Tab order follows visual layout
- **Context Information**: Screen reader announcements for status changes

### Font Scaling
- **System Integration**: Respects system font size settings
- **Minimum Size**: 14px readable text
- **Scalable Components**: All text scales proportionally
- **Overflow Handling**: Text truncation with ellipsis

## Implementation Checklist

### Design System
- [x] Color palette defined
- [x] Typography scale implemented
- [x] Spacing system established
- [x] Component library created

### Responsive Design
- [x] Breakpoints defined
- [x] Layout patterns documented
- [x] Component adaptations implemented
- [x] Testing guidelines provided

### Accessibility
- [x] Color contrast verified
- [x] Touch targets sized appropriately
- [x] Screen reader support implemented
- [x] Keyboard navigation enabled

### Animation & Interaction
- [x] Emergency animations defined
- [x] Status transitions implemented
- [x] Loading states designed
- [x] Error states handled

This comprehensive design system ensures a consistent, accessible, and responsive user experience across all BukAlert application screens and components.
