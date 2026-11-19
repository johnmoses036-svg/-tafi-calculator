
import 'package:flutter/material.dart';

void main() {
  runApp(const TafiCalculator());
}

class TafiCalculator extends StatelessWidget {
  const TafiCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TAFI Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101827),
      ),
      home: const CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({super.key});

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String expression = '';
  String result = '0';
  bool newInput = false;
  bool darkMode = true;
  final List<String> history = [];

  void press(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
        newInput = false;
      } else if (value == '⌫') {
        if (expression.isNotEmpty) {
          expression =
              expression.substring(0, expression.length - 1);
        }
      } else if (value == '=') {
        calculate();
      } else {
        if (newInput) {
          expression = '';
          newInput = false;
        }
        expression += value;
      }
    });
  }

  void calculate() {
    try {
      final output = MathParser(expression).parse();
      if (!output.isFinite) throw Exception();

      result = output == output.roundToDouble()
          ? output.toInt().toString()
          : output.toStringAsFixed(8)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');

      if (expression.isNotEmpty) {
        history.insert(0, '$expression = $result');
        if (history.length > 30) history.removeLast();
      }
      newInput = true;
    } catch (_) {
      result = 'Error';
      newInput = true;
    }
  }

  void showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C293B),
      builder: (context) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('CALCULATION HISTORY',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                children: history
                    .map((item) => ListTile(
                          title: Text(item,
                              style: const TextStyle(
                                  color: Colors.white)),
                        ))
                    .toList(),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => history.clear());
                Navigator.pop(context);
              },
              child: const Text('CLEAR HISTORY'),
            )
          ],
        ),
      ),
    );
  }

  Widget keyButton(String text) {
    final isOperator = [
      '%', '÷', '×', '−', '+', '='
    ].contains(text);
    final isSpecial = ['AC', '⌫'].contains(text);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: 68,
          child: ElevatedButton(
            onPressed: () => press(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: text == '='
                  ? const Color(0xFF2878F0)
                  : isOperator
                      ? const Color(0xFF253D5B)
                      : isSpecial
                          ? const Color(0xFF34445A)
                          : const Color(0xFF1C293B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 23, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode
          ? const Color(0xFF101827)
          : const Color(0xFFF0F3F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('TAFI CALCULATOR',
            style: TextStyle(
                color: Color(0xFF65A5FF),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
        actions: [
          IconButton(
            onPressed: showHistory,
            icon: const Icon(Icons.history, color: Colors.blueAccent),
          ),
          IconButton(
            onPressed: () =>
                setState(() => darkMode = !darkMode),
            icon: Icon(
                darkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.blueAccent),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        expression.isEmpty ? '0' : expression,
                        style: TextStyle(
                            color: darkMode
                                ? Colors.white60
                                : Colors.black54,
                            fontSize: 27),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        result,
                        style: TextStyle(
                            color: darkMode
                                ? Colors.white
                                : Colors.black87,
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  for (final row in [
                    ['AC', '⌫', '%', '÷'],
                    ['7', '8', '9', '×'],
                    ['4', '5', '6', '−'],
                    ['1', '2', '3', '+'],
                    ['±', '0', '.', '='],
                  ])
                    Expanded(
                      child: Row(
                        children: row.map((key) {
                          if (key == '±') {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    if (expression.isNotEmpty) {
                                      expression =
                                          '-($expression)';
                                    }
                                  }),
                                  child: const Text('±',
                                      style: TextStyle(fontSize: 23)),
                                ),
                              ),
                            );
                          }
                          return keyButton(key);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text('DESIGNED BY TAFI GROUP',
                  style: TextStyle(
                      color: Colors.blueGrey,
                      letterSpacing: 2,
                      fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }
}

class MathParser {
  final String input;
  int position = 0;

  MathParser(this.input);

  double parse() {
    final value = expression();
    if (position != input.length) throw Exception();
    return value;
  }

  double expression() {
    double value = term();
    while (position < input.length) {
      final op = input[position];
      if (op != '+' && op != '−') break;
      position++;
      final right = term();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  }

  double term() {
    double value = factor();
    while (position < input.length) {
      final op = input[position];
      if (op != '×' && op != '÷' && op != '%') break;
      position++;
      final right = factor();
      if (op == '×') {
        value *= right;
      } else if (op == '÷') {
        if (right == 0) throw Exception();
        value /= right;
      } else {
        value %= right;
      }
    }
    return value;
  }

  double factor() {
    if (position >= input.length) throw Exception();

    if (input[position] == '-') {
      position++;
      return -factor();
    }

    if (input[position] == '(') {
      position++;
      final value = expression();
      if (position >= input.length || input[position] != ')') {
        throw Exception();
      }
      position++;
      return value;
    }

    final start = position;
    while (position < input.length &&
        '0123456789.'.contains(input[position])) {
      position++;
    }
    if (start == position) throw Exception();

    return double.parse(input.substring(start, position));
  }
}
