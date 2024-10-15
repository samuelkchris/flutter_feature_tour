import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'feature_highlight.dart';
import 'feature_highlight_overlay.dart';
import 'feature_tour_theme.dart';

class OnboardingService {
  static final OnboardingService _instance = OnboardingService._internal();
  factory OnboardingService() => _instance;
  OnboardingService._internal();

  final List<List<FeatureHighlight>> _highlightSteps = [];
  int _currentIndex = 0;
  OverlayEntry? _currentOverlay;
  late Box<dynamic> _onboardingBox;
  bool _isInitialized = false;
  FeatureTourTheme _theme = FeatureTourTheme();

  // Analytics callback
  void Function(String event, Map<String, dynamic> properties)? onAnalyticsEvent;

  // Interactive widget builder
  Widget Function(BuildContext context, VoidCallback onComplete)? interactiveWidgetBuilder;

  Future<void> initialize() async {
    if (!_isInitialized) {
      _onboardingBox = await Hive.openBox('onboarding');
      _isInitialized = true;
    }
  }

  void addFeatureHighlightStep(List<FeatureHighlight> highlights) {
    _highlightSteps.add(highlights);
  }

  void setTheme(FeatureTourTheme theme) {
    _theme = theme;
  }

  void setAnalyticsCallback(void Function(String event, Map<String, dynamic> properties) callback) {
    onAnalyticsEvent = callback;
  }

  void setInteractiveWidgetBuilder(Widget Function(BuildContext context, VoidCallback onComplete) builder) {
    interactiveWidgetBuilder = builder;
  }

  Future<void> startOnboarding(BuildContext context) async {
    await initialize();

    bool onboardingCompleted = await isOnboardingCompleted();
    if (onboardingCompleted) {
      return;
    }

    _currentIndex = _onboardingBox.get('lastViewedStep', defaultValue: 0);

    if (_currentIndex >= _highlightSteps.length) {
      await _endOnboarding();
      return;
    }

    _trackEvent('onboarding_started', {'total_steps': _highlightSteps.length});
    _showNextHighlight(context);
  }

  Future<void> restartOnboarding(BuildContext context) async {
    await initialize();

    _currentIndex = 0;
    await _onboardingBox.put('lastViewedStep', 0);
    await _onboardingBox.put('onboardingCompleted', false);

    _trackEvent('onboarding_restarted', {'total_steps': _highlightSteps.length});
    _showNextHighlight(context);
  }

  void _showNextHighlight(BuildContext context) {
    if (_currentIndex >= _highlightSteps.length) {
      _endOnboarding();
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
          onSkip: () => _endOnboarding(),
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
    _trackEvent('step_viewed', {'step_index': _currentIndex, 'total_steps': _highlightSteps.length});
  }

  void _handleNext(BuildContext context) {
    _currentIndex++;
    _saveProgress();
    _trackEvent('step_completed', {'step_index': _currentIndex - 1, 'total_steps': _highlightSteps.length});
    _showNextHighlight(context);
  }

  Future<void> _endOnboarding() async {
    _currentOverlay?.remove();
    _currentOverlay = null;
    await _saveProgress(completed: true);
    _trackEvent('onboarding_completed', {'total_steps': _highlightSteps.length});
  }

  Future<void> _saveProgress({bool completed = false}) async {
    await _onboardingBox.put('lastViewedStep', _currentIndex);
    await _onboardingBox.put('onboardingCompleted', completed);
  }

  Future<bool> isOnboardingCompleted() async {
    await initialize();
    return _onboardingBox.get('onboardingCompleted', defaultValue: false);
  }

  void _trackEvent(String event, Map<String, dynamic> properties) {
    onAnalyticsEvent?.call(event, properties);
  }
}