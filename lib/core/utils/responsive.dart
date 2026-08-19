import 'package:flutter/material.dart';

/// Screen size breakpoints following modern design standards
class Breakpoints {
  Breakpoints._();

  static const double smallMobile = 360.0;
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;

  // Max content container widths
  static const double authFormMaxWidth = 460.0;
  static const double dashboardMaxWidth = 1200.0;
  static const double dialogMaxWidth = 520.0;
}

/// Device Screen Type classification
enum ScreenType {
  smallMobile,
  mobile,
  tablet,
  desktop,
}

/// Utility class for creating responsive layouts across all device sizes
class Responsive {
  Responsive._();

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.smallMobile) {
      return ScreenType.smallMobile;
    } else if (width < Breakpoints.mobile) {
      return ScreenType.mobile;
    } else if (width < Breakpoints.tablet) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.smallMobile;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.mobile && width < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double heightOf(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// Returns a responsive value based on current breakpoint
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? smallMobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.smallMobile && smallMobile != null) {
      return smallMobile;
    }
    if (width >= Breakpoints.tablet && desktop != null) {
      return desktop;
    }
    if (width >= Breakpoints.mobile && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Calculates responsive horizontal padding
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.smallMobile) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    } else if (width < Breakpoints.mobile) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
    } else if (width < Breakpoints.tablet) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    }
  }
}

/// A widget that builds different layouts based on screen constraints
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= Breakpoints.mobile && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Constrains child width and centers it for large screens (tablets, desktops)
class ResponsiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;

  const ResponsiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.dashboardMaxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
