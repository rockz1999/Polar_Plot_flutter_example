import 'package:flutter/material.dart';
import 'package:polar_plot_example/polar_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POLAR PLOT',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.grey[200],
        shadowColor: const Color(0xff9a9c9a),
        title: const Text(
          'POLAR  PLOT',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            letterSpacing: 2.5,
          ),
        ),
      ),
      body: Center(
        child: CustomPaint(
          painter: const PolarChartPainter(
              circleDivisions: const [10, 25, 50, 100],
              labels: const ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
              dataPoints: const [
                [43, 74, 21, 67, 78, 67, 88],
                [89, 45, 67, 34, 45, 80, 34],
              ],
              borderColor: const Color(0xff9a9c9a),
              circleDivisionsColor: Color(0xff9a9c9a),
              dataGraphColors: const [Color(0xffd6c315), Colors.blueAccent]),
          size: Size(
            MediaQuery.of(context).size.width * 0.8,
            MediaQuery.of(context).size.width * 0.8,
          ),
        ),
      ),
    );
  }
}
