import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dataNotifier2Provider = ChangeNotifierProvider((ref) => DataNotifier2());

const int maxLength = 4000;

class DataNotifier2 extends ChangeNotifier {
  final list = List<List<double>>.generate(8, (i) => []);
  var powers = List<double>.generate(8, (i) => 0);
  var fftResults = List<List<FFTDataPoint>>.generate(8, (i) => []);

  bool randomData = true;

  void addData(
    List<List<double>> bandPassData,
    List<double> powers,
    List<List<FFTDataPoint>> fftResults,
  ) {
    for (var i = 0; i < 8; i++) {
      // Add new data to the end of each list[i]
      list[i].addAll(bandPassData[i]);

      // Trim the list only if its length exceeds maxLength
      if (list[i].length > maxLength) {
        list[i] = list[i].sublist(list[i].length - maxLength);
      }
    }

    // this.powers = powers;
    // this.fftResults = fftResults;

    randomData = !randomData;

    notifyListeners();
  }
}
