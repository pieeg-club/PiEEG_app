import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_project/data_notifier.dart';
import 'package:test_project/test.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

/// My App
class MyApp extends StatelessWidget {
  /// Default constructor
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: EEGPage(),
    );
  }
}

/// Screen to listen data from EEG device
class EEGPage extends ConsumerWidget {
  /// Basic Constructor for EEGPage
  EEGPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataNotifier = ref.watch(dataNitiiferProvider);
    final dataReciver = ref.read(dataListenerProvider);
    final graphs = List<Widget>.generate(
      dataNotifier.length,
      (i) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Channel: $i'),
            ),
            Chart(
              padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
              spots: dataNotifier[i]
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
            ),
          ],
        );
      },
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: dataReciver.startDataRead,
              child: const Text('Start'),
            ),
            ElevatedButton(
              onPressed: () {
                exit(0); // Close the app on Linux
              },
              child: const Text('Close App'),
            ),
            SizedBox(
              width: 500,
              child: Wrap(
                children: graphs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  final EdgeInsetsGeometry _padding;
  final List<FlSpot> _spots;
  final List<FlSpot> _secondSpots;

  const Chart({
    Key? key,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    required List<FlSpot> spots,
    List<FlSpot>? secondSpots,
  })  : _padding = padding,
        _spots = spots,
        _secondSpots = secondSpots ?? const [],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _padding,
      child: SizedBox(
        width: 300,
        height: 75,
        child: LineChart(
          duration: const Duration(milliseconds: 0),
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                dotData: const FlDotData(show: false),
                barWidth: 0.5,
                isCurved: true,
                spots: _spots,
              ),
              if (_secondSpots.isNotEmpty)
                LineChartBarData(
                  dotData: const FlDotData(show: false),
                  barWidth: 0.5,
                  isCurved: true,
                  color: Colors.red,
                  spots: _secondSpots,
                ),
            ],
            lineTouchData: const LineTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}
