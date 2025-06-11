import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.purple,
                secondary: Colors.amber,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.deepPurple,
              ),
            ),
      home: CalculatorScreen(
        isDarkMode: isDarkMode,
        onThemeToggle: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "";

  void onButtonClick(String value) {
    setState(() {
      if (value == "C") {
        input = "";
        result = "";
      } else if (value == "=") {
        try {
          final exp = input.replaceAll("×", "*").replaceAll("÷", "/");
          result = "Result: ${_evaluateExpression(exp)}";
        } catch (_) {
          result = "Error";
        }
      } else {
        input += value;
      }
    });
  }

  String _evaluateExpression(String expression) {
    double eval = double.parse(
      (Function.apply(ExpressionEvaluator().evaluate, [
        expression,
      ])).toStringAsFixed(2),
    );
    return eval.toString();
  }

  Widget buildButton(String text, {Color? color}) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: () => onButtonClick(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("❤️Calculator❤️"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.onThemeToggle,
            tooltip: "Toggle Theme",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                input,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: const TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...['7', '8', '9', '÷'].map((e) => buildButton(e)),
                ...['4', '5', '6', '×'].map((e) => buildButton(e)),
                ...['1', '2', '3', '-'].map((e) => buildButton(e)),
                ...['0', '.', '%', '+'].map((e) => buildButton(e)),
                buildButton("C", color: Colors.redAccent),
                buildButton("=", color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpressionEvaluator {
  double evaluate(String expression) {
    final parsed = _parse(expression);
    return _calculate(parsed);
  }

  List<String> _parse(String expression) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      if ('0123456789.'.contains(char)) {
        buffer.write(char);
      } else if ('+-*/%'.contains(char)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }
        tokens.add(char);
      }
    }
    if (buffer.isNotEmpty) tokens.add(buffer.toString());
    return tokens;
  }

  double _calculate(List<String> tokens) {
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final op = tokens[i];
      final num = double.parse(tokens[i + 1]);
      switch (op) {
        case '+':
          total += num;
          break;
        case '-':
          total -= num;
          break;
        case '*':
          total *= num;
          break;
        case '/':
          total = num != 0 ? total / num : double.nan;
          break;
        case '%':
          total = num != 0 ? total % num : double.nan;
          break;
      }
    }
    return total;
  }
}
