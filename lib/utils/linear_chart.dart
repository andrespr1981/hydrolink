import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphicWidget extends StatelessWidget {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final List<FlSpot> pointsList;

  static const List<Color> gradientColors = [
    Color.fromARGB(255, 230, 238, 252),
    Color(0xff02d39a),
  ];

  const GraphicWidget({
    super.key,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.pointsList,
  });

  @override
  Widget build(BuildContext content) => LineChart(
    LineChartData(
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
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
          spots: pointsList,
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

class ScalesWidget extends StatelessWidget {
  final List<FlSpot> pointsList;
  final List<Color> colors;
  const ScalesWidget({
    super.key,
    required this.colors,
    required this.pointsList,
  });

  @override
  Widget build(BuildContext content) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: LineChart(
      LineChartData(
        minX: 1,
        maxX: 14,
        minY: 0,
        maxY: 1,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: false,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(spots: pointsList, color: Colors.white),
        ],
      ),
    ),
  );
}
