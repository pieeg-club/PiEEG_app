import 'dart:math';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fft.g.dart';

@Riverpod(keepAlive: true)
FastFourierTransformService fastFourierTransformService(Ref ref) =>
    FastFourierTransformService();

/// Sampling frequency
const double samplingFrequency = 250;

/// FastFourierTransform class
class FastFourierTransformService {
  /// Calculate the power
  double calculatePower(
    List<double> data,
    double leftCutOffFreq,
    double rightCutOffFreq,
  ) {
    final fftDataPoints = _applyFastFourierTransform(data);
    return _calculatePowerPerUnitFrequency(
      fftDataPoints: fftDataPoints,
      leftCutOffFreq: leftCutOffFreq,
      rightCutOffFreq: rightCutOffFreq,
    );
  }

  /// Calculate the power per unit frequency
  double _calculatePowerPerUnitFrequency({
    required List<FFTDataPoint> fftDataPoints,
    required double leftCutOffFreq,
    required double rightCutOffFreq,
  }) {
    var totalPower = 0.0;
    var numberOfDataPointsWithinRange = 0;
    for (final fftDataPoint in fftDataPoints) {
      if (fftDataPoint.frequency >= leftCutOffFreq &&
          fftDataPoint.frequency <= rightCutOffFreq) {
        totalPower += pow(fftDataPoint.amplitude, 2);
        numberOfDataPointsWithinRange++;
      }
    }
    if (numberOfDataPointsWithinRange == 0) return 0;
    final powerPerUnitFrequency = totalPower / numberOfDataPointsWithinRange;
    return powerPerUnitFrequency;
  }

  /// Apply Fast Fourier Transform
  List<FFTDataPoint> _applyFastFourierTransform(List<double> data) {
    // If there is no data, return an empty list
    if (data.isEmpty) return [];

    // Apply FFT and normalize
    var fourierTransform = FFT(data.length).realFft(data);
    final N = fourierTransform.length;
    final complexLength = Float64x2(N.toDouble(), N.toDouble());
    fourierTransform = Float64x2List.fromList(
        fourierTransform.map((x) => x / complexLength).toList());

    // Take the first half of the FFT result
    fourierTransform = fourierTransform.sublist(0, (N / 2).floor());

    // Create the results with amplitude and frequency
    final fastFourierTransformResults = _createResults(fourierTransform);

    return fastFourierTransformResults;
  }

  List<FFTDataPoint> _createResults(Float64x2List fourierTransform) {
    final fftResultLength = fourierTransform.length;
    final timePeriod = fftResultLength / samplingFrequency;

    final fastFourierTransformResults = List<FFTDataPoint>.generate(
      fftResultLength,
      (i) => FFTDataPoint(
        amplitude: _getMagnitude(fourierTransform[i].x, fourierTransform[i].y),
        frequency: i / timePeriod,
      ),
    );
    return fastFourierTransformResults;
  }

  double _getMagnitude(double realPart, double imaginaryPart) {
    return sqrt(realPart * realPart + imaginaryPart * imaginaryPart);
  }
}

/// FFTDataPoint class
class FFTDataPoint {
  /// Constructor
  FFTDataPoint({
    required this.amplitude,
    required this.frequency,
  });

  /// Amplitude
  final double amplitude;

  /// Frequency
  final double frequency;
}
