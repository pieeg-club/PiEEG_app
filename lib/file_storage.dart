import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

part 'file_storage.g.dart';

@Riverpod(keepAlive: true)
FileStorage fileStorage(Ref ref) => FileStorage();

class FileStorage {
  final Lock _lock = Lock();
  File? _file;
  bool _allowSave = false;

  /// Allows saving data to the file.
  void allowSave() {
    _allowSave = true;
  }

  /// Disallows saving data to the file.
  Future<void> disallowSave() async {
    _allowSave = false;
    if (_file != null) {
      await _flushFile(_file!);
      _file = null;
    }
  }

  /// Checks and Appends the provided data to the file.
  Future<void> checkAndSaveData({
    required String data,
  }) async {
    if (_allowSave) {
      await _saveData(data: data);
    }
  }

  /// Appends the provided data to the file.
  Future<void> _saveData({
    required String data,
  }) async {
    try {
      await _lock.synchronized(() async {
        final file = await _getFile();
        await file.writeAsString(data, mode: FileMode.append);
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

        // Format the current date and time
        final String timestamp =
            DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());

        // Generate the file name with date and time
        _file = File('${appDirectory.path}/eeg_data_$timestamp.txt');
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
