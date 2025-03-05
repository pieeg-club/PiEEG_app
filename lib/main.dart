import 'dart:math';

import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';
import 'package:PiEEG_app/data_notifier2.dart';
import 'package:PiEEG_app/widgets/powerDisplayWidget.dart';
import 'package:PiEEG_app/widgets/powerLineChart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiEEG_app/file_storage.dart';
import 'package:PiEEG_app/process_data.dart';
import 'package:PiEEG_app/recordingIndicatorNotifier.dart';
import 'package:PiEEG_app/test2.dart';

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

class EEGPage extends StatefulWidget {
  const EEGPage({Key? key}) : super(key: key);

  @override
  _EEGPageState createState() => _EEGPageState();
}

/// Screen to listen data from EEG device
class _EEGPageState extends State<EEGPage> {
  /// Basic Constructor for EEGPage

  final _bandPassLowController = TextEditingController(text: '1');
  final _bandPassHighController = TextEditingController(text: '30');

  // final list = List<List<double>>.generate(8, (i) => []);

  final _spots = List<List<FlSpot>>.generate(
    8,
    (i) => [],
  );

  bool randomData = true;

  void addData(
    List<List<FlSpot>> newspots,
  ) {
    for (var i = 0; i < 8; i++) {
      // Add new data to the end of each list[i]
      _spots[i].addAll(newspots[i]);

      // Trim the list only if its length exceeds maxLength
      if (_spots[i].length > maxLength) {
        _spots[i] = _spots[i].sublist(_spots[i].length - maxLength);
      }
    }

    randomData = !randomData;

    setState(() {});
  }

  late ADS1299Reader2 dataListener;
  late DataNotifier2 dataNotifier;
  late FileStorage fileStorage;
  late BandPassFilterService bandPassFilterService;
  late FastFourierTransformService fastFourierTransformService;

  @override
  void initState() {
    dataNotifier = DataNotifier2();
    fileStorage = FileStorage();
    bandPassFilterService = BandPassFilterService();
    fastFourierTransformService = FastFourierTransformService();
    dataListener = ADS1299Reader2(
      dataNotifier,
      fileStorage,
      bandPassFilterService,
      fastFourierTransformService,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final dataReciver = ref.read(dataListener2Provider);
    // final fileStorage = ref.read(fileStorageProvider);
    // final bandPassFilter = ref.read(bandPassFilterServiceProvider);
    // final recordingIndicatorNotifier =
    //     ref.read(recordingIndicatorNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PiEEG'),
      ),
      body: SizedBox.expand(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          dataListener.startDataReadIsolate(addData),
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
                    const SizedBox(height: 25),
                    Consumer(
                      builder: (context, ref, child) {
                        final recordingIndicator =
                            ref.watch(recordingIndicatorNotifierProvider);
                        return ElevatedButton.icon(
                          onPressed: () {
                            fileStorage.allowSave();
                            // recordingIndicatorNotifier.startRecording();
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
                        // recordingIndicatorNotifier.stopRecording();
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
                          bandPassFilterService.lowCutOffFreq =
                              double.parse(_bandPassLowController.text);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid low cut-off'),
                            ),
                          );
                          _bandPassLowController.text =
                              bandPassFilterService.leftCutOffFreq.toString();
                        }
                        // Update high cut-off frequency
                        try {
                          bandPassFilterService.highCutOffFreq =
                              double.parse(_bandPassHighController.text);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid high cut-off'),
                            ),
                          );
                          _bandPassHighController.text =
                              bandPassFilterService.rightCutOffFreq.toString();
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
                  ],
                ),
                SizedBox(
                  width: 800,
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
                            Chart(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 15),
                              data: _spots[i],
                              randomData: randomData,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Consumer(
            //   builder: (context, ref, child) {
            //     final dataNotifier = ref.watch(dataNotifier2Provider);

            //     return Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         PowerDisplayWidget(powerValues: dataNotifier.powers),
            //         // PowerLineChart(channelData: dataNotifier.fftResults),
            //       ],
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class Chart extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final List<FlSpot> data;
  final bool randomData;

  const Chart({
    Key? key,
    this.padding = EdgeInsets.zero,
    required this.data,
    required this.randomData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double minY = -200;
    double maxY = 200;

    return Padding(
      padding: padding,
      child: SizedBox(
        width: 180,
        height: 60,
        child: LineChart(
          duration: const Duration(milliseconds: 0),
          LineChartData(
            clipData: const FlClipData.vertical(),
            lineBarsData: [
              LineChartBarData(
                dotData: const FlDotData(show: false),
                barWidth: 0.5,
                isCurved: false,
                spots: data,
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
