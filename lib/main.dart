import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:test_project/data_notifier2.dart';
import 'package:test_project/data_notifier3.dart';
import 'package:test_project/file_storage.dart';
import 'package:test_project/process_data.dart';
import 'package:test_project/recordingIndicatorNotifier.dart';
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
      home: EEGPage(),
    );
  }
}

/// Screen to listen data from EEG device
class EEGPage extends ConsumerWidget {
  /// Basic Constructor for EEGPage
  EEGPage({super.key});

  final _bandPassLowController = TextEditingController(text: '1');
  final _bandPassHighController = TextEditingController(text: '30');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataReciver = ref.read(dataListener2Provider);
    final fileStorage = ref.read(fileStorageProvider);
    final bandPassFilter = ref.read(bandPassFilterServiceProvider);
    final recordingIndicatorNotifier =
        ref.read(recordingIndicatorNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PiEEG'),
      ),
      body: SizedBox.expand(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: dataReciver.startDataReadIsolate,
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'Start',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                // const SizedBox(height: 10),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     Process.killPid(pid); // Close the app on Linux
                //   },
                //   icon: const Icon(Icons.close, color: Colors.white),
                //   label: const Text(
                //     'Close App',
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.red,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 10,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 25),
                Consumer(
                  builder: (context, ref, child) {
                    final recordingIndicator =
                        ref.watch(recordingIndicatorNotifierProvider);
                    return ElevatedButton.icon(
                      onPressed: () {
                        fileStorage.allowSave();
                        recordingIndicatorNotifier.startRecording();
                      },
                      icon: Icon(
                        Icons.save,
                        color: recordingIndicator ? Colors.green : null,
                      ),
                      label: const Text('Start saving'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    fileStorage.disallowSave();
                    recordingIndicatorNotifier.stopRecording();
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop saving'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Bandpass: '),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 60,
                      height: 50,
                      child: TextField(
                        controller: _bandPassLowController,
                        decoration: const InputDecoration(
                          labelText: 'Low',
                          border: OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 60,
                      height: 50,
                      child: TextField(
                        controller: _bandPassHighController,
                        decoration: const InputDecoration(
                          labelText: 'High',
                          border: OutlineInputBorder(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Update low cut-off frequency
                    try {
                      bandPassFilter.lowCutOffFreq =
                          double.parse(_bandPassLowController.text);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid low cut-off'),
                        ),
                      );
                      _bandPassLowController.text =
                          bandPassFilter.leftCutOffFreq.toString();
                    }
                    // Update high cut-off frequency
                    try {
                      bandPassFilter.highCutOffFreq =
                          double.parse(_bandPassHighController.text);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid high cut-off'),
                        ),
                      );
                      _bandPassHighController.text =
                          bandPassFilter.rightCutOffFreq.toString();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.medical_services_outlined),
                  label: const Text('EOG, ECG, EMG'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.memory),
                  label: const Text('Sensors board'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 1050,
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
    );
  }
}

class Chart extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final List<double> data;
  final List<double> secondData;
  final bool randomData;

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

  final double padding = 40;

  @override
  Widget build(BuildContext context) {
    double minY = -100;
    double maxY = 100;
    if (widget.data.isNotEmpty) {
      minY = widget.data.reduce(min) - padding;
      maxY = widget.data.reduce(max) + padding;
    }
    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: 450,
        height: 110,
        child: LineChart(
          duration: const Duration(milliseconds: 0),
          LineChartData(
            maxY: maxY,
            minY: minY,
            clipData: const FlClipData.vertical(),
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

/// Chart2
// ignore: must_be_immutable
class Chart2 extends ConsumerWidget {
  /// Basic Constructor for Chart2
  Chart2({
    required int channelIndex,
    super.key,
  })  : _channelIndex = channelIndex,
        _data = [];

  final int _channelIndex;
  final List<double> _data;
  double counter = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(dataNotifier3Provider);
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 15),
      child: SizedBox(
        width: 300,
        height: 75,
        child: SfCartesianChart(
          primaryYAxis: NumericAxis(
            minimum: -1000, // Set minimum based on your expected data range
            maximum: 1000, // Set maximum based on your expected data range
          ),
          series: <LineSeries<double, double>>[
            LineSeries<double, double>(
              onRendererCreated:
                  (ChartSeriesController<double, double> controller) {
                notifier.setUp(controller, _data, _channelIndex);
              },
              dataSource: _data,
              xValueMapper: (_, int index) {
                counter++;
                return counter;
              },
              yValueMapper: (double value, _) => value,
              animationDuration: 0,
            ),
          ],
        ),
      ),
    );
  }
}
