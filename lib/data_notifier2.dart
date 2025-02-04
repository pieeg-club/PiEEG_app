import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

const int maxLength = 4000;

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
}
