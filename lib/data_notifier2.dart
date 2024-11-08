import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

class DataNotifier2 extends ChangeNotifier {
  final list = List<List<double>>.generate(8, (i) => []);

  void addData(List<List<double>> data) {
    for (var i = 0; i < 8; i++) {
      list[i] = [...list[i], ...data[i]];
      while (list[i].length > 1000) {
        list[i].removeAt(0);
      }
    }
    notifyListeners();
  }
}
