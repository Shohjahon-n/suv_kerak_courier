import 'package:flutter/material.dart';

/// Provides responsive spacing and sizing values based on screen size
class ResponsiveSpacing {
  ResponsiveSpacing._();

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return ScreenSize.small;
    if (width < 400) return ScreenSize.medium;
    if (width < 600) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }

  /// Get responsive padding for cards based on screen size
  static EdgeInsets cardPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(10);
      case ScreenSize.medium:
        return const EdgeInsets.all(12);
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(14);
    }
  }

  /// Get responsive padding for large cards
  static EdgeInsets largePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(12);
      case ScreenSize.medium:
        return const EdgeInsets.all(14);
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(16);
    }
  }

  /// Get responsive page padding
  static EdgeInsets pagePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(14);
      case ScreenSize.medium:
        return const EdgeInsets.all(16);
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, {double base = 24}) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return base * 0.85;
      case ScreenSize.medium:
        return base * 0.92;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return base;
    }
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context, {double base = 18}) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return base * 0.85;
      case ScreenSize.medium:
        return base * 0.92;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return base;
    }
  }

  /// Get responsive spacing between elements
  static double spacing(BuildContext context, {double base = 12}) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return base * 0.75;
      case ScreenSize.medium:
        return base * 0.85;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return base;
    }
  }

  /// Get responsive vertical spacing
  static double verticalSpacing(BuildContext context, {double base = 16}) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return base * 0.7;
      case ScreenSize.medium:
        return base * 0.85;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return base;
    }
  }
}

enum ScreenSize {
  small, // < 360
  medium, // 360-399
  large, // 400-599
  extraLarge, // >= 600
}
