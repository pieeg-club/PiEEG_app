import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';

/// AlgorithmResult class
class AlgorithmResult {
  /// AlgorithmResult constructor
  AlgorithmResult({
    required this.bandPassResult,
    required this.powers,
    required this.fftResults,
  });

  /// bandPassResult
  final List<List<double>> bandPassResult;

  /// fftResults
  final List<List<FFTDataPoint>> fftResults;

  /// power
  final List<double> powers;
}
