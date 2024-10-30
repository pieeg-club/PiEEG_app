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
  void addData(List<double> data) {
    final newState = <List<double>>[];
    for (var i = 0; i < 8; i++) {
      newState.add([]);
      newState[i] = [...state[i], data[i]];
      if (newState[i].length > 2000) {
        newState[i].remove(0);
      }
    }
    state = newState;
  }
}
