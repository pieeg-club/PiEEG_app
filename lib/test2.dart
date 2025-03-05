import 'dart:async';
import 'dart:isolate';

import 'package:PiEEG_app/algorithm/algorithm.dart';
import 'package:PiEEG_app/algorithm/algorithm_result.dart';
import 'package:PiEEG_app/algorithm/processing_steps/fft.dart';
import 'package:PiEEG_app/data_notifier2.dart';
import 'package:PiEEG_app/file_storage.dart';
import 'package:PiEEG_app/process_data.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'test2.g.dart';

@riverpod
ADS1299Reader2 dataListener2(Ref ref) {
  final dataNotifier = ref.read(dataNotifier2Provider);
  final fileStorage = ref.read(fileStorageProvider);
  final bandPassFilter = ref.read(bandPassFilterServiceProvider);
  final fastFourierTransform = ref.read(fastFourierTransformServiceProvider);
  return ADS1299Reader2(
    dataNotifier,
    fileStorage,
    bandPassFilter,
    fastFourierTransform,
  );
}

class ADS1299Reader2 {
  final DataNotifier2 dataNotifier;
  final FileStorage fileStorage;
  final BandPassFilterService bandPassFilterService;
  final FastFourierTransformService fastFourierTransformService;

  ADS1299Reader2(this.dataNotifier, this.fileStorage,
      this.bandPassFilterService, this.fastFourierTransformService);

  static void _initializeADS1299(SPI spi) {
    const config1 = 0x01;
    const config2 = 0X02;
    const config3 = 0X03;

    const reset = 0x06;
    const stop = 0x0A;
    const start = 0x08;
    const sdatac = 0x11;
    const rdatac = 0x10;
    const wakeup = 0x02;

    const ch1set = 0x05;
    const ch2set = 0x06;
    const ch3set = 0x07;
    const ch4set = 0x08;
    const ch5set = 0x09;
    const ch6set = 0x0A;
    const ch7set = 0x0B;
    const ch8set = 0x0C;

    _sendCommand(spi, wakeup);
    _sendCommand(spi, stop);
    _sendCommand(spi, reset);
    _sendCommand(spi, sdatac);

    _writeByte(spi, 0x14, 0x80); // GPIO

    _writeByte(spi, config1, 0x96);
    _writeByte(spi, config2, 0xD4);
    _writeByte(spi, config3, 0xFF);
    _writeByte(spi, 0x04, 0x00);
    _writeByte(spi, 0x0D, 0x00);
    _writeByte(spi, 0x0E, 0x00);
    _writeByte(spi, 0x0F, 0x00);
    _writeByte(spi, 0x10, 0x00);
    _writeByte(spi, 0x11, 0x00);
    _writeByte(spi, 0x15, 0x20);

    _writeByte(spi, 0x17, 0x00);
    _writeByte(spi, ch1set, 0x00);
    _writeByte(spi, ch2set, 0x00);
    _writeByte(spi, ch3set, 0x00);
    _writeByte(spi, ch4set, 0x00);
    _writeByte(spi, ch5set, 0x00);
    _writeByte(spi, ch6set, 0x00);
    _writeByte(spi, ch7set, 0x00);
    _writeByte(spi, ch8set, 0x00);

    _sendCommand(spi, rdatac); // RDATAC
    _sendCommand(spi, start); // START
  }

  static void _sendCommand(SPI spi, int command) {
    final sendData = [command];
    spi.transfer(sendData, false);
  }

  static void _writeByte(SPI spi, int register, int data) {
    final writeCommand = 0x40 | register;
    final sendData = [writeCommand, 0x00, data];
    spi.transfer(sendData, false);
  }

  static List<int> _readData(SPI spi, int length) {
    return spi.transfer(List.filled(length, 0), false);
  }

