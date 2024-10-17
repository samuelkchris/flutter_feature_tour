import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'feature_highlight.dart';
import 'feature_highlight_overlay.dart';
import 'feature_tour_theme.dart';

/// A service that manages the onboarding process and feature tour for an application.
///
/// This service handles the logic for displaying feature highlights, managing onboarding state,
/// and coordinating the flow of the feature tour, including the final "All Set" card.
class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();

  /// Factory constructor that returns the singleton instance of [OnboardingService].
  factory OnboardingService() => _instance;

  OnboardingService._internal();

  final List<List<FeatureHighlight>> _highlightSteps = [];
  int _currentIndex = 0;
  OverlayEntry? _currentOverlay;
  late Box<dynamic> _onboardingBox;
  bool _isInitialized = false;
  FeatureTourTheme _theme = FeatureTourTheme();

  /// Callback function for tracking analytics events.
  void Function(String event, Map<String, dynamic> properties)?
      onAnalyticsEvent;

  /// Builder function for creating interactive widgets within the feature tour.
  Widget Function(BuildContext context, VoidCallback onComplete)?
      interactiveWidgetBuilder;

  /// Initializes the onboarding service.
  ///
  /// This method should be called before using any other methods of the service.
  /// It sets up the Hive box for storing onboarding state.
  Future<void> initialize() async {
    if (!_isInitialized) {
      _onboardingBox = await Hive.openBox('onboarding');
      _isInitialized = true;
    }
  }

  /// Adds a step to the feature tour.
  ///
  /// Each step consists of a list of [FeatureHighlight]s to be displayed together.
  void addFeatureHighlightStep(List<FeatureHighlight> highlights) {
    _highlightSteps.add(highlights);
  }

  /// Sets the theme for the feature tour.
  void setTheme(FeatureTourTheme theme) {
    _theme = theme;
  }

  /// Sets the callback function for tracking analytics events.
  void setAnalyticsCallback(
      void Function(String event, Map<String, dynamic> properties) callback) {
    onAnalyticsEvent = callback;
  }

  /// Sets the builder function for creating interactive widgets within the feature tour.
  void setInteractiveWidgetBuilder(
      Widget Function(BuildContext context, VoidCallback onComplete) builder) {
    interactiveWidgetBuilder = builder;
  }

  /// Starts the onboarding process.
  ///
  /// This method will show the first unseen step of the feature tour, or do nothing
  /// if the onboarding has already been completed.
  Future<void> startOnboarding(BuildContext context) async {
    await initialize();

    bool onboardingCompleted = await isOnboardingCompleted();
    if (onboardingCompleted) {
      return;
    }

    _currentIndex = _onboardingBox.get('lastViewedStep', defaultValue: 0);

    if (_currentIndex >= _highlightSteps.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAllSetCard(context);
      });
      return;
    }

    _trackEvent('onboarding_started', {'total_steps': _highlightSteps.length});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNextHighlight(context);
    });
  }

  /// Restarts the onboarding process from the beginning.
  ///
  /// This method resets the onboarding progress and starts the feature tour from the first step.
  Future<void> restartOnboarding(BuildContext context) async {
    await initialize();

    _currentIndex = 0;
    await _onboardingBox.put('lastViewedStep', 0);
    await _onboardingBox.put('onboardingCompleted', false);

    _trackEvent(
        'onboarding_restarted', {'total_steps': _highlightSteps.length});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNextHighlight(context);
    });
  }

  /// Displays the next highlight in the feature tour.
  void _showNextHighlight(BuildContext context) {
    if (_currentIndex >= _highlightSteps.length) {
      _showAllSetCard(context);
      return;
    }

    _currentOverlay?.remove();
    final highlights = _highlightSteps[_currentIndex];

    _currentOverlay = OverlayEntry(
      builder: (context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FeatureHighlightOverlay(
          key: ValueKey(_currentIndex),
          highlights: highlights,
          onNext: () => _handleNext(context),
          onSkip: () => _showAllSetCard(context),
          onFinish: () => _endOnboarding(),
          totalSteps: _highlightSteps.length,
          currentStep: _currentIndex + 1,
          theme: _theme,
          interactiveWidget: interactiveWidgetBuilder != null
              ? interactiveWidgetBuilder!(context, () => _handleNext(context))
              : null,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
    _trackEvent('step_viewed',
        {'step_index': _currentIndex, 'total_steps': _highlightSteps.length});
  }

  /// Handles the action of moving to the next step in the feature tour.
  void _handleNext(BuildContext context) {
    _currentIndex++;
    _saveProgress();
    _trackEvent('step_completed', {
      'step_index': _currentIndex - 1,
      'total_steps': _highlightSteps.length
    });
    _showNextHighlight(context);
  }

  /// Shows the "All Set" card at the end of the feature tour.
  void _showAllSetCard(BuildContext context) {
    _currentOverlay?.remove();

    _currentOverlay = OverlayEntry(
      builder: (context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FeatureHighlightOverlay(
          key: const ValueKey('all_set'),
          highlights: [
            FeatureHighlight(
              targetKey: GlobalKey(),
              title: "You're All Set!",
              description:
                  "Congratulations! You've completed the feature tour. Enjoy using the app!",
              icon: Icons.check_circle,
            )
          ],
          onNext: () => _endOnboarding(),
          onSkip: () => _endOnboarding(),
          onFinish: () => _endOnboarding(),
          totalSteps: _highlightSteps.length,
          currentStep: _highlightSteps.length + 1,
          theme: _theme,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
    _trackEvent('all_set_card_shown', {'total_steps': _highlightSteps.length});
  }

  /// Ends the onboarding process.
  Future<void> _endOnboarding() async {
    _currentOverlay?.remove();
    _currentOverlay = null;
    await _saveProgress(completed: true);
    _trackEvent(
        'onboarding_completed', {'total_steps': _highlightSteps.length});
  }

  /// Saves the current progress of the onboarding process.
  Future<void> _saveProgress({bool completed = false}) async {
    await _onboardingBox.put('lastViewedStep', _currentIndex);
    await _onboardingBox.put('onboardingCompleted', completed);
  }

  /// Checks if the onboarding process has been completed.
  ///
  /// Returns `true` if onboarding has been completed, `false` otherwise.
  Future<bool> isOnboardingCompleted() async {
    await initialize();
    return _onboardingBox.get('onboardingCompleted', defaultValue: false);
  }

  /// Tracks an analytics event.
  void _trackEvent(String event, Map<String, dynamic> properties) {
    onAnalyticsEvent?.call(event, properties);
  }
}
