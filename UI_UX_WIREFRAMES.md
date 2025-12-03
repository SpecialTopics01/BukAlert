# BukAlert UI/UX Wireframes & Design System

## Overview

This document contains comprehensive wireframes and design specifications for the BukAlert emergency response mobile application. Since direct Figma access is not available, this document provides detailed wireframe descriptions, component specifications, and implementation guidelines.

## Design Philosophy

### Core Principles
- **Emergency-First**: Red color scheme for immediate recognition
- **Intuitive Navigation**: Bottom tabs with clear icons
- **Accessibility**: High contrast, large touch targets, clear typography
- **Responsive**: Adaptive layouts for all screen sizes
- **Real-time Focus**: Live updates and status indicators

### Color Palette

```dart
// Primary Colors
const Color emergencyRed = Color(0xFFD32F2F);
const Color emergencyRedDark = Color(0xFFB71C1C);
const Color emergencyRedLight = Color(0xFFEF5350);

// Status Colors
const Color statusActive = Color(0xFF4CAF50);
const Color statusWarning = Color(0xFFFF9800);
const Color statusError = Color(0xFFF44336);
const Color statusInfo = Color(0xFF2196F3);

// Neutral Colors
const Color background = Color(0xFFFAFAFA);
const Color surface = Color(0xFFFFFFFF);
const Color textPrimary = Color(0xFF212121);
const Color textSecondary = Color(0xFF757575);
const Color divider = Color(0xFFBDBDBD);
```

### Typography Scale

```dart
// Headlines
const TextStyle headline1 = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
const TextStyle headline2 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
const TextStyle headline3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);

// Body Text
const TextStyle body1 = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
const TextStyle body2 = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
const TextStyle caption = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

// Button Text
const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
```

### Spacing Scale

```dart
const double spacing4 = 4.0;
const double spacing8 = 8.0;
const double spacing12 = 12.0;
const double spacing16 = 16.0;
const double spacing20 = 20.0;
const double spacing24 = 24.0;
const double spacing32 = 32.0;
const double spacing48 = 48.0;
const double spacing64 = 64.0;
```

## Wireframe Screens

### 1. Splash Screen

```
┌─────────────────────────────────────┐
│                                     │
│         🚑                         │
│                                     │
│       BukAlert                     │
│  Emergency Response System         │
│                                     │
│     Bukidnon, Philippines          │
│                                     │
│       [Loading Indicator]          │
│                                     │
└─────────────────────────────────────┘
```

**Features:**
- Full-screen emergency red background
- Centered logo and app name
- Loading animation
- Auto-transition to login/dashboard

### 2. Authentication Flow

#### Login Screen

```
┌─────────────────────────────────────┐
│ ← Back                              │
│                                     │
│         🚑 BukAlert                │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📧 Email                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔒 Password                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [Forgot Password?]                  │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │   Login     │ │Create Account│    │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ─────────────────────────────────── │
│          Emergency Hotline          │
│    Call 911 for immediate help      │
└─────────────────────────────────────┘
```

#### Register Screen

```
┌─────────────────────────────────────┐
│ ← Back                              │
│                                     │
│         🚑 Create Account          │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 Full Name                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📧 Email                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📱 Phone                       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔒 Password                    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔒 Confirm Password            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌───────────────────────────────┐   │
│ │        Create Account         │   │
│ └───────────────────────────────┘   │
└─────────────────────────────────────┘
```

### 3. Citizen Dashboard

#### Home Tab

```
┌─────────────────────────────────────┐
│ BukAlert                    🔔 ⚠️ │
│ ─────────────────────────────────── │
│ ┌─────────────────────────────────┐ │
│ │ 🚨 Emergency Red Background     │ │
│ │                                 │ │
│ │ Welcome to BukAlert            │ │
│ │ Your safety is our priority    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │Report Emergency│Call Rescue Unit│ │
│ │      🔥      │      📞      │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ View Map    │ Call History  │ │
│ │      🗺️     │      📋      │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Recent Activity                 │ │
│ │                                 │ │
│ │ No recent activity              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ [⚠️] Emergency Button (FAB)        │
└─────────────────────────────────────┘
```

#### Map Tab

```
┌─────────────────────────────────────┐
│ Emergency Map                📍 🔍 │
│ ─────────────────────────────────── │
│ ┌─────────────────────────────────┐ │
│ │         [Google Maps]           │ │
│ │                                 │ │
│ │  📍 User's Location             │ │
│ │  🚑 Fire Station (2.3km)        │ │
│ │  🚔 Police Station (3.1km)      │ │
│ │  🏥 Hospital (4.2km)            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ My Location │ Nearby Units  │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ [📞] Quick Call Button (FAB)       │
└─────────────────────────────────────┘
```

