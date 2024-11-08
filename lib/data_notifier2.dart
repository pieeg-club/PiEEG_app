import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

class DataNotifier2 extends ChangeNotifier {
  final list = List<List<double>>.generate(8, (i) => []);

  bool update = false;

  void addData(List<List<double>> data) {
    for (var i = 0; i < 8; i++) {
      list[i].addAll(data[i]);
      while (list[i].length > 1000) {
        list[i].removeAt(0);
      }
    }
    print('DataNotifier2: ${list[0].length}');
    update = true;
    notifyListeners();
  }
}
