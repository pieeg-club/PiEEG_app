import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

part 'data_notifier3.g.dart';

@riverpod
DataNotifier3 dataNotifier3(Ref ref) => DataNotifier3();

class DataNotifier3 {
  List<List<double>> list = List.generate(8, (_) => []);
  List<ChartSeriesController<double, double>?> controllers =
      List.generate(8, (_) => null);

  void setUp(ChartSeriesController<double, double> conroller, List<double> data,
      int channelIndex) {
    controllers[channelIndex] = conroller;
    list[channelIndex] = data;
  }

  void updateData(List<double> data) {
    for (var i = 0; i < data.length; i++) {
      final controller = controllers[i]!;
      var removedDataIndex = -1;
      list[i].add(data[i]);
      if (list[i].length == 1000) {
        list[i].removeAt(0);
        removedDataIndex = -1;
      }
      controller.updateDataSource(
        addedDataIndex: list[i].length - 1,
        removedDataIndex: removedDataIndex,
      );
    }
  }
}
