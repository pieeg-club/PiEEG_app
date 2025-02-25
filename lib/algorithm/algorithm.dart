import 'package:PiEEG_app/algorithm/algorithm_result.dart';
import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';
import 'package:PiEEG_app/buffer.dart';
import 'package:PiEEG_app/deice_data_process.dart';
import 'package:PiEEG_app/process_data.dart';

/// Algorithm class
class Algorithm {
  /// Constructor
  Algorithm(
    this._bandPassFilterService,
    this._fastFourierTransformService,
  ) {
    _bandPassData = List<List<double>>.generate(
      _buffers.length,
      (i) => _buffers[i].getData(),
    ).toList();
  }

  final BandPassFilterService _bandPassFilterService;
  final FastFourierTransformService _fastFourierTransformService;
  final _buffers = List<CircularBuffer>.generate(8, (_) => CircularBuffer(250));
  late List<List<double>> _bandPassData;
  String _rawDataBuffer = '';
  double _bandPassResult = 0;
  int _counter = 0;

  /// Process the data
  void processData(
    List<int> data,
    Future<void> Function(String) saveFunction,
    void Function(AlgorithmResult) displayFunction,
  ) {
    _rawDataBuffer += data.toString();

    final result = DeviceDataProcessorService.processRawDeviceData(data);
    for (var channelIndex = 0; channelIndex < result.length; channelIndex++) {
      // Apply the band-pass filter
      _bandPassResult = _bandPassFilterService.applyBandPassFilter(
        channelIndex,
        result[channelIndex],
      );

      _buffers[channelIndex].add(_bandPassResult);
    }

    _counter++;

    if (_counter >= 250) {
      saveFunction(_rawDataBuffer);
      _rawDataBuffer = '';

      // move data from buffer to dataToSend
      for (var i = 0; i < _buffers.length; i++) {
        _bandPassData[i] = _buffers[i].getData();
      }

      final fftResults = <List<FFTDataPoint>>[];
      final powers = <double>[];
      for (var i = 0; i < _buffers.length; i++) {
        final fftResult =
            _fastFourierTransformService.applyFastFourierTransform(
          _bandPassData[i],
        );
        // fftResults.add(fftResult);
        final power =
            _fastFourierTransformService.calculatePowerPerUnitFrequency(
          fftDataPoints: fftResult,
          leftCutOffFreq: _bandPassFilterService.leftCutOffFreq,
          rightCutOffFreq: _bandPassFilterService.rightCutOffFreq,
        );
        powers.add(power);
      }

      final result = AlgorithmResult(
        bandPassResult: _bandPassData,
        powers: powers,
        fftResults: fftResults,
      );

      displayFunction(result);
      _counter = 0;
    }
  }
}
