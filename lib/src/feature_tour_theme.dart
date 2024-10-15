import 'package:flutter/material.dart';

class FeatureTourTheme {
  final Color overlayColor;
  final Color highlightColor;
  final Color cardColor;
  final Color textColor;
  final Color primaryColor;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final TextStyle buttonStyle;
  final double cornerRadius;
  final double highlightBorderWidth;

  const FeatureTourTheme({
    this.overlayColor = Colors.black54,
    this.highlightColor = Colors.purple,
    this.cardColor = Colors.white,
    this.textColor = Colors.black87,
    this.primaryColor = Colors.purple,
    this.titleStyle = const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    this.bodyStyle = const TextStyle(fontSize: 14),
    this.buttonStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    this.cornerRadius = 8.0,
    this.highlightBorderWidth = 2.0,
  });

  factory FeatureTourTheme.fromTheme(ThemeData theme) {
    return FeatureTourTheme(
      overlayColor: theme.colorScheme.onSurface.withOpacity(0.5),
      highlightColor: theme.colorScheme.primary,
      cardColor: theme.cardColor,
      textColor: theme.textTheme.bodyLarge!.color!,
      primaryColor: theme.colorScheme.primary,
      titleStyle: theme.textTheme.titleLarge!,
      bodyStyle: theme.textTheme.bodyMedium!,
      buttonStyle: theme.textTheme.labelLarge!,
      cornerRadius: 8.0,
      highlightBorderWidth: 2.0,
    );
  }
}