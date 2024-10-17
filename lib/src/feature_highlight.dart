import 'package:flutter/material.dart';

/// Defines the shape of the highlight overlay for a feature.
///
/// This enum is used to specify how a feature should be visually highlighted
/// during the feature tour.
enum HighlightShape {
  /// A circular highlight around the feature.
  circle,

  /// A rectangular highlight around the feature.
  rectangle,

  /// A custom-shaped highlight defined by a [Path].
  customPath,
}

/// Represents a single feature to be highlighted during the feature tour.
///
/// This class encapsulates all the information needed to showcase and describe
/// a specific feature in the application.
class FeatureHighlight {
  /// The [GlobalKey] of the widget to be highlighted.
  ///
  /// This key is used to locate the widget's position on the screen.
  final GlobalKey targetKey;

  /// The title of the feature being highlighted.
  ///
  /// This is typically displayed prominently in the info card.
  final String title;

  /// A detailed description of the feature.
  ///
  /// This provides more information about the feature and how to use it.
  final String description;

  /// An icon representing the feature.
  ///
  /// This is typically displayed alongside the title in the info card.
  final IconData icon;

  /// The shape of the highlight overlay.
  ///
  /// Defaults to [HighlightShape.circle] if not specified.
  final HighlightShape shape;

  /// A custom path for the highlight shape.
  ///
  /// This is required when [shape] is set to [HighlightShape.customPath],
  /// and ignored for other shapes.
  final Path? customPath;

  /// Creates a [FeatureHighlight] instance.
  ///
  /// The [targetKey], [title], [description], and [icon] parameters are required.
  /// The [shape] parameter defaults to [HighlightShape.circle] if not specified.
  /// The [customPath] parameter is required when [shape] is [HighlightShape.customPath].
  ///
  /// Throws an [AssertionError] if [shape] is [HighlightShape.customPath] and
  /// [customPath] is null.
  FeatureHighlight({
    required this.targetKey,
    required this.title,
    required this.description,
    required this.icon,
    this.shape = HighlightShape.circle,
    this.customPath,
  }) : assert(shape != HighlightShape.customPath || customPath != null,
  'customPath must be provided when shape is HighlightShape.customPath');
}