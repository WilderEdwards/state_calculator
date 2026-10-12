import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:state_calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test: running total and AC reset',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Display starts at 0.
    expect(find.byKey(const Key('calc-display')), findsOneWidget);
    expect(find.text('0'), findsWidgets);

    // 2 + 3 × 4 = → 20 (left-to-right running total).
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    // After entering the second operand and choosing ×, 2 + 3 commits.
    await tester.tap(find.text('×'));
    await tester.pump();
    expect(find.text('5'), findsWidgets);
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(find.text('20'), findsWidgets);

    // AC resets everything.
    await tester.tap(find.text('AC'));
    await tester.pump();
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('Operator replacement: 9 + × 2 = → 18',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('9'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('×'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();
    expect(find.text('18'), findsWidgets);
  });
}
