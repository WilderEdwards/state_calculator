import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:state_calculator/main.dart';

/// Executable accessibility checks for Agent Test Drive 02.
void main() {
  testWidgets('a11y: every key announces the right label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const MyApp());

    // What TalkBack actually announces (effective semantics node, which the
    // framework combines from the button's ink response and label).
    // find.bySemanticsLabel cannot see these because the framework merges
    // the label node upward -- the framework docs describe exactly this case.
    final grid = find.byKey(const Key('calc-grid'));
    Finder keyFinder(String text) => find.descendant(of: grid, matching: find.text(text));
    const expected = {
      'AC': 'All clear',
      '±': 'Toggle positive negative',
      '%': 'Percent',
      '÷': 'Divide',
      '7': '7',
      '8': '8',
      '9': '9',
      '×': 'Multiply',
      '4': '4',
      '5': '5',
      '6': '6',
      '−': 'Subtract',
      '1': '1',
      '2': '2',
      '3': '3',
      '+': 'Add',
      '0': '0',
      '.': 'Decimal point',
      '=': 'Equals',
    };
    for (final entry in expected.entries) {
      expect(
        tester.getSemantics(keyFinder(entry.key)).label,
        entry.value,
        reason: 'wrong announcement for ${entry.key}',
      );
    }
    expect(
      tester.getSemantics(find.byKey(const Key('calc-display'))).label,
      'Calculator display showing 0',
    );
    handle.dispose();
  });

  testWidgets('a11y: touch targets are at least 48x48', (tester) async {
    await tester.pumpWidget(const MyApp());

    final keys = find.byType(InkWell);
    expect(keys, findsWidgets);
    for (final element in keys.evaluate()) {
      final box = element.renderObject! as RenderBox;
      expect(box.size.width, greaterThanOrEqualTo(48));
      expect(box.size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('a11y: layout survives 200% text scaling', (tester) async {
    final handle = tester.ensureSemantics();
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MyApp());
    // Tap by key: at 200% scale the display text duplicates button text,
    // so text finders are ambiguous.
    await tester.tap(find.byKey(const Key('calc-key-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('calc-key-+')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('calc-key-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('calc-key-=')));
    await tester.pump();
    expect(find.text('4'), findsWidgets);
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    handle.dispose();
  });

  testWidgets('a11y: narrow 320px screen keeps full flow', (tester) async {
    tester.view.physicalSize = const Size(960, 1704);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    for (final key in ['2', '+', '3', '×', '4', '=']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    expect(find.text('20'), findsWidgets);
  });
}
