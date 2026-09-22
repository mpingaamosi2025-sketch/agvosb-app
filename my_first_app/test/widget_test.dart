import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('shows the calendar and supports bottom navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgVosbApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('AgVosb'), findsOneWidget);

    await tester.tap(find.text('Calendar').last);
    await tester.pump();
    expect(find.text('No events for this day'), findsOneWidget);

    await tester.tap(find.text('Stopwatch').last);
    await tester.pump();
    expect(find.text('Stopwatch').first, findsOneWidget);
  });
}
