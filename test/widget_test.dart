// This is a basic Flutter widget test for Mini Task & Habit Tracker
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mini_task_habit_tracker/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('Mini Tracker'), findsOneWidget);
  });
}
