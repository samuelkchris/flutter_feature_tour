import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'feature_highlight.dart';
import 'feature_tour_theme.dart';

class InfoCard extends StatelessWidget {
  final FeatureHighlight highlight;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int totalSteps;
  final int currentStep;
  final FeatureTourTheme theme;
  final FocusNode skipButtonFocus;
  final FocusNode nextButtonFocus;
  final Widget? interactiveWidget;

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
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.cornerRadius)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
              ),
              const SizedBox(height: 12),
              Text(
                highlight.description,
                style: theme.bodyStyle.copyWith(color: theme.textColor.withOpacity(0.8)),
              ),
              if (interactiveWidget != null) ...[
                const SizedBox(height: 16),
                interactiveWidget!,
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currentStep of $totalSteps',
                    style: theme.bodyStyle.copyWith(color: theme.textColor.withOpacity(0.6)),
                  ),
                  Row(
                    children: [
                      Semantics(
                        label: 'Skip tour',
                        button: true,
                        child: Focus(
                          focusNode: skipButtonFocus,
                          child: TextButton(
                            onPressed: onSkip,
                            child: Text('Skip', style: theme.buttonStyle.copyWith(color: theme.primaryColor)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Semantics(
                        label: currentStep == totalSteps ? 'Finish tour' : 'Next step',
                        button: true,
                        child: Focus(
                          focusNode: nextButtonFocus,
                          child: ElevatedButton.icon(
                            onPressed: onNext,
                            icon: const Icon(Iconsax.arrow_right_3, size: 18),
                            label: Text(currentStep == totalSteps ? 'Finish' : 'Next'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: theme.cardColor,
                              backgroundColor: theme.primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(theme.cornerRadius)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ).copyWith(
                              textStyle: MaterialStateProperty.all(theme.buttonStyle),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}