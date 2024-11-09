import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

const int maxLength = 1000;

class DataNotifier2 extends ChangeNotifier {
  final list = List<List<double>>.generate(8, (i) => []);

  bool randomData = true;

  void addData(List<List<double>> data) {
    for (var i = 0; i < 8; i++) {
      // Add new data to the end of each list[i]
      list[i].addAll(data[i]);

      // Trim the list only if its length exceeds maxLength
      if (list[i].length > maxLength) {
        list[i] = list[i].sublist(list[i].length - maxLength);
      }
    }

    randomData = !randomData;

    notifyListeners();
  }

  Timer? _updateTimer;
  final List<List<double>> _pendingData = List.generate(8, (_) => []);

  void addSamples(List<double> samples) {
    for (var i = 0; i < 8; i++) {
      // Add new data to the end of each list[i]
      list[i].add(samples[i]);

      // Trim the list only if its length exceeds maxLength
      while (list[i].length > 1000) {
        list[i].removeAt(0);
      }
    }

    randomData = !randomData;

    notifyListeners();
  }

  List<ChartSeriesController?> controllers = List.generate(8, (_) => null);

  void setUp(
      ChartSeriesController conroller, List<double> data, int channelIndex) {
    controllers[channelIndex] = conroller;
    list[channelIndex] = data;
  }

  void updateData(List<double> data) {
    for (var i = 0; i < data.length; i++) {
      final controller = controllers[i]!;
      // var removedDataIndex = -1;
      list[i].add(data[i]);
      // if (list[i].length > maxLength) {
      //   list[i].removeAt(0);
      //   removedDataIndex = 0;
      // }
      controller.updateDataSource(
        addedDataIndex: list[i].length - 1,
        // removedDataIndex: removedDataIndex,
      );
    }
  }
}
