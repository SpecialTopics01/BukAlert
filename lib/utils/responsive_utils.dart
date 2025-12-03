import 'package:flutter/material.dart';

/// Utility class for responsive design
class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Check if the device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Check if the device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Check if the device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Get responsive value based on screen size
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(32),
    );
  }

  /// Get responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const EdgeInsets.all(8),
      tablet: const EdgeInsets.all(12),
      desktop: const EdgeInsets.all(16),
    );
  }

  /// Get responsive font size
  static double responsiveFontSize(BuildContext context, double baseSize) {
    final scale = MediaQuery.of(context).textScaleFactor;
    final width = MediaQuery.of(context).size.width;

    // Scale font size based on screen width
    double scaleFactor = 1.0;
    if (width < mobileBreakpoint) {
      scaleFactor = 0.9;
    } else if (width < desktopBreakpoint) {
      scaleFactor = 1.0;
    } else {
      scaleFactor = 1.1;
    }

    return baseSize * scaleFactor * scale;
  }

  /// Get responsive button size
  static Size responsiveButtonSize(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: const Size(double.infinity, 48),
      tablet: const Size(200, 48),
      desktop: const Size(250, 48),
    );
  }

  /// Get responsive card width
  static double? responsiveCardWidth(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: double.infinity,
      tablet: MediaQuery.of(context).size.width * 0.8,
      desktop: 400,
    );
  }

  /// Get responsive grid cross axis count
  static int responsiveGridCount(BuildContext context) {
    return responsiveValue(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Get responsive spacing
  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    return responsiveValue(
      context: context,
      mobile: baseSpacing * 0.8,
      tablet: baseSpacing,
      desktop: baseSpacing * 1.2,
    );
  }

  /// Safe area aware padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final responsivePadding = this.responsivePadding(context);

    return EdgeInsets.only(
      top: padding.top + responsivePadding.top,
      bottom: padding.bottom + responsivePadding.bottom,
      left: padding.left + responsivePadding.left,
      right: padding.right + responsivePadding.right,
    );
  }
}

/// Extension methods for responsive design
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  EdgeInsets get responsivePadding => ResponsiveUtils.responsivePadding(this);
  EdgeInsets get responsiveMargin => ResponsiveUtils.responsiveMargin(this);
  Size get responsiveButtonSize => ResponsiveUtils.responsiveButtonSize(this);
  double? get responsiveCardWidth => ResponsiveUtils.responsiveCardWidth(this);
  int get responsiveGridCount => ResponsiveUtils.responsiveGridCount(this);

  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.responsiveFontSize(this, baseSize);

  double responsiveSpacing(double baseSpacing) =>
      ResponsiveUtils.responsiveSpacing(this, baseSpacing);
}

/// Responsive widget builder
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.responsiveValue(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile,
      desktop: desktop ?? tablet ?? mobile,
    );
  }
}

/// Responsive layout builder
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, constraints),
    );
  }
}

/// Responsive text
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveStyle = style?.copyWith(
      fontSize: context.responsiveFontSize(style?.fontSize ?? 14),
    );

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive container
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final Alignment? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? context.responsivePadding,
      margin: margin ?? context.responsiveMargin,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// Responsive button
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool fullWidth;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style?.copyWith(
        minimumSize: MaterialStateProperty.all(
          fullWidth ? Size(double.infinity, 48) : context.responsiveButtonSize,
        ),
      ) ?? ElevatedButton.styleFrom(
        minimumSize: MaterialStateProperty.all(
          fullWidth ? const Size(double.infinity, 48) : context.responsiveButtonSize,
        ),
      ),
      child: child,
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: context.responsiveGridCount,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Orientation aware widget
class OrientationAware extends StatelessWidget {
  final Widget portrait;
  final Widget? landscape;

  const OrientationAware({
    super.key,
    required this.portrait,
    this.landscape,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? portrait
        : landscape ?? portrait;
  }
}
