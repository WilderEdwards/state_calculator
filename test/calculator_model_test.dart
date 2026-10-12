import 'package:flutter_test/flutter_test.dart';
import 'package:state_calculator/calculator_model.dart';

void main() {
  group('Core left-to-right contract', () {
    test('2 + 3 × 4 = evaluates as (2 + 3) × 4 = 20', () {
      final calc = CalculatorModel();
      calc.inputDigit('2');
      calc.setOperator('+');
      calc.inputDigit('3');
      // Choosing × after an operand first applies 2 + 3.
      calc.setOperator('×');
      expect(calc.display, '5');
      calc.inputDigit('4');
      calc.equals();
      expect(calc.display, '20');
    });

    test('9 + × 2 = replaces the pending operator → 18', () {
      final calc = CalculatorModel();
      calc.inputDigit('9');
      calc.setOperator('+');
      calc.setOperator('×');
      calc.inputDigit('2');
      calc.equals();
      expect(calc.display, '18');
    });

    test('7 + = ignores equals while awaiting an operand', () {
      final calc = CalculatorModel();
      calc.inputDigit('7');
      calc.setOperator('+');
      calc.equals();
      expect(calc.display, '7');
      expect(calc.pendingOperator, '+');
    });

    test('digit after equals starts a fresh calculation', () {
      final calc = CalculatorModel();
      calc.inputDigit('2');
      calc.setOperator('+');
      calc.inputDigit('2');
      calc.equals();
      expect(calc.display, '4');
      calc.inputDigit('9');
      expect(calc.display, '9');
    });

    test('AC clears operand, accumulator, and pending operator', () {
      final calc = CalculatorModel();
      calc.inputDigit('8');
      calc.setOperator('+');
      calc.inputDigit('2');
      calc.clearAll();
      expect(calc.display, '0');
      expect(calc.pendingOperator, isNull);
      expect(calc.accumulator, isNull);
      // Stale state must not leak into the next calculation.
      calc.inputDigit('4');
      calc.setOperator('+');
      calc.inputDigit('1');
      calc.equals();
      expect(calc.display, '5');
    });

    test('digit after an operator starts the next operand', () {
      final calc = CalculatorModel();
      calc.inputDigit('2');
      calc.setOperator('+');
      calc.inputDigit('3');
      expect(calc.display, '3');
    });
  });

  group('Selected undergraduate features', () {
    test('error handling: division by zero with AC recovery', () {
      final calc = CalculatorModel();
      calc.inputDigit('5');
      calc.setOperator('÷');
      calc.inputDigit('0');
      calc.equals();
      expect(calc.hasError, isTrue);
      expect(calc.display, 'Cannot divide by 0');
      calc.clearAll();
      expect(calc.display, '0');
      expect(calc.hasError, isFalse);
    });

    test('percent: standalone value divides by 100', () {
      final calc = CalculatorModel();
      calc.inputDigit('5');
      calc.inputDigit('0');
      calc.percent();
      expect(calc.display, '0.5');
    });

    test('sign toggle: zero stays zero, negatives flip', () {
      final calc = CalculatorModel();
      calc.toggleSign();
      expect(calc.display, '0');
      calc.inputDigit('5');
      calc.toggleSign();
      expect(calc.display, '-5');
      calc.toggleSign();
      expect(calc.display, '5');
    });
  });
}
