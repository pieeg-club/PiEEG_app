import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirjdart/butterworth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'process_data.g.dart';

@Riverpod(keepAlive: true)
BandPassFilterService bandPassFilterService(Ref ref) => BandPassFilterService();

const double samplingFrequency = 250;
const int numberOfChannels = 8;
const double _leftCutOffFreq = 1;
const double _rightCutOffFreq = 10;
const int _order = 5;
const int _bandPassMinProcessedLength = 900;
const int _bandPassWarmUpLength = 100;

class BandPassFilterService {
  final List<Butterworth> _butterworths;

  BandPassFilterService()
      : _butterworths = List.generate(8, (_) => Butterworth()) {
    _initializeBandPassFilters();
  }

  void _initializeBandPassFilters() {
    double centerFreq = (_rightCutOffFreq + _leftCutOffFreq) / 2;
    double widthInFreq = _rightCutOffFreq - _leftCutOffFreq;
    for (var filter in _butterworths) {
      filter.bandPass(_order, samplingFrequency, centerFreq, widthInFreq);
    }
  }

  List<double> applyBandPassFilter(int channelIndex, List<double> data) {
    var filter = _butterworths[channelIndex];
    List<double> filteredData = [];
    for (double sample in data) {
      filteredData.add(filter.filter(sample));
    }
    return filteredData;
  }
}
