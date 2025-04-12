import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vini_drive_ops/screens/driver/dashboard_screen.dart';

void main() {
  group('DriverDashboard Widget Tests', () {
    testWidgets('renders driver dashboard elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));

      expect(find.text('Driver Dashboard'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('displays driver profile information', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
      
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('shows status toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
      
      expect(find.byType(Switch), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('displays trip history section', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
      
      expect(find.text('Recent Trips'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows earnings summary', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));
      
      expect(find.text('Earnings'), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('handles status toggle interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DriverDashboardScreen()));

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle(); // Use pumpAndSettle to handle all animations and timers

      // Verify status change
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('navigates to trip details on tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DriverDashboardScreen(),
        routes: {
          '/trip-details': (context) => Scaffold(appBar: AppBar(title: Text('Trip Details')))
        },
      ));

      final tripTile = find.byType(ListTile).first;
      await tester.tap(tripTile);
      await tester.pumpAndSettle();

      // Verify navigation to trip details
      expect(find.text('Trip Details'), findsOneWidget);
    });
  });
}