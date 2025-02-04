import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirjdart/butterworth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'process_data.g.dart';

@Riverpod(keepAlive: true)
BandPassFilterService bandPassFilterService(Ref ref) => BandPassFilterService();

const double samplingFrequency = 250;
const int numberOfChannels = 8;
const int _order = 5;

class BandPassFilterService {
  final List<Butterworth> _butterworths;
  double _leftCutOffFreq = 1;
  double _rightCutOffFreq = 30;

  BandPassFilterService()
      : _butterworths = List.generate(8, (_) => Butterworth()) {
    _initializeBandPassFilters();
  }

  double get leftCutOffFreq => _leftCutOffFreq;

  set lowCutOffFreq(double freq) {
    if (freq < 0 || freq >= _rightCutOffFreq) {
      throw Exception('Invalid low cut-off frequency');
    }
    _leftCutOffFreq = freq;
    _initializeBandPassFilters();
  }

  double get rightCutOffFreq => _rightCutOffFreq;

  set highCutOffFreq(double freq) {
    if (freq <= _leftCutOffFreq) {
      throw Exception('Invalid high cut-off frequency');
    }
    _rightCutOffFreq = freq;
    _initializeBandPassFilters();
  }

  void _initializeBandPassFilters() {
    double centerFreq = (_rightCutOffFreq + _leftCutOffFreq) / 2;
    double widthInFreq = _rightCutOffFreq - _leftCutOffFreq;
    for (var filter in _butterworths) {
      filter.bandPass(_order, samplingFrequency, centerFreq, widthInFreq);
    }
  }

  double applyBandPassFilter(int channelIndex, double data) {
    var filter = _butterworths[channelIndex];
    return filter.filter(data);
  }
}
