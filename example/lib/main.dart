import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_feature_tour/flutter_feature_tour.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
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

  const MyHomePage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final OnboardingService _onboardingService = OnboardingService();
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _notificationKey = GlobalKey();
  final GlobalKey _addItemKey = GlobalKey();
  final GlobalKey _listItemKey = GlobalKey();
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
    _onboardingService.startOnboarding(context);
    // Set up analytics callback
    _onboardingService.setAnalyticsCallback((String event, Map<String, dynamic> properties) {
      if (kDebugMode) {
        print('Analytics Event: $event, Properties: $properties');
      }
      // Implement your analytics tracking here
    });

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _dashboardKey,
        title: 'Welcome to Your Dashboard',
        description: 'This is your central hub for all app activities. Let\'s explore the key features!',
        icon: Iconsax.category,
        shape: HighlightShape.rectangle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _searchKey,
        title: 'Quick Search',
        description: 'Find anything in the app instantly with our powerful search feature.',
        icon: Iconsax.search_normal,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _profileKey,
        title: 'Your Profile',
        description: 'View and customize your profile information here.',
        icon: Iconsax.user,
        shape: HighlightShape.rectangle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _settingsKey,
        title: 'App Settings',
        description: 'Tailor the app to your preferences in the settings menu.',
        icon: Iconsax.setting_2,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _notificationKey,
        title: 'Stay Updated',
        description: 'Get real-time notifications about important events and updates.',
        icon: Iconsax.notification,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _addItemKey,
        title: 'Add New Items',
        description: 'Quickly add new items to your list with this floating action button.',
        icon: Iconsax.add,
        shape: HighlightShape.circle,
      ),
    ]);

    _onboardingService.addFeatureHighlightStep([
      FeatureHighlight(
        targetKey: _listItemKey,
        title: 'Interactive List Items',
        description: 'Each item in the list is interactive. Try swiping or tapping for more options!',
        icon: Iconsax.edit,
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
            const SnackBar(content: Text('Great job! You\'ve tried the feature!')),
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
        title: const Text('Feature Tour Demo'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              key: _dashboardKey,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to Your Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
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
            label: const Text('Restart Feature Tour'),
            onPressed: () {
              _onboardingService.restartOnboarding(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  key: index == 0 ? _listItemKey : null,
                  leading: const Icon(Iconsax.document),
                  title: Text('Item ${index + 1}'),
                  subtitle: const Text('Swipe me or tap for options'),
                  trailing: const Icon(Iconsax.arrow_right_3),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You tapped on Item ${index + 1}')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _addItemKey,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adding a new item')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }
}
