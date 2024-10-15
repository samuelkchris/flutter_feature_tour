import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_feature_tour/flutter_feature_tour.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Tour Example',
      theme: _isDarkMode ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: MyHomePage(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  MyHomePage({required this.toggleTheme, required this.isDarkMode});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OnboardingService _onboardingService = OnboardingService();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _scrollItemKey = GlobalKey();
  bool _useCustomTourTheme = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setTourTheme();
      _setupOnboarding();
    });
  }

  void _setTourTheme() {
    if (_useCustomTourTheme) {
      _onboardingService.setTheme(FeatureTourTheme(
        overlayColor: Colors.black87,
        highlightColor: Colors.amber,
        cardColor: Colors.grey[900]!,
        textColor: Colors.white,
        primaryColor: Colors.amber,
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        bodyStyle: const TextStyle(fontSize: 16),
        buttonStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        cornerRadius: 12.0,
        highlightBorderWidth: 3.0,
      ));
    } else {
      _onboardingService.setTheme(FeatureTourTheme.fromTheme(Theme.of(context)));
    }
  }

  void _toggleTourTheme() {
    setState(() {
      _useCustomTourTheme = !_useCustomTourTheme;
      _setTourTheme();
    });
  }

  void _setupOnboarding() {
    // Set up analytics callback
    _onboardingService.setAnalyticsCallback((String event, Map<String, dynamic> properties) {
      print('Analytics Event: $event, Properties: $properties');
      // Implement your analytics tracking here
    });

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _searchKey,
        title: 'Search',
        description: 'Quickly find what you need using our powerful search feature.',
        icon: Iconsax.search_normal,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _profileKey,
        title: 'Profile',
        description: 'View and edit your profile information here.',
        icon: Iconsax.user,
        shape: HighlightShape.rectangle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _settingsKey,
        title: 'Settings',
        description: 'Customize the app to your liking in the settings menu.',
        icon: Iconsax.setting_2,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _notificationKey,
        title: 'Notifications',
        description: 'Stay updated with the latest news and alerts.',
        icon: Iconsax.notification,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _scrollItemKey,
        title: 'Special Item',
        description: 'This item is highlighted to show you can target list items too!',
        icon: Iconsax.star,
        shape: HighlightShape.rectangle,
      ),
    ]);

    // Set up interactive widget builder
    _onboardingService.setInteractiveWidgetBuilder((BuildContext context, VoidCallback onComplete) {
      return ElevatedButton.icon(
        icon: const Icon(Iconsax.play),
        label: const Text('Try it out!'),
        onPressed: () {
          // Simulate an action
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You tried the feature!')),
          );
          onComplete();
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Tour Example'),
        actions: [
          IconButton(
            key: _searchKey,
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {},
          ),
          IconButton(
            key: _profileKey,
            icon: const Icon(Iconsax.user),
            onPressed: () {},
          ),
          IconButton(
            key: _settingsKey,
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {},
          ),
          IconButton(
            key: _notificationKey,
            icon: const Icon(Iconsax.notification),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: Icon(widget.isDarkMode ? Iconsax.sun_1 : Iconsax.moon),
                label: Text(widget.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                onPressed: () => widget.toggleTheme(),
              ),
              ElevatedButton.icon(
                icon: Icon(_useCustomTourTheme ? Iconsax.brush_1 : Iconsax.brush_4),
                label: Text(_useCustomTourTheme ? 'Default Tour Theme' : 'Custom Tour Theme'),
                onPressed: _toggleTourTheme,
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Iconsax.repeat),
            label: const Text('Restart Onboarding'),
            onPressed: () {
              _onboardingService.restartOnboarding(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                if (index == 15) {
                  return ListTile(
                    key: _scrollItemKey,
                    leading: const Icon(Iconsax.star1, color: Colors.yellow),
                    title: const Text('Special Item'),
                    subtitle: const Text('This item is highlighted in the tour'),
                    trailing: const Icon(Iconsax.arrow_right_3),
                  );
                }
                return ListTile(
                  leading: const Icon(Iconsax.document),
                  title: Text('Item $index'),
                  subtitle: const Text('This is a regular list item'),
                  trailing: const Icon(Iconsax.arrow_right_3),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new item')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }
}