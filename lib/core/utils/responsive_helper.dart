import 'package:flutter/material.dart';

Size getScreenSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

bool isPortrait(BuildContext context) {
  return MediaQuery.of(context).orientation == Orientation.portrait;
}

bool isLandscape(BuildContext context) {
  return MediaQuery.of(context).orientation == Orientation.landscape;
}

bool isTablet(BuildContext context) {
  final size = getScreenSize(context);
  return size.width > 600;
}

bool isSmallScreen(BuildContext context) {
  final size = getScreenSize(context);
  return size.width < 360;
}

double getResponsiveWidth(BuildContext context, double portraitWidth, double landscapeWidth) {
  if (isLandscape(context)) {
    return landscapeWidth;
  }
  return portraitWidth;
}
