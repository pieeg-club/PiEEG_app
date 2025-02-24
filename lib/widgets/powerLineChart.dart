import 'dart:math';

import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PowerLineChart extends StatelessWidget {
  /// Expects exactly 8 lists of FFTDataPoint objects (one for each channel)
  final List<List<FFTDataPoint>> channelData;

  const PowerLineChart({
    Key? key,
    required this.channelData,
  })  : assert(channelData.length == 8, "Provide data for 8 channels."),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define distinct colors for each channel
    final List<Color> channelColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
      Colors.brown,
      Colors.pink,
    ];

    // Create a LineChartBarData object for each channel
    List<LineChartBarData> lineBarsData = [];
    for (int i = 0; i < channelData.length; i++) {
      final List<FFTDataPoint> channel = channelData[i];
      // Convert FFTDataPoint to FlSpot (x: frequency, y: amplitude)
      final List<FlSpot> spots = channel
          .map(
            (point) => FlSpot(
              point.frequency,
              pow(point.amplitude, 2).toDouble(),
            ),
          )
          .toList();

      lineBarsData.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: channelColors[i % channelColors.length],
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        barWidth: 2,
      ));
    }

    // Build the LineChart widget with proper axis settings
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 300,
        height: 110,
        child: LineChart(
          LineChartData(
            lineBarsData: lineBarsData,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    // Format frequency values as desired
                    return Text(value.toStringAsFixed(0));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    // Format amplitude values as desired
                    return Text(value.toStringAsFixed(0));
                  },
                ),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                left: BorderSide(),
                bottom: BorderSide(),
              ),
            ),
            // Optionally, set axis ranges if needed:
            // minX: 0, maxX: 100,
            // minY: 0, maxY: 100,
          ),
        ),
      ),
    );
  }
}
