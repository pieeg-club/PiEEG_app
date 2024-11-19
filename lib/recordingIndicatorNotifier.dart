import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recordingIndicatorNotifier.g.dart';

@riverpod
class RecordingIndicatorNotifier extends _$RecordingIndicatorNotifier {
  @override
  bool build() {
    return false;
  }

  void startRecording() {
    state = true;
  }

  void stopRecording() {
    state = false;
  }
}
