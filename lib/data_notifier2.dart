import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

class DataNotifier2 extends ChangeNotifier {
  var list = List<List<double>>.generate(8, (i) => []);

  void addData(List<List<double>> data) {
    final voltData = <List<double>>[];
    for (var i = 0; i < 8; i++) {
      voltData.add([]);
      voltData[i] = [...list[i], ...data[i]];
      while (voltData[i].length > 1000) {
        voltData[i].removeAt(0);
      }
    }
    list = voltData;
    notifyListeners();
  }
}