#### Reports Tab

```
┌─────────────────────────────────────┐
│ Emergency Reports                  │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │ All │ │Active│ │Resolv│ │Add│     │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔥 Fire Emergency               │ │
│ │ Status: Active                  │ │
│ │ 2 hours ago                     │ │
│ │ Assigned: Fire Station #1       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🚑 Medical Emergency            │ │
│ │ Status: Resolved                │ │
│ │ 1 day ago                       │ │
│ │ Response: 12 min                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ➕ Report New Emergency          │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### Profile Tab

```
┌─────────────────────────────────────┐
│ Profile                            │
│                                     │
│     👤                              │
│                                     │
│   John Doe                          │
│   john@example.com                  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ✏️ Edit Profile                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📞 Call History                 │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ⭐ Bookmarked Units             │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ⚙️ Settings                     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🚪 Logout                       │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4. Emergency Reporting Flow

#### Report Type Selection

```
┌─────────────────────────────────────┐
│ Report Emergency           ❌       │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ 🔥 Fire     │ │ 🚑 Medical  │ │
│ │ Emergency   │ │ Emergency   │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ 🚔 Crime    │ │ 🚗 Accident │ │
│ │ /Violence   │ │            │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ 🌪️ Natural  │ │ ❓ Other    │ │
│ │ Disaster    │ │ Emergency   │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ Selected: 🔥 Fire Emergency        │
└─────────────────────────────────────┘
```

#### Report Details

```
┌─────────────────────────────────────┐
│ Report Details             ❌       │
│                                     │
│ Emergency Type: 🔥 Fire Emergency  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Describe the emergency...       │ │
│ │                                 │ │
│ │ [Multiline text input]          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Priority Level:                    │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │Low  │ │Med  │ │High │ │Crit │     │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
│                                     │
│ Current Location:                   │
│ ┌─────────────────────────────────┐ │
│ │ 📍 123 Emergency St, Bukidnon   │ │
│ │ 🔄 [Refresh Location]           │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Additional Notes (Optional)     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🚨 Submit Emergency Report       │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 5. Video Calling Interface

#### Call Screen

```
┌─────────────────────────────────────┐
│                                     │
│        [Video Feed Area]            │
│                                     │
│   📞 Connecting to Fire Station...  │
│                                     │
└─────────────────────────────────────┘
│                                     │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │ 🔇  │ │ 📹  │ │ 🔄   │ │ ❌   │ │
│ │ Mute│ │ Cam │ │Flip │ │ End │ │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
│                                     │
│ 00:45                              │
└─────────────────────────────────────┘
```

#### Incoming Call Dialog

```
┌─────────────────────────────────────┐
│ 🚨 EMERGENCY VIDEO CALL            │
│                                     │
│     📞                             │
│                                     │
│   Fire Station #1                   │
│   is calling...                     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │   Decline   │ │   Accept    │ │
│ └─────────────┘ └─────────────┘     │
└─────────────────────────────────────┘
```

### 6. Admin Dashboard

#### Overview Tab

```
┌─────────────────────────────────────┐
│ BukAlert Admin              👤     │
│ ─────────────────────────────────── │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ 📊 Reports  │ │ 📞 Calls    │ │
│ │     156     │ │     42      │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────┐ ┌─────────────┐     │
│ │ 🚑 Active   │ │ ⏱️ Avg Resp │ │
│ │      8      │ │   12 min    │ │
│ └─────────────┘ └─────────────┘     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📈 Response Time Chart          │ │
│ │                                 │ │
│ │ [Line chart showing trends]      │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Recent Reports                  │ │
│ │ 🔥 Fire - Downtown              │ │
│ │ 🚑 Medical - Residential        │ │
│ │ 🚔 Crime - Commercial           │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### Reports Management

```
┌─────────────────────────────────────┐
│ Reports                    🔍 📊    │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │ All │ │Active│ │Pend │ │Resolv│   │
│ └─────┘ └─────┘ └─────┘ └─────┘     │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔍 Search reports...            │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔥 Fire Emergency               │ │
│ │ John Doe - Downtown             │ │
│ │ Status: Active                  │ │
│ │ Assigned: Engine #5             │ │
│ │ [Assign] [Update] [Close]       │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 📊 Generate Report              │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Responsive Design Guidelines

### Breakpoints

```dart
class ScreenBreakpoints {
  static const double mobile = 320;
  static const double tablet = 768;
  static const double desktop = 1024;
}
```

### Layout Patterns

#### Mobile-First (320px - 767px)
- Single column layout
- Bottom navigation
- Stacked cards
- Full-width buttons
- Touch-friendly (48px minimum)

#### Tablet (768px - 1023px)
- Two-column layouts where appropriate
- Side navigation option
- Larger cards and spacing
- Grid layouts for dashboards

#### Desktop (1024px+)
- Multi-column layouts
- Sidebar navigation
- Advanced grid systems
- Hover states and tooltips

### Component Adaptations

#### Cards
```dart
// Mobile
width: double.infinity
padding: EdgeInsets.all(16)

