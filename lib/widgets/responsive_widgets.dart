import 'package:flutter/material.dart';

class ScreenSizes {
  static const double mobile = 320;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double large = 1440;
}

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ScreenSizes.tablet;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= ScreenSizes.tablet &&
           MediaQuery.of(context).size.width < ScreenSizes.desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ScreenSizes.desktop;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseSize * 0.9;
    if (screenWidth > 1200) return baseSize * 1.1;
    return baseSize;
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < ScreenSizes.mobile) {
      return const EdgeInsets.all(12);
    } else if (screenWidth < ScreenSizes.tablet) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  static double responsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < ScreenSizes.tablet) {
      return double.infinity; // Full width on mobile
    } else if (screenWidth < ScreenSizes.desktop) {
      return 400; // Fixed width on tablet
    } else {
      return 500; // Larger fixed width on desktop
    }
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? color;
  final BoxShadow? shadow;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.color,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardPadding = padding ?? EdgeInsets.all(
      screenWidth < ScreenSizes.tablet ? 16 : 20
    );

    final cardWidth = width ?? ResponsiveUtils.responsiveCardWidth(context);
    final cardHeight = height;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.all(screenWidth < ScreenSizes.tablet ? 8 : 12),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadow != null ? [shadow!] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: child,
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileCrossAxisCount;
  final int tabletCrossAxisCount;
  final int desktopCrossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount = 2,
    this.tabletCrossAxisCount = 3,
    this.desktopCrossAxisCount = 4,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < ScreenSizes.tablet
            ? mobileCrossAxisCount
            : constraints.maxWidth < ScreenSizes.desktop
                ? tabletCrossAxisCount
                : desktopCrossAxisCount;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = width ?? (screenWidth < ScreenSizes.tablet ? double.infinity : 200);
    final buttonHeight = height ?? (screenWidth < ScreenSizes.tablet ? 50 : 56);

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFFD32F2F),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      backgroundColor: const Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      elevation: screenWidth < ScreenSizes.tablet ? 2 : 4,
      toolbarHeight: screenWidth < ScreenSizes.tablet ? 56 : 64,
    );
  }
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < ScreenSizes.tablet;

    return Scaffold(
      appBar: appBar,
      body: Container(
        color: Colors.grey[50],
        child: body != null ? SafeArea(
          child: Padding(
            padding: ResponsiveUtils.responsivePadding(context),
            child: body!,
          ),
        ) : null,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation ?? FloatingActionButtonLocation.endFloat,
      extendBody: extendBody,
    );
  }
}

class ResponsiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double? maxWidth;

  const ResponsiveDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogMaxWidth = maxWidth ?? (screenWidth < ScreenSizes.tablet ? screenWidth * 0.9 : 400);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              content,
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: action,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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
    final baseStyle = style ?? const TextStyle();
    final responsiveStyle = baseStyle.copyWith(
      fontSize: ResponsiveUtils.responsiveFontSize(context, baseStyle.fontSize ?? 16),
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

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BoxDecoration? decoration;
  final double? maxWidth;
  final double? maxHeight;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = padding ?? EdgeInsets.all(
      screenWidth < ScreenSizes.tablet ? 16 : 24
    );
    final containerMargin = margin ?? EdgeInsets.all(
      screenWidth < ScreenSizes.tablet ? 8 : 16
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (screenWidth < ScreenSizes.tablet ? double.infinity : 600),
        maxHeight: maxHeight ?? double.infinity,
      ),
      padding: containerPadding,
      margin: containerMargin,
      decoration: decoration ?? BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
