// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_feature_tour/flutter_feature_tour.dart';
//
// void main() {
//   group('OnboardingService Tests', () {
//     late OnboardingService onboardingService;
//
//     setUp(() {
//       onboardingService = OnboardingService();
//     });
//
//     test('Adding feature highlight steps', () {
//       onboardingService.addFeatureHighlightStep([
//         FeatureHighlight(
//           targetKey: GlobalKey(),
//           title: 'Test',
//           description: 'Test description',
//           icon: Icons.star,
//         ),
//       ]);
//
//       expect(onboardingService.getSteps().length, 1);
//     });
//
//     test('Setting and getting theme', () {
//       final customTheme = const FeatureTourTheme(
//         overlayColor: Colors.black87,
//         highlightColor: Colors.amber,
//       );
//       onboardingService.setTheme(customTheme);
//
//       expect(onboardingService.getTheme(), customTheme);
//     });
//
//     test('Setting analytics callback', () {
//       bool callbackCalled = false;
//       onboardingService.setAnalyticsCallback(
//           (String event, Map<String, dynamic> properties) {
//         callbackCalled = true;
//       });
//
//       onboardingService
//           .trackAnalyticsEvent('test_event', {'property': 'value'});
//       expect(callbackCalled, true);
//     });
//
//     test('Setting interactive widget builder', () {
//       onboardingService.setInteractiveWidgetBuilder(
//           (BuildContext context, VoidCallback onComplete) {
//         return ElevatedButton(onPressed: onComplete, child: const Text('Test'));
//       });
//
//       expect(onboardingService.getInteractiveWidgetBuilder(), isNotNull);
//     });
//   });
//
//   testWidgets('FeatureHighlightOverlay widget test',
//       (WidgetTester tester) async {
//     final GlobalKey targetKey = GlobalKey();
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: Stack(
//             children: [
//               Center(
//                 child: Container(
//                   key: targetKey,
//                   width: 100,
//                   height: 100,
//                   color: Colors.blue,
//                 ),
//               ),
//               FeatureHighlightOverlay(
//                 highlights: [
//                   FeatureHighlight(
//                     targetKey: targetKey,
//                     title: 'Test Highlight',
//                     description: 'This is a test description',
//                     icon: Icons.star,
//                   ),
//                 ],
//                 onNext: () {},
//                 onSkip: () {},
//                 onFinish: () {},
//                 totalSteps: 1,
//                 currentStep: 1,
//                 theme: FeatureTourTheme(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//
// // Verify that the FeatureHighlightOverlay is rendered
//     expect(find.byType(FeatureHighlightOverlay), findsOneWidget);
//
// // Verify that the highlight and info card are displayed
//     expect(find.byType(CustomPaint), findsOneWidget);
//     expect(find.text('Test Highlight'), findsOneWidget);
//     expect(find.text('This is a test description'), findsOneWidget);
//   });
// }
