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
  final Butterworth _butterworth;

  BandPassFilterService() : _butterworth = Butterworth() {
    _initializeBandPassFilter();
  }

  void _initializeBandPassFilter() {
    double centerFreq = (_rightCutOffFreq + _leftCutOffFreq) / 2;
    double widthInFreq = _rightCutOffFreq - _leftCutOffFreq;
    _butterworth.bandPass(_order, samplingFrequency, centerFreq, widthInFreq);
  }

  List<double> applyBandPassFilter(List<double> data) {
    if (data.length < _bandPassMinProcessedLength) return [];

    List<double> filteredData = [];
    for (double sample in data) {
      filteredData.add(_butterworth.filter(sample));
    }
    return filteredData.length < _bandPassWarmUpLength
        ? []
        : filteredData.sublist(_bandPassWarmUpLength);
  }
}
