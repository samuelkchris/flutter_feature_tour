import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'feature_highlight.dart';
import 'feature_tour_theme.dart';
import 'highlight_painter.dart';
import 'info_card.dart';

class FeatureHighlightOverlay extends StatefulWidget {
  final List<FeatureHighlight> highlights;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int totalSteps;
  final int currentStep;
  final FeatureTourTheme theme;
  final Widget? interactiveWidget;

  const FeatureHighlightOverlay({
    super.key,
    required this.highlights,
    required this.onNext,
    required this.onSkip,
    required this.totalSteps,
    required this.currentStep,
    required this.theme,
    this.interactiveWidget,
  });

  @override
  State<FeatureHighlightOverlay> createState() => _FeatureHighlightOverlayState();
}

class _FeatureHighlightOverlayState extends State<FeatureHighlightOverlay> with SingleTickerProviderStateMixin {
  late FocusNode _overlayFocusNode;
  late FocusNode _skipButtonFocus;
  late FocusNode _nextButtonFocus;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _overlayFocusNode = FocusNode();
    _skipButtonFocus = FocusNode();
    _nextButtonFocus = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _overlayFocusNode.dispose();
    _skipButtonFocus.dispose();
    _nextButtonFocus.dispose();
    _animationController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyPress(FocusNode node, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (event.isShiftPressed) {
          _skipButtonFocus.requestFocus();
        } else {
          _nextButtonFocus.requestFocus();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_skipButtonFocus.hasFocus) {
          widget.onSkip();
        } else if (_nextButtonFocus.hasFocus) {
          widget.onNext();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.theme.overlayColor,
      child: Focus(
        focusNode: _overlayFocusNode,
        autofocus: true,
        onKey: _handleKeyPress,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onNext,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                ...widget.highlights.map((highlight) => _buildHighlight(context, highlight)).toList(),
                _buildInfoCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final highlight = widget.highlights.first;
    final targetBox = highlight.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final targetPosition = targetBox?.localToGlobal(Offset.zero);
    final targetSize = targetBox?.size;

    if (targetPosition == null || targetSize == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isOnLeftSide = targetPosition.dx < screenSize.width / 2;

    return Positioned(
      top: targetPosition.dy + targetSize.height + 24,
      left: isOnLeftSide ? targetPosition.dx : null,
      right: isOnLeftSide ? null : screenSize.width - targetPosition.dx - targetSize.width,
      child: Semantics(
        label: 'Feature tour overlay',
        hint: 'Tap to move to the next step, or use tab key to navigate',
        child: InfoCard(
          highlight: highlight,
          onNext: widget.onNext,
          onSkip: widget.onSkip,
          totalSteps: widget.totalSteps,
          currentStep: widget.currentStep,
          theme: widget.theme,
          skipButtonFocus: _skipButtonFocus,
          nextButtonFocus: _nextButtonFocus,
          interactiveWidget: widget.interactiveWidget,
        ),
      ),
    );
  }

  Widget _buildHighlight(BuildContext context, FeatureHighlight highlight) {
    final targetBox = highlight.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final targetPosition = targetBox?.localToGlobal(Offset.zero);
    final targetSize = targetBox?.size;

    if (targetPosition == null || targetSize == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: targetPosition.dx,
      top: targetPosition.dy,
      child: SizedBox(
        width: targetSize.width,
        height: targetSize.height,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return CustomPaint(
              painter: HighlightPainter(
                shape: highlight.shape,
                customPath: highlight.customPath,
                color: widget.theme.highlightColor.withOpacity(value),
                strokeWidth: widget.theme.highlightBorderWidth * value,
              ),
            );
          },
        ),
      ),
    );
  }
}