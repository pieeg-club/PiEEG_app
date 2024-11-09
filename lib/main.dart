import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:test_project/data_notifier.dart';
import 'package:test_project/data_notifier2.dart';
import 'package:test_project/data_notifier3.dart';
import 'package:test_project/test2.dart';

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
      home: EEGPage2(),
    );
  }
}

/// Screen to listen data from EEG device
class EEGPage extends ConsumerWidget {
  /// Basic Constructor for EEGPage
  EEGPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataReciver = ref.read(dataListener2Provider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: SizedBox.expand(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: dataReciver.startDataReadIsolate,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    exit(0); // Close the app on Linux
                  },
                  child: const Text('Close App'),
                ),
                SizedBox(
                  width: 700,
                  // child: Consumer(
                  //   builder: (context, ref, child) {
                  //     final dataNotifier = ref.watch(dataNitiiferProvider);
                  //     return Wrap(
                  //       children: List<Widget>.generate(
                  //         dataNotifier.length,
                  //         (i) {
                  //           return Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               Padding(
                  //                 padding: const EdgeInsets.only(left: 20),
                  //                 child: Text('Channel: $i'),
                  //               ),
                  //               Chart(
                  //                 padding: const EdgeInsets.only(
                  //                     left: 5, right: 5, top: 15),
                  //                 spots: dataNotifier[i]
                  //                     .asMap()
                  //                     .entries
                  //                     .map((e) =>
                  //                         FlSpot(e.key.toDouble(), e.value))
                  //                     .toList(),
                  //               ),
                  //             ],
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  child: Wrap(
                    children: List<Widget>.generate(
                      8,
                      (i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text('Channel: $i'),
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final dataNotifier =
                                    ref.watch(dataNotifier2Provider);

                                return Chart(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 15),
                                  data: dataNotifier.list[i],
                                  randomData: dataNotifier.randomData,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Chart extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final List<double> data;
  final List<double> secondData;
  final randomData;

  const Chart({
    Key? key,
    this.padding = EdgeInsets.zero,
    required this.data,
    required this.randomData,
    this.secondData = const [],
  }) : super(key: key);

  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  List<FlSpot> _spots = [];
  List<FlSpot> _secondSpots = [];

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.randomData != oldWidget.randomData) {
      _spots = widget.data
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }
    if (widget.secondData != oldWidget.secondData) {
      _secondSpots = widget.secondData
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
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
                isCurved: false,
                spots: _spots,
              ),
              if (_secondSpots.isNotEmpty)
                LineChartBarData(
                  dotData: const FlDotData(show: false),
                  barWidth: 0.5,
                  isCurved: false,
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

// class Chart extends StatelessWidget {
//   final EdgeInsetsGeometry _padding;
//   final List<FlSpot> _spots;
//   final List<FlSpot> _secondSpots;

//   const Chart({
//     Key? key,
//     EdgeInsetsGeometry padding = EdgeInsets.zero,
//     required List<FlSpot> spots,
//     List<FlSpot>? secondSpots,
//   })  : _padding = padding,
//         _spots = spots,
//         _secondSpots = secondSpots ?? const [],
//         super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: _padding,
//       child: SizedBox(
//         width: 300,
//         height: 75,
//         child: LineChart(
//           duration: const Duration(milliseconds: 0),
//           LineChartData(
//             lineBarsData: [
//               LineChartBarData(
//                 dotData: const FlDotData(show: false),
//                 barWidth: 0.5,
//                 isCurved: false,
//                 spots: _spots,
//               ),
//               if (_secondSpots.isNotEmpty)
//                 LineChartBarData(
//                   dotData: const FlDotData(show: false),
//                   barWidth: 0.5,
//                   isCurved: false,
//                   color: Colors.red,
//                   spots: _secondSpots,
//                 ),
//             ],
//             lineTouchData: const LineTouchData(enabled: false),
//             gridData: const FlGridData(show: false),
//             titlesData: const FlTitlesData(
//               rightTitles:
//                   AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

/// Screen to listen data from EEG device
class EEGPage2 extends ConsumerWidget {
  /// Basic Constructor for EEGPage
  EEGPage2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataReciver = ref.read(dataListener2Provider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: SizedBox.expand(
          child: Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: dataReciver.startDataReadIsolate,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () {
                    exit(0); // Close the app on Linux
                  },
                  child: const Text('Close App'),
                ),
                SizedBox(
                  width: 700,
                  child: Wrap(
                    children: List<Widget>.generate(
                      8,
                      (i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text('Channel: $i'),
                            ),
                            Chart2(
                              channelIndex: i,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Chart2 extends ConsumerWidget {
  /// Basic Constructor for Chart2
  Chart2({
    required int channelIndex,
    super.key,
  })  : _channelIndex = channelIndex,
        _data = [];

  int _channelIndex;
  List<double> _data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dataNotifier3Provider);
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
      child: SizedBox(
        width: 300,
        height: 75,
        child: SfCartesianChart(
          series: <LineSeries<double, double>>[
            LineSeries<double, double>(
              onRendererCreated:
                  (ChartSeriesController<double, double> controller) {
                notifier.setUp(controller, _data, _channelIndex);
              },
              dataSource: _data,
              xValueMapper: (_, int index) => index.toDouble(),
              yValueMapper: (double value, _) => value,
              animationDuration: 0,
            ),
          ],
        ),
      ),
    );
  }
}
