import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elevate/main.dart';

void main() {
  testWidgets('ElevateApp smoke test', (WidgetTester tester) async {
    await Hive.initFlutter();
    await Hive.openBox('notesBox');
    await Hive.openBox('alarmsBox');
    await Hive.openBox('newsBox');

    await tester.pumpWidget(
      const ProviderScope(
        child: ElevateApp(),
      ),
    );

    // Allow the async dashboard data timer to complete
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ElevateApp), findsOneWidget);
  });
}
