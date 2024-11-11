/// A Flutter package for creating interactive feature tours and onboarding experiences.
///
/// This package provides a customizable way to highlight and explain features in your app
/// through an interactive step-by-step tour. It includes support for:
/// * Multi-step feature tours
/// * Customizable themes and styling
/// * Analytics tracking
/// * Progress persistence
/// * Interactive widgets
/// * Cross-platform compatibility
///
/// Example usage:
/// ```dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: MyHomePage(),
///     );
///   }
/// }
///
/// class MyHomePage extends StatefulWidget {
///   @override
///   _MyHomePageState createState() => _MyHomePageState();
/// }
///
/// class _MyHomePageState extends State<MyHomePage> {
///   @override
///   void initState() {
///     super.initState();
///     _setupOnboarding();
///   }
///
///   Future<void> _setupOnboarding() async {
///     final onboardingService = OnboardingService();
///
///     // Add feature highlights
///     onboardingService.addFeatureHighlightStep([
///       FeatureHighlight(
///         targetKey: GlobalKey(),
///         title: 'Welcome!',
///         description: 'Let\'s take a quick tour of the app.',
///         icon: Icons.waving_hand,
///       ),
///     ]);
///
///     // Start the tour
///     await onboardingService.startOnboarding(context);
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(title: Text('My App')),
///       body: Center(child: Text('Content')),
///     );
///   }
/// }
/// ```
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feature_highlight.dart';
import 'feature_highlight_overlay.dart';
import 'feature_tour_theme.dart';

/// A service that manages the onboarding process and feature tour for an application.
///
/// The [OnboardingService] is implemented as a singleton to ensure consistent state
/// management across the application. It handles:
/// * Feature tour step management
/// * Progress persistence using SharedPreferences
/// * Analytics event tracking
/// * Theme customization
/// * Interactive widget integration
///
/// Before using the service, it should be initialized:
/// ```dart
/// final onboardingService = OnboardingService();
/// await onboardingService.initialize();
/// ```
class OnboardingService {
  /// Private constructor for singleton pattern
  OnboardingService._internal();

  /// Singleton instance of the service
  static final OnboardingService _instance = OnboardingService._internal();

  /// Factory constructor that returns the singleton instance
  factory OnboardingService() => _instance;

  /// Stores the steps of the feature tour, where each step can contain multiple highlights
  final List<List<FeatureHighlight>> _highlightSteps = [];

  /// Current index in the feature tour
  int _currentIndex = 0;

  /// Current overlay entry being displayed
  OverlayEntry? _currentOverlay;

  /// SharedPreferences instance for storing progress
  late SharedPreferences _prefs;

  /// Flag indicating whether the service has been initialized
  bool _isInitialized = false;

  /// Theme configuration for the feature tour
  FeatureTourTheme _theme = FeatureTourTheme();

  /// Callback function for tracking analytics events
  ///
  /// When set, this function will be called with event name and properties
  /// for various tour interactions
  void Function(String event, Map<String, dynamic> properties)?
      onAnalyticsEvent;

  /// Builder function for creating interactive widgets within the feature tour
  ///
  /// This can be used to add custom interactive elements to the tour
  Widget Function(BuildContext context, VoidCallback onComplete)?
      interactiveWidgetBuilder;

  /// Initializes the onboarding service.
  ///
  /// This method must be called before using any other methods of the service.
  /// It initializes SharedPreferences for storing onboarding state.
  ///
  /// ```dart
  /// await OnboardingService().initialize();
  /// ```
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Adds a step to the feature tour.
  ///
  /// Each step consists of a list of [FeatureHighlight]s that will be displayed together.
  /// Steps are shown in the order they are added.
  ///
  /// ```dart
  /// onboardingService.addFeatureHighlightStep([
  ///   FeatureHighlight(
  ///     targetKey: key,
  ///     title: 'Feature Title',
  ///     description: 'Feature Description',
  ///     icon: Icons.star,
  ///   ),
  /// ]);
  /// ```
  void addFeatureHighlightStep(List<FeatureHighlight> highlights) {
    _highlightSteps.add(highlights);
  }

  /// Sets the theme for the feature tour.
  ///
  /// The theme controls the visual appearance of the feature tour overlays.
  /// ```dart
  /// onboardingService.setTheme(FeatureTourTheme(
  ///   backgroundColor: Colors.blue,
  ///   textColor: Colors.white,
  /// ));
  /// ```
  void setTheme(FeatureTourTheme theme) {
    _theme = theme;
  }

  /// Sets the callback function for tracking analytics events.
  ///
  /// This function will be called whenever significant events occur during the tour.
  /// ```dart
  /// onboardingService.setAnalyticsCallback((event, properties) {
  ///   analytics.logEvent(event, properties);
  /// });
  /// ```
  void setAnalyticsCallback(
      void Function(String event, Map<String, dynamic> properties) callback) {
    onAnalyticsEvent = callback;
  }

  /// Sets the builder function for creating interactive widgets.
  ///
  /// This allows adding custom interactive elements to the feature tour.
  /// ```dart
  /// onboardingService.setInteractiveWidgetBuilder((context, onComplete) {
  ///   return CustomWidget(onComplete: onComplete);
  /// });
  /// ```
  void setInteractiveWidgetBuilder(
      Widget Function(BuildContext context, VoidCallback onComplete) builder) {
    interactiveWidgetBuilder = builder;
  }

  /// Starts the onboarding process.
  ///
  /// This method will show the first unseen step of the feature tour,
  /// or do nothing if the onboarding has already been completed.
  /// ```dart
  /// await onboardingService.startOnboarding(context);
  /// ```
  Future<void> startOnboarding(BuildContext context) async {
    await initialize();

    bool onboardingCompleted = await isOnboardingCompleted();
    if (onboardingCompleted) {
      return;
    }

    _currentIndex = _prefs.getInt('lastViewedStep') ?? 0;

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
  /// This method resets the onboarding progress and starts the feature tour
  /// from the first step.
  /// ```dart
  /// await onboardingService.restartOnboarding(context);
  /// ```
  Future<void> restartOnboarding(BuildContext context) async {
    await initialize();

    _currentIndex = 0;
    await _prefs.setInt('lastViewedStep', 0);
    await _prefs.setBool('onboardingCompleted', false);

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
    await _prefs.setInt('lastViewedStep', _currentIndex);
    await _prefs.setBool('onboardingCompleted', completed);
  }

  /// Checks if the onboarding process has been completed.
  ///
  /// Returns `true` if onboarding has been completed, `false` otherwise.
  /// ```dart
  /// bool completed = await onboardingService.isOnboardingCompleted();
  /// ```
  Future<bool> isOnboardingCompleted() async {
    await initialize();
    return _prefs.getBool('onboardingCompleted') ?? false;
  }

  /// Tracks an analytics event.
  void _trackEvent(String event, Map<String, dynamic> properties) {
    onAnalyticsEvent?.call(event, properties);
  }
}
