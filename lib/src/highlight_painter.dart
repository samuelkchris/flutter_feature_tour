import 'package:flutter/material.dart';
import 'feature_highlight.dart';

/// A custom painter that draws highlight shapes for feature tours.
///
/// This painter is responsible for drawing different shapes (circle, rectangle, or custom path)
/// around UI elements to highlight them during a feature tour.
class HighlightPainter extends CustomPainter {
  /// The shape of the highlight (circle, rectangle, or custom path).
  final HighlightShape shape;

  /// A custom path to be used when [shape] is [HighlightShape.customPath].
  final Path? customPath;

  /// The color of the highlight stroke.
  final Color color;

  /// The width of the highlight stroke.
  final double strokeWidth;

  /// Creates a [HighlightPainter] with the specified parameters.
  ///
  /// The [shape], [color], and [strokeWidth] are required.
  /// [customPath] is only used when [shape] is [HighlightShape.customPath].
  HighlightPainter({
    required this.shape,
    this.customPath,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    switch (shape) {
      case HighlightShape.circle:
        _drawCircle(canvas, size, paint);
        break;
      case HighlightShape.rectangle:
        _drawRectangle(canvas, size, paint);
        break;
      case HighlightShape.customPath:
        _drawCustomPath(canvas, paint);
        break;
    }
  }

  /// Draws a circular highlight.
  void _drawCircle(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 -
        strokeWidth / 2;
    canvas.drawCircle(center, radius, paint);
  }

  /// Draws a rectangular highlight.
  void _drawRectangle(Canvas canvas, Size size, Paint paint) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    canvas.drawRect(rect, paint);
  }

  /// Draws a custom path highlight.
  void _drawCustomPath(Canvas canvas, Paint paint) {
    if (customPath != null) {
      canvas.drawPath(customPath!, paint);
    }
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      oldDelegate.customPath != customPath ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
