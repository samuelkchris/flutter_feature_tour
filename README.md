# 🎡 Flutter Feature Tour

A powerful and customizable feature tour package for Flutter applications, designed to create
engaging onboarding experiences and highlight key features of your app.

## Demo

![Flutter Feature Tour Demo](https://via.placeholder.com/600x300.png?text=Flutter+Feature+Tour+Demo)
<!-- BEGIN DEMO -->
![screenshot1](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202024-11-11%20at%2021.54.38.png)

![screenshot2](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202024-11-11%20at%2021.54.46.png)

![screenshot3](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202024-11-11%20at%2021.54.52.png)

![screenshot4](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202024-11-11%20at%2021.55.03.png)

![screenshot5](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202024-11-11%20at%2021.55.30.png)

![Ufeatur 4](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/featur4.png)
*Ufeatur 4*

![Ufeature-mac](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/feature-mac.png)
*Ufeature-mac*

![Ufeature 2](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/feature2.png)
*Ufeature 2*

![Ufeature 3](https://github.com/samuelkchris/flutter_feature_tour/blob/master/images/feature3.png)
*Ufeature 3*

<!-- END DEMO -->

## 📋 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Customization](#-customization)
- [Analytics](#-analytics)
- [Interactive Elements](#-interactive-elements)
- [Animations and Transitions](#-animations-and-transitions)
- [Persistence](#-persistence)
- [Accessibility](#-accessibility)
- [Testing](#-testing)
- [Features in Development](#-features-in-development)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Features

- 🎨 Customizable styling with `FeatureTourTheme`
- 🔦 Multiple highlight shapes (circle, rectangle, custom path)
- 📊 Analytics integration
- 🖼️ Interactive elements within tour steps
- 🎭 Smooth animations and transitions
- 💾 Persistence and state management
- ♿ Accessibility features
- 🧪 Testing utilities

## 📥 Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_feature_tour: ^1.0.0
```

Then run:

```
flutter pub get
```

## 🚀 Usage

### Basic Setup

1. Import the package:

```dart
import 'package:flutter_feature_tour/flutter_feature_tour.dart';
```

2. Create an instance of `OnboardingService`:

```dart

final OnboardingService _onboardingService = OnboardingService();
```

3. Set up your feature highlights:

```dart
void _setupOnboarding() {
  _onboardingService.addFeatureHighlightStep([
    FeatureHighlight(
      targetKey: _searchKey,
      title: 'Search',
      description: 'Quickly find what you need using our powerful search feature.',
      icon: Icons.search,
      shape: HighlightShape.circle,
    ),
  ]);

  _onboardingService.addFeatureHighlightStep([
    FeatureHighlight(
      targetKey: _profileKey,
      title: 'Profile',
      description: 'View and edit your profile information here.',
      icon: Icons.person,
      shape: HighlightShape.rectangle,
    ),
  ]);
}
```

4. Start the onboarding process:

```dart
_onboardingService.startOnboarding
(
context
);
```

## 🎨 Customization

Customize the appearance of your feature tour using `FeatureTourTheme`:

```dart
_onboardingService.setTheme
(
FeatureTourTheme(
overlayColor: Colors.black87,
highlightColor: Colors.amber,
cardColor: Colors.grey[900]!,
textColor: Colors.white,
primaryColor: Colors.amber,
titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
bodyStyle: const TextStyle(fontSize: 16),
buttonStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
cornerRadius: 12.0,
highlightBorderWidth
:
3.0
,
)
);
```

You can also use the theme from your app:

```dart
_onboardingService.setTheme
(
FeatureTourTheme.fromTheme(Theme.of(context)));
```

## 📊 Analytics

Integrate analytics to track user engagement:

```dart
_onboardingService.setAnalyticsCallback
(
(String event, Map<String, dynamic> properties) {
// Implement your analytics tracking here
print('Analytics Event: $event, Properties: $properties');
});
```

The package tracks the following events:

- onboarding_started
- onboarding_restarted
- step_viewed
- step_completed
- onboarding_completed

## 🖼️ Interactive Elements

Add interactive elements to your tour steps:

```dart
_onboardingService.setInteractiveWidgetBuilder
(
(BuildContext context, VoidCallback onComplete) {
return ElevatedButton(
child: Text('Try it out!'),
onPressed: () {
// Simulate an action
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('You tried the feature!')),
);
onComplete();
},
);
});
```

## 🎭 Animations and Transitions

The package includes smooth animations for the overlay appearance and highlight transitions. These
are handled automatically by the `FeatureHighlightOverlay` widget.

## 💾 Persistence

The onboarding progress is automatically saved using Hive. To check if onboarding is completed:

```dart

bool onboardingCompleted = await
_onboardingService.isOnboardingCompleted
();
```

To restart the onboarding process:

```dart
_onboardingService.restartOnboarding
(
context
);
```

## ♿ Accessibility

The package includes basic accessibility features:

- Semantic labels for the overlay and buttons
- Keyboard navigation support (Tab, Shift+Tab, Enter, Space)

## 🧪 Testing

To facilitate testing, you can use the following methods:

```dart
testWidgets
('Feature tour test
'
, (WidgetTester tester) async {
await tester.pumpWidget(MyApp());

// Start onboarding
await tester.tap(find.byType(StartOnboardingButton));
await tester.pumpAndSettle();

expect(find.byType(FeatureHighlightOverlay), findsOneWidget);
expect(find.text('Search'), findsOneWidget);

// Tap next button
await tester.tap(find.text('Next'));
await tester.pumpAndSettle();

expect(find.text('Profile'), findsOneWidget);
});
```

## 🚧 Features in Development

The following features are currently in development:

- 🔄 Advanced Navigation: Custom navigation paths and conditional steps
- 🌐 Localization: Built-in support for easy localization of tour content
- 🎯 Multiple Simultaneous Highlights: Ability to highlight multiple elements at once

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.## Demo

Below are demonstrations of the Feature Tour in action:


RandomWord29072
RandomWord5274
RandomWord19155
RandomWord23308
RandomWord3961
RandomWord19054
RandomWord3592
RandomWord20799
RandomWord7881
RandomWord31623
RandomWord22532
RandomWord13240
RandomWord10568
RandomWord9341
RandomWord12478
RandomWord11612
RandomWord26170
RandomWord20545
RandomWord31515
RandomWord23881
RandomWord5261
RandomWord4593
RandomWord16885
RandomWord9024
RandomWord13296
RandomWord4243
RandomWord23967
RandomWord4684
RandomWord19631
RandomWord17297
RandomWord17766
RandomWord14308
RandomWord16027
RandomWord30004
RandomWord26205
RandomWord14530
RandomWord4794
RandomWord28898
RandomWord6886
RandomWord24454
RandomWord15279
RandomWord22808
RandomWord3841
RandomWord30985
RandomWord28904
RandomWord24869
RandomWord7508
RandomWord6786
RandomWord4234
RandomWord26284
RandomWord28926
RandomWord11611
RandomWord13340
RandomWord9943
RandomWord30748
RandomWord23761
RandomWord25589
RandomWord2908
RandomWord29463
RandomWord16718
RandomWord5478
RandomWord19249
RandomWord11444
RandomWord16551
RandomWord19074
RandomWord17661
RandomWord24482
RandomWord13563
RandomWord3418
RandomWord18559
RandomWord9143
RandomWord32467
RandomWord24475
RandomWord12975
RandomWord17417
RandomWord17421
RandomWord13662
RandomWord24703
RandomWord20276
RandomWord24653
RandomWord10352
RandomWord12924
RandomWord20897
RandomWord23448
RandomWord188
RandomWord2763
RandomWord16856
RandomWord11953
RandomWord22392
RandomWord12005
RandomWord25993
RandomWord28982
RandomWord16658
RandomWord2322
RandomWord31576
RandomWord19834
RandomWord10713
RandomWord1447
RandomWord13676
RandomWord22049
RandomWord20844
RandomWord2047
RandomWord20662
RandomWord6526
RandomWord4323
RandomWord13114
RandomWord21761
RandomWord3757
RandomWord22463
RandomWord696
RandomWord18878
RandomWord14447
RandomWord2962
RandomWord28243
RandomWord27533
RandomWord6600
RandomWord13933