// Tablet
width: MediaQuery.of(context).size.width * 0.8
padding: EdgeInsets.all(20)

// Desktop
width: 400
padding: EdgeInsets.all(24)
```

#### Buttons
```dart
// Mobile
minimumSize: Size(double.infinity, 48)

// Tablet
minimumSize: Size(200, 48)

// Desktop
minimumSize: Size(250, 48)
```

#### Typography
```dart
// Responsive text scaling
double scale = MediaQuery.of(context).textScaleFactor;
TextStyle responsiveStyle = baseStyle.copyWith(
  fontSize: baseStyle.fontSize! * scale,
);
```

## Component Library

### Buttons

#### Primary Emergency Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: emergencyRed,
    foregroundColor: Colors.white,
    minimumSize: Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Emergency Action'),
)
```

#### Secondary Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: emergencyRed),
    foregroundColor: emergencyRed,
    minimumSize: Size(double.infinity, 48),
  ),
  child: Text('Secondary Action'),
)
```

### Cards

#### Emergency Status Card
```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning, color: emergencyRed),
            SizedBox(width: 8),
            Text('Emergency Alert', style: headline3),
          ],
        ),
        SizedBox(height: 8),
        Text('Status details here...', style: body2),
      ],
    ),
  ),
)
```

### Form Elements

#### Emergency Type Selector
```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: emergencyTypes.map((type) => ChoiceChip(
    label: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(type.emoji),
        SizedBox(width: 4),
        Text(type.displayName),
      ],
    ),
    selected: selectedType == type,
    onSelected: (selected) {
      if (selected) setState(() => selectedType = type);
    },
    selectedColor: emergencyRed.withOpacity(0.2),
    checkmarkColor: emergencyRed,
  )).toList(),
)
```

### Navigation

#### Bottom Navigation
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.report),
      label: 'Reports',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
  currentIndex: selectedIndex,
  selectedItemColor: emergencyRed,
  unselectedItemColor: Colors.grey,
  onTap: onItemTapped,
)
```

## Animation Guidelines

### Transitions
- Screen transitions: `MaterialPageRoute` with slide animation
- Dialog transitions: Scale and fade animations
- Loading states: Smooth opacity transitions

### Micro-interactions
- Button press feedback
- Emergency button pulse animation
- Status indicator color changes
- Loading spinners

### Emergency Animations
```dart
// Emergency button pulse
AnimationController _pulseController = AnimationController(
  duration: Duration(milliseconds: 1000),
  vsync: this,
)..repeat(reverse: true);

Animation<double> _pulseAnimation = Tween<double>(
  begin: 1.0,
  end: 1.2,
).animate(CurvedAnimation(
  parent: _pulseController,
  curve: Curves.easeInOut,
));

AnimatedBuilder(
  animation: _pulseAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _pulseAnimation.value,
      child: FloatingActionButton(
        backgroundColor: emergencyRed,
        child: Icon(Icons.warning),
        onPressed: () {},
      ),
    );
  },
)
```

## Accessibility Guidelines

### Color Contrast
- Text on background: 4.5:1 minimum ratio
- Emergency elements: 7:1 minimum ratio
- Status indicators: Clear color differentiation

### Touch Targets
- Minimum 48x48px for interactive elements
- 8px spacing between touch targets
- Visual feedback for all interactions

### Screen Reader Support
- Semantic labels for all interactive elements
- Descriptive text for icons and images
- Logical tab order for form navigation

### Font Scaling
- Support for system font size changes
- Minimum readable font size: 14px
- Scalable text components

## Implementation Notes

### Flutter Implementation
- Use `MediaQuery` for responsive layouts
- Implement `OrientationBuilder` for orientation changes
- Use `LayoutBuilder` for constraint-based layouts
- Apply `FittedBox` for text overflow handling

### Performance Considerations
- Lazy loading for lists and grids
- Image optimization and caching
- Efficient rebuild patterns with `Consumer`
- Memory management for media content

### Testing Guidelines
- Test on multiple device sizes (320px to 4K)
- Verify touch targets on small screens
- Test accessibility with screen readers
- Validate color contrast ratios

This comprehensive wireframe and design system provides the foundation for implementing a professional, accessible, and responsive emergency response application.