import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'feature_highlight.dart';
import 'feature_tour_theme.dart';

/// A widget that displays information about a highlighted feature during a feature tour.
///
/// This card shows the title, description, and navigation buttons for each step of the tour.
/// It also supports an optional interactive widget for more complex demonstrations.
class InfoCard extends StatelessWidget {
  /// The feature being highlighted in the current step.
  final FeatureHighlight highlight;

  /// Callback function to move to the next step in the tour.
  final VoidCallback onNext;

  /// Callback function to skip the rest of the tour.
  final VoidCallback onSkip;

  /// The total number of steps in the entire tour.
  final int totalSteps;

  /// The current step number in the tour.
  final int currentStep;

  /// The theme to use for styling the info card.
  final FeatureTourTheme theme;

  /// Focus node for the skip button to enable keyboard navigation.
  final FocusNode skipButtonFocus;

  /// Focus node for the next/finish button to enable keyboard navigation.
  final FocusNode nextButtonFocus;

  /// An optional widget to display within the card for interactive demos.
  final Widget? interactiveWidget;

  /// Whether to show the skip button. Defaults to true.
  final bool showSkipButton;

  /// Custom text for the next button. If not provided, defaults to 'Next' or 'Finish'.
  final String? nextButtonText;

  /// Creates an [InfoCard] widget.
  ///
  /// All parameters except [interactiveWidget], [showSkipButton], and [nextButtonText] are required.
  const InfoCard({
    super.key,
    required this.highlight,
    required this.onNext,
    required this.onSkip,
    required this.totalSteps,
    required this.currentStep,
    required this.theme,
    required this.skipButtonFocus,
    required this.nextButtonFocus,
    this.interactiveWidget,
    this.showSkipButton = true,
    this.nextButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.cornerRadius)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildDescription(),
              if (interactiveWidget != null) ...[
                const SizedBox(height: 16),
                interactiveWidget!,
              ],
              const SizedBox(height: 20),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section of the card, including the icon and title.
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(highlight.icon, color: theme.primaryColor, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            highlight.title,
            style: theme.titleStyle.copyWith(color: theme.textColor),
          ),
        ),
      ],
    );
  }

  /// Builds the description section of the card.
  Widget _buildDescription() {
    return Text(
      highlight.description,
      style: theme.bodyStyle.copyWith(color: theme.textColor.withOpacity(0.8)),
    );
  }

  /// Builds the footer section of the card, including step counter and navigation buttons.
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (currentStep <= totalSteps)
          Text(
            '$currentStep of $totalSteps',
            style: theme.bodyStyle
                .copyWith(color: theme.textColor.withOpacity(0.6)),
          )
        else
          const SizedBox.shrink(),
        Row(
          children: [
            if (showSkipButton) ...[
              _buildSkipButton(),
              const SizedBox(width: 8),
            ],
            _buildNextButton(),
          ],
        ),
      ],
    );
  }

  /// Builds the skip button with proper semantics and focus handling.
  Widget _buildSkipButton() {
    return Semantics(
      label: 'Skip tour',
      button: true,
      child: Focus(
        focusNode: skipButtonFocus,
        child: TextButton(
          onPressed: onSkip,
          child: Text('Skip',
              style: theme.buttonStyle.copyWith(color: theme.primaryColor)),
        ),
      ),
    );
  }

  /// Builds the next/finish button with proper semantics and focus handling.
  Widget _buildNextButton() {
    final isLastStep = currentStep == totalSteps;
    final buttonText = nextButtonText ?? (isLastStep ? 'Finish' : 'Next');
    return Semantics(
      label: isLastStep ? 'Finish tour' : 'Next step',
      button: true,
      child: Focus(
        focusNode: nextButtonFocus,
        child: ElevatedButton.icon(
          onPressed: onNext,
          icon: const Icon(Iconsax.arrow_right_3, size: 18),
          label: Text(buttonText),
          style: ElevatedButton.styleFrom(
            foregroundColor: theme.cardColor,
            backgroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(theme.cornerRadius)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ).copyWith(
            textStyle: WidgetStateProperty.all(theme.buttonStyle),
          ),
        ),
      ),
    );
  }
}
