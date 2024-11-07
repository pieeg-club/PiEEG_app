import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_notifier.g.dart';

/// notifier that will update ui when new data is processed
@riverpod
class DataNitiifer extends _$DataNitiifer {
  @override
  List<List<double>> build() {
    return List<List<double>>.generate(8, (i) => []);
  }

  /// adds data to a current list
  // void addData(List<double> data1, List<double> data2) {
  //   final newState = <List<double>>[];
  //   for (var i = 0; i < 8; i++) {
  //     newState.add([]);
  //     newState[i] = [...state[i], data1[i]];
  //   }
  //   for (var i = 8; i < 16; i++) {
  //     newState.add([]);
  //     newState[i + 8] = [...state[i + 8], data2[i]];
  //   }
  //   state = newState;
  // }

  void addData(List<List<double>> data) {
    final voltData = <List<double>>[];
    for (var i = 0; i < 8; i++) {
      voltData.add([]);
      voltData[i] = [...state[i], ...data[i]];
      while (voltData[i].length > 1000) {
        voltData[i].removeAt(0);
      }
    }

    // final bandPassFilterService = ref.read(bandPassFilterServiceProvider);
    // final bandPassResuult = List<List<double>>.generate(8, (i) => []);
    // for (var i = 0; i < data.length; i++) {
    //   bandPassResuult[i] =
    //       bandPassFilterService.applyBandPassFilter(voltData[i]);
    // }

    state = voltData;
  }

  void addSamples(List<double> samples) {
    final newState = List<List<double>>.generate(8, (i) {
      final updatedChannelData = [...state[i], samples[i]];
      if (updatedChannelData.length > 1000) {
        updatedChannelData.removeAt(0);
      }
      return updatedChannelData;
    });

    state = newState;
  }
}
