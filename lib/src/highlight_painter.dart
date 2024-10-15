import 'package:flutter/material.dart';
import 'feature_highlight.dart';

class HighlightPainter extends CustomPainter {
  final HighlightShape shape;
  final Path? customPath;
  final Color color;
  final double strokeWidth;

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
        final center = Offset(size.width / 2, size.height / 2);
        final radius = (size.width < size.height ? size.width : size.height) / 2 - strokeWidth / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case HighlightShape.rectangle:
        final rect = Rect.fromLTWH(
          strokeWidth / 2,
          strokeWidth / 2,
          size.width - strokeWidth,
          size.height - strokeWidth,
        );
        canvas.drawRect(rect, paint);
        break;
      case HighlightShape.customPath:
        if (customPath != null) {
          canvas.drawPath(customPath!, paint);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(HighlightPainter oldDelegate) =>
      oldDelegate.shape != shape ||
          oldDelegate.customPath != customPath ||
          oldDelegate.color != color ||
          oldDelegate.strokeWidth != strokeWidth;
}