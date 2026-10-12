import 'package:flutter/material.dart';

import 'calculator_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _mode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: _mode,
      home: MyHomePage(
        title: 'Calculator State Lab',
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.isDark,
    required this.onToggleTheme,
  });

  final String title;
  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CalculatorModel _model = CalculatorModel();

  void _onDigit(String digit) => setState(() => _model.inputDigit(digit));
  void _onDecimal() => setState(() => _model.inputDecimal());
  void _onOperator(String op) => setState(() => _model.setOperator(op));
  void _onEquals() => setState(() => _model.equals());
  void _onClear() => setState(() => _model.clearAll());
  void _onSign() => setState(() => _model.toggleSign());
  void _onPercent() => setState(() => _model.percent());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Switch to light theme' : 'Switch to dark theme',
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDisplay(),
                  const SizedBox(height: 12),
                  Expanded(child: _buildButtonGrid()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    final pending = _model.pendingOperator != null && _model.accumulator != null
        ? '${CalculatorModel.formatNumber(_model.accumulator!)} ${_model.pendingOperator}'
        : '';
    return Semantics(
      label: _model.hasError
          ? 'Calculator display showing error: ${_model.display}'
          : 'Calculator display showing ${_model.display}',
      liveRegion: true,
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pending.isNotEmpty)
              Text(
                pending,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ExcludeSemantics(
              child: Text(
                _model.display,
                key: const Key('calc-display'),
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Courier',
                  fontFamilyFallback: const ['monospace'],
                  color: _model.hasError
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_model.hasError)
              Text(
                '${_model.errorMessage} — tap AC to clear',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Column(
      key: const Key('calc-grid'),
      children: [
        _buttonRow([
          _calcButton(label: 'AC', semanticLabel: 'All clear', onPressed: _onClear),
          _calcButton(label: '±', semanticLabel: 'Toggle positive negative', onPressed: _onSign),
          _calcButton(label: '%', semanticLabel: 'Percent', onPressed: _onPercent),
          _calcButton(
            label: '÷',
            semanticLabel: 'Divide',
            onPressed: () => _onOperator('÷'),
            isOperator: true,
          ),
        ]),
        _buttonRow([
          _calcButton(label: '7', onPressed: () => _onDigit('7')),
          _calcButton(label: '8', onPressed: () => _onDigit('8')),
          _calcButton(label: '9', onPressed: () => _onDigit('9')),
          _calcButton(
            label: '×',
            semanticLabel: 'Multiply',
            onPressed: () => _onOperator('×'),
            isOperator: true,
          ),
        ]),
        _buttonRow([
          _calcButton(label: '4', onPressed: () => _onDigit('4')),
          _calcButton(label: '5', onPressed: () => _onDigit('5')),
          _calcButton(label: '6', onPressed: () => _onDigit('6')),
          _calcButton(
            label: '−',
            semanticLabel: 'Subtract',
            onPressed: () => _onOperator('-'),
            isOperator: true,
          ),
        ]),
        _buttonRow([
          _calcButton(label: '1', onPressed: () => _onDigit('1')),
          _calcButton(label: '2', onPressed: () => _onDigit('2')),
          _calcButton(label: '3', onPressed: () => _onDigit('3')),
          _calcButton(
            label: '+',
            semanticLabel: 'Add',
            onPressed: () => _onOperator('+'),
            isOperator: true,
          ),
        ]),
        Expanded(
          flex: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _calcButton(label: '0', onPressed: () => _onDigit('0')),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _calcButton(
                    label: '.',
                    semanticLabel: 'Decimal point',
                    onPressed: _onDecimal,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _calcButton(
                    label: '=',
                    semanticLabel: 'Equals',
                    onPressed: _onEquals,
                    isEquals: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buttonRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final button in buttons)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: button,
              ),
            ),
        ],
      ),
    );
  }

  Widget _calcButton({
    required String label,
    String? semanticLabel,
    required VoidCallback onPressed,
    bool isOperator = false,
    bool isEquals = false,
  }) {
    return _CalcButton(
      key: Key('calc-key-$label'),
      label: label,
      semanticLabel: semanticLabel ?? label,
      onPressed: onPressed,
      isOperator: isOperator,
      isEquals: isEquals,
    );
  }
}

/// Calculator key with a smooth, consistent press response (scale animation)
/// layered on top of the Material ink splash, so every button behaves the
/// same way without lag.
class _CalcButton extends StatefulWidget {
  const _CalcButton({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    this.isOperator = false,
    this.isEquals = false,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;
  final bool isOperator;
  final bool isEquals;

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = widget.isEquals
        ? scheme.primary
        : widget.isOperator
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHigh;
    final foreground = widget.isEquals
        ? scheme.onPrimary
        : widget.isOperator
            ? scheme.onSecondaryContainer
            : scheme.onSurface;

    return AnimatedScale(
      scale: _pressed ? 0.93 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onPressed,
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Semantics(
            button: true,
            label: widget.semanticLabel,
            child: Center(
              // Excluded so screen readers announce the semantic label
              // exactly once instead of label + visible glyph.
              child: ExcludeSemantics(
                child: Text(
                  widget.label,
                  style: TextStyle(fontSize: 24, color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
