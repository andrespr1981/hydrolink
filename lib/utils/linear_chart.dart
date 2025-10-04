import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LinearChartWidget extends StatelessWidget {
  static const List<Color> gradientColors = [
    Colors.blueAccent,
    Color(0xff02d39a),
  ];

  const LinearChartWidget({super.key});

  @override
  Widget build(BuildContext content) => LineChart(
    LineChartData(
      minX: 1,
      maxX: 7,
      minY: 1,
      maxY: 14,
      gridData: FlGridData(
        show: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(color: const Color(0xff37434d), strokeWidth: 1);
        },
        drawVerticalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(color: const Color(0xff37434d), strokeWidth: 1);
        },
      ),
      borderData: FlBorderData(show: true, border: Border.all()),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, 8),
            FlSpot(2, 6),
            FlSpot(3, 4),
            FlSpot(4, 5),
            FlSpot(5, 5),
            FlSpot(6, 9),
            FlSpot(7, 10),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(colors: gradientColors),
          ),
        ),
      ],
    ),
  );
}
