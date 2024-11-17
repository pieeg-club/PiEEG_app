import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// Setter for the allowSave property.
  set allowSave(bool value) {
    _allowSave = value;
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
        print("Data saved to file");
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
        print('File path: ${_file!.path}');
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
