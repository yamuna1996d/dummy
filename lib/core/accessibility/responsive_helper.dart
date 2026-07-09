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

  /// Returns true for tablet or larger screens.
  static bool isTabletOrLarger(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppDimensions.tabletBreakpoint;
  }



  /// Returns horizontal padding appropriate for the screen size.
  static double horizontalPadding(BuildContext context) {
    return switch (deviceType(context)) {
      DeviceType.mobile => AppDimensions.paddingMd,
      DeviceType.tablet => AppDimensions.paddingLg,
      DeviceType.desktop => AppDimensions.paddingXl,
    };
  }
}
