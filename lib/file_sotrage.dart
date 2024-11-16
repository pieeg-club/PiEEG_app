import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

class FileStorage {
  final Lock _lock = Lock();
  File? _file;

  /// Appends the provided data to the file.
  Future<void> saveData({
    required List<int> data,
  }) async {
    try {
      await _lock.synchronized(() async {
        final file = await _getFile();
        await file.writeAsString(data.toString(), mode: FileMode.append);
        // await file.writeAsBytes(data, mode: FileMode.append);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves a flushed file, ensuring all buffered data is written to disk.
  Future<File> getFlushedFile() async {
    try {
      return _lock.synchronized(() async {
        final file = await _getFile(flush: true);
        return file;
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes the file after ensuring all buffered data is written to disk.
  Future<void> deleteFileWithData() async {
    try {
      await _lock.synchronized(() async {
        final file = await _getFile(flush: true);
        if (!await file.exists()) return;
        await file.delete();
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to get the file,
  /// with an option to flush buffered data to disk.
  Future<File> _getFile({bool flush = false}) async {
    try {
      if (_file == null) {
        Directory appDirectory = await getApplicationDocumentsDirectory();
        // _file = File('${appDirectory!.path}/eeg_data.bin');
        _file = File('${appDirectory.path}/eeg_data.txt');
      }

      if (flush) {
        await _flushFile(_file!);
      }

      return _file!;
    } catch (e) {
      rethrow;
    }
  }

  /// Flushes buffered data to disk to ensure data integrity.
  Future<void> _flushFile(File file) async {
    try {
      RandomAccessFile randomAccessFile = await file.open();
      await randomAccessFile.flush();
      await randomAccessFile.close();
    } catch (e) {
      rethrow;
    }
  }
}
