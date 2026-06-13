import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elevate/features/notepad/presentation/pages/notepad_web_page.dart';

void main() {
  testWidgets('NotepadWebPage renders AppBar with title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotepadWebPage(),
      ),
    );
    await tester.pump();

    // Verify the scaffold and app bar title render
    expect(find.byType(NotepadWebPage), findsOneWidget);
    expect(find.text('Sticky Notes'), findsOneWidget);
  });
}
