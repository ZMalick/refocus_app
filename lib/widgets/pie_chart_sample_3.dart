// ReFocus App
// Pie Chart Details
// Zaid Malick

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:refocus_app/services/app_data.dart';
import 'package:provider/provider.dart';

class PieChartSample3 extends StatefulWidget {
  const PieChartSample3({super.key});

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State {
  int touchedIndex = 0;

  final List<Color> customColors = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.orange,
  Colors.purple,
];

  @override
Widget build(BuildContext context) {
  return Consumer<AppData>(
    builder: (context, appData, child) {
      final topApps = appData.top5Apps;
      final totalTime = topApps.fold<double>(
          0, (sum, app) => sum + app.screenTimeUsed.inMinutes.toDouble());

      // Make sure touchedIndex is valid
      if (touchedIndex >= topApps.length) {
        touchedIndex = -1;
      }
      return AspectRatio(
        aspectRatio: 1.3,
        child: PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      response == null ||
                      response.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = response.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
            sections: List.generate(topApps.length, (i) {
              final app = topApps[i];
              final isTouched = i == touchedIndex;
              final fontSize = isTouched ? 20.0 : 16.0;
              final radius = isTouched ? 110.0 : 100.0;
              final value = app.screenTimeUsed.inMinutes.toDouble();
              final percentage =
                  totalTime == 0 ? 0 : (value / totalTime * 100);

              return PieChartSectionData(
                color: customColors[i % customColors.length],
                value: value,
                title: '${percentage.toStringAsFixed(0)}%',
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                badgeWidget: _Badge(
                  iconBytes: app.appIcon, // Uint8List from AppData
                  size: isTouched ? 55 : 40,
                  borderColor: Colors.black,
                ),
                badgePositionPercentageOffset: .98,
              );
            }),
          ),
        ),
      );
    },
  );
}
}

class _Badge extends StatelessWidget {
  final ImageProvider iconBytes;
  final double size;
  final Color borderColor;

  const _Badge({
    required this.iconBytes,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: Image(
          image: iconBytes,
        ), // <-- works like SelectApp
      ),
    );
  }
}