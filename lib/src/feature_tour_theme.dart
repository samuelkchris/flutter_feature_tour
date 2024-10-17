import 'package:flutter/material.dart';

/// Defines the visual theme for the feature tour.
///
/// This class encapsulates all the styling properties used throughout the feature tour,
/// allowing for consistent and customizable appearance across all tour elements.
class FeatureTourTheme {
  /// The color of the overlay that dims the background during the tour.
  final Color overlayColor;

  /// The color used to highlight the featured elements.
  final Color highlightColor;

  /// The background color of the info card.
  final Color cardColor;

  /// The primary text color used in the info card.
  final Color textColor;

  /// The color used for interactive elements like buttons.
  final Color primaryColor;

  /// The text style used for titles in the info card.
  final TextStyle titleStyle;

  /// The text style used for body text in the info card.
  final TextStyle bodyStyle;

  /// The text style used for buttons in the info card.
  final TextStyle buttonStyle;

  /// The corner radius used for the info card and buttons.
  final double cornerRadius;

  /// The width of the border used in the highlight shape.
  final double highlightBorderWidth;

  /// Creates a [FeatureTourTheme] with default or custom values.
  ///
  /// All parameters are optional and will use default values if not specified.
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

  /// Creates a [FeatureTourTheme] based on the provided [ThemeData].
  ///
  /// This factory constructor allows for easy integration with the app's existing theme.
  /// It extracts relevant colors and text styles from the provided [theme] to create
  /// a cohesive look for the feature tour.
  ///
  /// [theme] - The [ThemeData] to base the feature tour theme on.
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