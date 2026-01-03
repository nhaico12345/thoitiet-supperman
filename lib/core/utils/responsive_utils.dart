// Tự động chọn layout phù hợp cho mobile/tablet/desktop dựa trên kích thước màn hình.

import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobileBuilder;
  final Widget Function(BuildContext context) tabletBuilder;
  final Widget Function(BuildContext context)? desktopBuilder;

  const ResponsiveBuilder({
    super.key,
    required this.mobileBuilder,
    required this.tabletBuilder,
    this.desktopBuilder,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100 && desktopBuilder != null) {
          return desktopBuilder!(context);
        } else if (constraints.maxWidth >= 600) {
          return tabletBuilder(context);
        } else {
          return mobileBuilder(context);
        }
      },
    );
  }
}