  List<double> repeatPatternWithAlignment(
      List<double> waveData, int startIndex, int endIndex, int patternLength) {
    // Step 1: Extract the pattern segment before the corrupted section
    List<double> pattern = waveData.sublist(endIndex, endIndex + patternLength);

    // Step 2: Find the point in `pattern` that aligns best with the last valid point
    double lastValidPoint = waveData[startIndex - 1];
    int bestMatchIndex = 0;
    double minDifference = double.infinity;

    for (int i = 0; i < pattern.length; i++) {
      double difference = (pattern[i] - lastValidPoint).abs();
      if (difference < minDifference) {
        minDifference = difference;
        bestMatchIndex = i;
      }
    }

    // Step 3: Use the aligned pattern to fill in the corrupted segment
    int patternIndex = bestMatchIndex;
    for (int i = startIndex; i <= endIndex; i++) {
      waveData[i] = pattern[patternIndex];
      patternIndex =
          (patternIndex + 1) % pattern.length; // Wrap around the pattern
    }

    return waveData;
  }

  int? _lastValidValue;

  var _counter = 0;

  bool _theInputIsValide(List<int> input) {
    final msb = input[24];
    final middle = input[25];
    final lsb = input[26];

    final currentValue = _toSigned24Bit(msb, middle, lsb);

    if (_lastValidValue == null) {
      _lastValidValue = currentValue;
      return true;
    }

    final difference = (currentValue - _lastValidValue!).abs();
    if (difference > 3925) {
      print('Corrupted data detected _counter: $_counter');
      _counter++;
      return false;
    }

    _lastValidValue = currentValue;
    return true;
  }

  int _toSigned24Bit(int msb, int middle, int lsb) {
    // Combine the bytes into a 24-bit integer
    int combined = (msb << 16) | (middle << 8) | lsb;

    // Check the sign bit of the MSB
    if (msb & 0x80 != 0) {
      // If the sign bit is set, convert to negative 24-bit signed integer
      combined -= 1 << 24;
    }

    return combined;
  }

  Future<void> startDataReadIsolate() async {
    final receivePort = ReceivePort();

    final algorithm = Algorithm(
      bandPassFilterService,
      fastFourierTransformService,
    );

    // Initialize SPI and GPIO here
    final spi = SPI(0, 0, SPImode.mode1, 2000000);
    spi.setSPIbitsPerWord(8);
    spi.setSPIbitOrder(BitOrder.msbFirst);

    final gpio = GPIO(26, GPIOdirection.gpioDirIn, 4);
    // gpio.setGPIOedge(GPIOedge.gpioEdgeFalling);

    // Initialize ADS1299
    _initializeADS1299(spi);

    bool testDRDY = false;
    bool buttonState = false;

    while (true) {
      // await Future.delayed(Duration(milliseconds: 1));
      buttonState = gpio.read();

      if (buttonState) {
        testDRDY = true;
      }
      if (testDRDY && !buttonState) {
        testDRDY = false;

        // Read data from SPI
        final data = _readData(spi, 27);

        algorithm.processData(
          data,
          (String data) => fileStorage.checkAndSaveData(data: data),
          (AlgorithmResult algorithmResult) => dataNotifier.addData(
            algorithmResult.bandPassResult,
            algorithmResult.powers,
            algorithmResult.fftResults,
          ),
        );
      }
    }
  }

  static Future<void> dataAcquisitionIsolate(SendPort sendPort) async {
    // Initialize SPI and GPIO here
    final spi = SPI(0, 0, SPImode.mode1, 2000000);
    spi.setSPIbitsPerWord(8);
    spi.setSPIbitOrder(BitOrder.msbFirst);

    final gpio = GPIO(26, GPIOdirection.gpioDirIn, 4);
    // gpio.setGPIOedge(GPIOedge.gpioEdgeFalling);

    // Initialize ADS1299
    _initializeADS1299(spi);

    bool testDRDY = false;
    bool buttonState = false;

    while (true) {
      buttonState = gpio.read();

      if (buttonState) {
        testDRDY = true;
      }
      if (testDRDY && !buttonState) {
        testDRDY = false;

        // Read data from SPI
        final data = _readData(spi, 27);

        sendPort.send(data);
      }
    }
  }
}
