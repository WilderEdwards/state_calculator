/// Pure-Dart calculator model for the left-to-right running-total contract.
///
/// Core contract (Assignment 01, alternate edition):
/// - A digit after an operator starts the next operand.
/// - Choosing another operator after an operand first applies the pending
///   operation and displays the running total.
/// - Choosing an operator twice before entering another digit replaces the
///   pending operator.
/// - Equals with no new operand is ignored.
/// - A digit after equals starts a fresh calculation.
/// - AC clears the display, accumulator, and pending operator.
///
/// Evaluation is strictly left to right with NO operator precedence:
/// `2 + 3 x 4 =` evaluates as `(2 + 3) x 4 = 20`.
class CalculatorModel {
  String _input = '0';
  double? _accumulator;
  String? _pendingOp;
  bool _awaitingOperand = false;
  bool _justEvaluated = false;
  String? _error;

  /// What the display should show right now.
  String get display => _error ?? _input;

  /// Non-null when an error is active (e.g. division by zero).
  String? get errorMessage => _error;

  bool get hasError => _error != null;

  /// Exposed for tests / UI hints (e.g. showing the pending operator).
  double? get accumulator => _accumulator;
  String? get pendingOperator => _pendingOp;
  bool get awaitingOperand => _awaitingOperand;
  bool get justEvaluated => _justEvaluated;

  static const int maxDigits = 12;

  void inputDigit(String digit) {
    assert(digit.length == 1 && int.tryParse(digit) != null);
    if (_error != null) {
      clearAll();
    }
    if (_justEvaluated) {
      // Digit after equals starts a fresh calculation.
      _input = digit;
      _accumulator = null;
      _pendingOp = null;
      _awaitingOperand = false;
      _justEvaluated = false;
      return;
    }
    if (_awaitingOperand) {
      // Digit after an operator starts the next operand.
      _input = digit;
      _awaitingOperand = false;
      return;
    }
    if (_input == '0') {
      _input = digit;
    } else if (_input == '-0') {
      _input = '-$digit';
    } else {
      final digitCount = _input.replaceAll(RegExp(r'[^0-9]'), '').length;
      if (digitCount >= maxDigits) return;
      _input += digit;
    }
  }

  void inputDecimal() {
    if (_error != null) {
      clearAll();
      _input = '0.';
      return;
    }
    if (_justEvaluated) {
      _input = '0.';
      _accumulator = null;
      _pendingOp = null;
      _awaitingOperand = false;
      _justEvaluated = false;
      return;
    }
    if (_awaitingOperand) {
      _input = '0.';
      _awaitingOperand = false;
      return;
    }
    if (!_input.contains('.')) {
      _input += '.';
    }
  }

  /// Accepts '+', '-', '×' (or '*'), '÷' (or '/').
  void setOperator(String op) {
    final normalized = _normalizeOp(op);
    if (normalized == null || _error != null) return;

    if (_justEvaluated) {
      // Continue chaining from the displayed result.
      _accumulator = double.tryParse(_input) ?? 0;
      _justEvaluated = false;
    }

    if (_awaitingOperand) {
      // Operator pressed twice: replace the pending operator.
      _pendingOp = normalized;
      return;
    }

    final current = double.tryParse(_input) ?? 0;
    if (_accumulator == null || _pendingOp == null) {
      _accumulator = current;
    } else {
      final result = _apply(_accumulator!, current, _pendingOp!);
      if (result == null) {
        _setError(current);
        return;
      }
      _accumulator = result;
      _input = formatNumber(result);
    }
    _pendingOp = normalized;
    _awaitingOperand = true;
  }

  void equals() {
    if (_error != null) return;
    // Equals with no new operand is ignored.
    if (_pendingOp == null || _accumulator == null || _awaitingOperand) return;
    final current = double.tryParse(_input) ?? 0;
    final result = _apply(_accumulator!, current, _pendingOp!);
    if (result == null) {
      _setError(current);
      return;
    }
    _input = formatNumber(result);
    _accumulator = null;
    _pendingOp = null;
    _awaitingOperand = false;
    _justEvaluated = true;
  }

  void clearAll() {
    _input = '0';
    _accumulator = null;
    _pendingOp = null;
    _awaitingOperand = false;
    _justEvaluated = false;
    _error = null;
  }

  /// Sign toggle. Zero (including '-0' / '0.') stays '0'.
  void toggleSign() {
    if (_error != null) return;
    if (_awaitingOperand) {
      _input = '-0';
      _awaitingOperand = false;
      return;
    }
    if (_input.startsWith('-')) {
      _input = _input.substring(1);
      if (_input.isEmpty || _input == '0' || _input == '0.') _input = '0';
    } else {
      final value = double.tryParse(_input) ?? 0;
      if (value == 0) {
        _input = '0';
      } else {
        _input = '-$_input';
      }
    }
  }

  /// Percent: standalone value and in-operation behavior are both
  /// "divide the current input by 100" (e.g. `50` → `0.5`;
  /// `50 + 10 % =` → `50 + 0.1 = 50.1` under left-to-right rules).
  void percent() {
    if (_error != null) return;
    final value = double.tryParse(_input) ?? 0;
    final result = value / 100;
    _input = formatNumber(result);
    if (_awaitingOperand) _awaitingOperand = false;
  }

  static String? _normalizeOp(String op) {
    switch (op) {
      case '+':
      case '-':
      case '×':
      case '*':
        return op == '*' ? '×' : op;
      case '÷':
      case '/':
        return '÷';
      default:
        return null;
    }
  }

  /// Returns null when the operation cannot be completed (div by zero or
  /// non-finite result) so the caller can raise an error state.
  static double? _apply(double left, double right, String op) {
    double result;
    switch (op) {
      case '+':
        result = left + right;
        break;
      case '-':
        result = left - right;
        break;
      case '×':
        result = left * right;
        break;
      case '÷':
        if (right == 0) return null;
        result = left / right;
        break;
      default:
        return null;
    }
    if (!result.isFinite) return null;
    // Snap away float noise (e.g. 0.1 + 0.2).
    return double.tryParse(result.toStringAsPrecision(12)) ?? result;
  }

  void _setError(double attemptedSecondOperand) {
    if (attemptedSecondOperand == 0 && _pendingOp == '÷') {
      _error = 'Cannot divide by 0';
    } else {
      _error = 'Out of range';
    }
    _accumulator = null;
    _pendingOp = null;
    _awaitingOperand = false;
    _justEvaluated = false;
  }

  /// Formats a finite double without trailing noise ('20', not
  /// '20.00000000'; '0.3', not '0.30000000000000004').
  static String formatNumber(double value) {
    if (!value.isFinite) return 'Error';
    if (value == 0) return '0';
    var s = value.toStringAsPrecision(10);
    if (s.contains('e') || s.contains('E')) return s;
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
    }
    if (s == '-0') return '0';
    return s;
  }
}
