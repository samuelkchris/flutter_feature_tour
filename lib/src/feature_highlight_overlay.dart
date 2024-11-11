import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'feature_highlight.dart';
import 'feature_tour_theme.dart';
import 'highlight_painter.dart';
import 'info_card.dart';

/// A widget that displays an overlay highlighting specific features in the app.
///
/// This overlay is part of a feature tour system, allowing developers to guide users
/// through their app's features. It creates a darkened overlay with highlighted areas
/// around specific widgets and displays informational cards.
///
/// The [FeatureHighlightOverlay] supports animations, keyboard navigation, and
/// customizable styling through [FeatureTourTheme].
class FeatureHighlightOverlay extends StatefulWidget {
  /// The list of features to highlight in this step of the tour.
  final List<FeatureHighlight> highlights;

  /// Callback function to move to the next step in the tour.
  final VoidCallback onNext;

  /// Callback function to skip the rest of the tour.
  final VoidCallback onSkip;

  /// Callback function to finish the tour.
  final VoidCallback onFinish;

  /// The total number of steps in the entire tour.
  final int totalSteps;

  /// The current step number in the tour.
  final int currentStep;

  /// The theme to use for styling the overlay and info card.
  final FeatureTourTheme theme;

  /// An optional widget to display within the info card for interactive demos.
  final Widget? interactiveWidget;

  /// Creates a [FeatureHighlightOverlay].
  ///
  /// All parameters except [interactiveWidget] are required.
  const FeatureHighlightOverlay({
    super.key,
    required this.highlights,
    required this.onNext,
    required this.onSkip,
    required this.onFinish,
    required this.totalSteps,
    required this.currentStep,
    required this.theme,
    this.interactiveWidget,
  });

  @override
  State<FeatureHighlightOverlay> createState() =>
      _FeatureHighlightOverlayState();
}

class _FeatureHighlightOverlayState extends State<FeatureHighlightOverlay>
    with SingleTickerProviderStateMixin {
  late FocusNode _overlayFocusNode;
  late FocusNode _skipButtonFocus;
  late FocusNode _nextButtonFocus;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _showAllSetCard = false;

  @override
  void initState() {
    super.initState();
    _initializeFocusNodes();
    _setupAnimations();
  }

  /// Initializes focus nodes for keyboard navigation.
  void _initializeFocusNodes() {
    _overlayFocusNode = FocusNode();
    _skipButtonFocus = FocusNode();
    _nextButtonFocus = FocusNode();
  }

  /// Sets up the animations for the overlay appearance.
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
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

  /// Handles key press events for keyboard navigation.
  ///
  /// Manages focus changes and triggers appropriate actions based on key presses.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          _skipButtonFocus.requestFocus();
        } else {
          _nextButtonFocus.requestFocus();
        }
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_skipButtonFocus.hasFocus) {
          _showAllSetCard ? widget.onFinish() : widget.onSkip();
        } else if (_nextButtonFocus.hasFocus) {
          _handleNext();
        }
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _handleNext() {
    if (_showAllSetCard) {
      widget.onFinish();
    } else if (widget.currentStep == widget.totalSteps) {
      setState(() {
        _showAllSetCard = true;
      });
    } else {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.theme.overlayColor,
      child: Focus(
        focusNode: _overlayFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _handleNext,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                if (!_showAllSetCard)
                  ...widget.highlights
                      .map((highlight) => _buildHighlight(context, highlight)),
                _showAllSetCard
                    ? _buildAllSetCard(context)
                    : _buildInfoCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds and positions the info card for the current highlight.
  Widget _buildInfoCard(BuildContext context) {
    final highlight = widget.highlights.first;
    final targetBox =
        highlight.targetKey.currentContext?.findRenderObject() as RenderBox?;
    final targetPosition = targetBox?.localToGlobal(Offset.zero);
    final targetSize = targetBox?.size;

    if (targetPosition == null || targetSize == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final isOnLeftSide = targetPosition.dx < screenSize.width / 2;

    // Calculate available space below the target
    final spaceBelow =
        screenSize.height - (targetPosition.dy + targetSize.height);

    // Determine if there's enough space below (e.g., 100 pixels as a threshold)
    final enoughSpaceBelow = spaceBelow > 100;

    // Calculate the vertical position and alignment
    double? top;
    double? bottom;
    if (enoughSpaceBelow) {
      top = targetPosition.dy + targetSize.height + 24;
    } else {
      bottom = screenSize.height - targetPosition.dy + 24;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: isOnLeftSide ? targetPosition.dx : null,
      right: isOnLeftSide
          ? null
          : screenSize.width - targetPosition.dx - targetSize.width,
      child: Semantics(
        label: 'Feature tour overlay',
        hint: 'Tap to move to the next step, or use tab key to navigate',
        child: InfoCard(
          highlight: highlight,
          onNext: _handleNext,
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

  /// Builds the "All Set" card shown at the end of the tour.
  Widget _buildAllSetCard(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Feature tour completed',
        hint: 'Tap to finish the tour',
        child: InfoCard(
          highlight: FeatureHighlight(
            targetKey: GlobalKey(),
            title: "You're All Set!",
            description:
                "Congratulations! You've completed the feature tour. Enjoy using the app!",
            icon: Icons.check_circle,
          ),
          onNext: widget.onFinish,
          onSkip: widget.onFinish,
          totalSteps: widget.totalSteps,
          currentStep: widget.totalSteps,
          theme: widget.theme,
          skipButtonFocus: _skipButtonFocus,
          nextButtonFocus: _nextButtonFocus,
          showSkipButton: false,
          nextButtonText: 'Finish',
        ),
      ),
    );
  }

  /// Builds and positions the highlight for a specific feature.
  Widget _buildHighlight(BuildContext context, FeatureHighlight highlight) {
    final targetBox =
        highlight.targetKey.currentContext?.findRenderObject() as RenderBox?;
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
