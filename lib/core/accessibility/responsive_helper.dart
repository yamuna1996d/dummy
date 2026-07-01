import 'package:flutter/material.dart';
import 'package:kincare/app/constants/app_dimensions.dart';

/// Device form factor enumeration for responsive layouts.
enum DeviceType { mobile, tablet, desktop }

/// Utility for responsive layout decisions.
abstract final class ResponsiveHelper {
  /// Determines the device type based on screen width.
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppDimensions.desktopBreakpoint) return DeviceType.desktop;
    if (width >= AppDimensions.tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Returns true if the device is in landscape orientation.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Returns true for tablet or larger screens.
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppDimensions.tabletBreakpoint;
  }

  /// Returns the number of grid columns appropriate for the screen size.
  static int gridColumns(BuildContext context) {
    return switch (deviceType(context)) {
      DeviceType.mobile => isLandscape(context) ? 2 : 1,
      DeviceType.tablet => isLandscape(context) ? 3 : 2,
      DeviceType.desktop => 3,
    };
  }

  /// Returns horizontal padding appropriate for the screen size.
  static double horizontalPadding(BuildContext context) {
    return switch (deviceType(context)) {
      DeviceType.mobile => AppDimensions.paddingMd,
      DeviceType.tablet => AppDimensions.paddingLg,
      DeviceType.desktop => AppDimensions.paddingXl,
    };
  }

  /// Returns the text scale factor clamped to accessibility-safe bounds.
  static double clampedTextScale(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    return scale.clamp(0.8, 2.0);
  }
}
