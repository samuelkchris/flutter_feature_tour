import 'package:flutter/material.dart';

enum HighlightShape {
  circle,
  rectangle,
  customPath,
}

class FeatureHighlight {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final IconData icon;
  final HighlightShape shape;
  final Path? customPath;

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
