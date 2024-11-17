import 'dart:async';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dart_periphery/dart_periphery.dart';
import 'package:test_project/buffer.dart';
import 'package:test_project/data_notifier2.dart';
import 'package:test_project/file_storage.dart';
import 'package:test_project/process_data.dart';

import 'deice_data_process.dart';

part 'test2.g.dart';

@riverpod
ADS1299Reader2 dataListener2(Ref ref) {
  final dataNotifier = ref.read(dataNotifier2Provider);
  final fileStorage = ref.read(fileStorageProvider);
  return ADS1299Reader2(dataNotifier, fileStorage);
}

class ADS1299Reader2 {
  final DataNotifier2 dataNotifier;
  final FileStorage fileStorage;

  ADS1299Reader2(this.dataNotifier, this.fileStorage);

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
    _writeByte(spi, ch5set, 0x01);
    _writeByte(spi, ch6set, 0x01);
    _writeByte(spi, ch7set, 0x01);
    _writeByte(spi, ch8set, 0x01);

    _sendCommand(spi, rdatac); // RDATAC
    _sendCommand(spi, start); // START
  }

  // Future<void> startDataRead() async {
  //   const int buttonPin = 26;
  //   const int gpioChip = 4;
  //   // var gpioConfig = GPIOconfig.defaultValues();
  //   // gpioConfig.bias = GPIObias.gpioBiasPullDown;
  //   // final gpio = GPIO.advanced(buttonPin, gpioConfig, gpioChip);
  //   var gpio = GPIO(buttonPin, GPIOdirection.gpioDirIn, gpioChip);

  //   // rpi_gpio
  //   // RpiGpio gpio = await initialize_RpiGpio(spi: false);
  //   // const int buttonPin = 37;
  //   // final button = gpio.input(buttonPin);

  //   int testDRDY = 5;

  //   print('Rpigpio initialized');

  //   var spi = SPI(0, 0, SPImode.mode1, 600000);
  //   spi.setSPIbitsPerWord(8);
  //   spi.setSPIbitOrder(BitOrder.msbFirst); // ???

  //   _initializeADS1299(spi);

  //   print('Rpispi initialized');

  //   print("Data reading started.");

  //   var buffer = List<List<double>>.generate(8, (i) => []);

  //   var buttonState = false;

  //   // bandpass filter
  //   BandPassFilterService bandPassFilterService = BandPassFilterService();

  //   while (true) {
  //     buttonState = gpio.read();
  //     // rpi_gpio
  //     // buttonState = await button.value;
  //     // print('Button state: $buttonState');

  //     if (buttonState) {
  //       testDRDY = 10;
  //     } else if (testDRDY == 10) {
  //       testDRDY = 0;

  //       // Read 27 bytes from the SPI device
  //       final data = _readData(spi, 27);
  //       print(
  //           'Raw SPI Data: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

  //       // Process and scale the data to obtain voltage values
  //       final result = DeviceDataProcessorService.processRawDeviceData(data);
  //       for (var i = 0; i < result.length; i++) {
  //         final bandPassResult =
  //             bandPassFilterService.applyBandPassFilter(i, result[i]);
  //         buffer[i].add(bandPassResult);
  //       }

  //       if (buffer[0].length >= 250) {
  //         dataNotifier.addData(buffer);
  //         buffer = List<List<double>>.generate(8, (i) => []);
  //       }

  //       // if (buffer[0].length >= 250) {
  //       //   final bandPassResult = List<List<double>>.generate(8, (i) => []);
  //       //   for (var i = 0; i < 8; i++) {
  //       //     final bandPassData =
  //       //         bandPassFilterService.applyBandPassFilter(i, buffer[i]);
  //       //     bandPassResult[i] = bandPassData;
  //       //   }
  //       //   dataNotifier.addData(bandPassResult);
  //       //   buffer = List<List<double>>.generate(8, (i) => []);
  //       // }
  //       // await Future<void>.delayed(Duration(milliseconds: 1));
  //     }
  //   }
  // }

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

  Future<void> startDataReadIsolate() async {
    ReceivePort receivePort = ReceivePort();

    // !!new version!! /open

    final buffers =
        List<CircularBuffer>.generate(8, (_) => CircularBuffer(250));

    var rawDataBuffer = '';

    final bandPassFilterService = BandPassFilterService();
    double bandPassResult = 0;

    int counter = 0;
    // int channelCounter = 0;

    final dataToSend = List<List<double>>.generate(
      buffers.length,
      (i) => buffers[i].getData(),
    ).toList();

    // final bandPassFilterService = BandPassFilterService();

    // !!new version!! /close

    // Start the isolate
    await Isolate.spawn(dataAcquisitionIsolate, receivePort.sendPort);

    // Map<int, double> samplePerChannel = {};

    receivePort.listen((data) {
      if (data is List<int>) {
        rawDataBuffer += data.toString();

        final result = DeviceDataProcessorService.processRawDeviceData(data);
        for (var channelIndex = 0;
            channelIndex < result.length;
            channelIndex++) {
          // Apply the band-pass filter
          bandPassResult = bandPassFilterService.applyBandPassFilter(
            channelIndex,
            result[channelIndex],
          );

          buffers[channelIndex].add(bandPassResult);
        }

        counter++;

        if (counter >= 250) {
          fileStorage.checkAndSaveData(data: rawDataBuffer);
          rawDataBuffer = '';

          // move data from buffer to dataToSend
          for (var i = 0; i < buffers.length; i++) {
            dataToSend[i] = buffers[i].getData();
          }

          dataNotifier.addData(dataToSend);
          counter = 0;
        }
      }
    });

    // !! new version!! /open

    // Listen for data from the isolate
    // receivePort.listen((data) {
    //   if (data is Map) {
    //     final channelIndex = data['channelIndex'] as int;
    //     final bandPassData = data['sample'] as double;

    //     // samplePerChannel[channelIndex] = bandPassData;

    //     // if (samplePerChannel.length == 8) {
    //     //   // All channels have a sample, update state
    //     //   final samples = List<double>.generate(8, (i) => samplePerChannel[i]!);

    //     //   dataNotifier.updateData(samples);

    //     //   // Clear the map for the next set of samples
    //     //   samplePerChannel.clear();
    //     // }

    //     if (counter >= 250) {
    //       // move data from buffer to dataToSend
    //       for (var i = 0; i < buffers.length; i++) {
    //         dataToSend[i] = buffers[i].getData();
    //         // dataToSend[i] =
    //         //     repeatPatternWithAlignment(buffers[i].getData(), 10, 50, 20);

    //         // Apply band-pass filter
    //         // for (var j = 0; j < dataToSend[i].length; j++) {
    //         //   dataToSend[i][j] = bandPassFilterService.applyBandPassFilter(
    //         //     i,
    //         //     dataToSend[i][j],
    //         //   );
    //         // }
    //       }

    //       dataNotifier.addData(dataToSend);
    //       counter = 0;
    //     }

    //     channelCounter++;

    //     buffers[channelIndex].add(bandPassData);

    //     if (channelCounter == 8) {
    //       channelCounter = 0;
    //       counter++;
    //     }
    //   }
    // });

    // !! new version!! /close

    // !!previous veriosn!! /open

    // Listen for data from the isolate
    // receivePort.listen((data) {
    //   if (data is List<List<double>>) {
    //     dataNotifier.addData(data);
    //   }
    // });

    // !!previous veriosn!! /close
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

    // !!previous veriosn!! /open

    // final bandPassFilterService = BandPassFilterService();

    // final buffers =
    //     List<CircularBuffer>.generate(8, (_) => CircularBuffer(250));

    // !!previous veriosn!! /close

    bool testDRDY = false;
    bool buttonState = false;

    // !!previous veriosn!! /open

    // int counter = 0;

    // !!previous veriosn!! /close

    // !!new version!! /open

    // final bandPassFilterService = BandPassFilterService();
    // double bandPassResult = 0;

    // !!new version!! /close

    while (true) {
      buttonState = gpio.read();

      // final int timeout = 1000;
      // final gpio_res = gpio.poll(timeout);

      // if (gpio_res == GPIOpolling.success) {
      //   final edge = gpio.readEvent();

      if (buttonState) {
        testDRDY = true;
      }
      if (testDRDY && !buttonState) {
        testDRDY = false;

        // Read data from SPI
        final data = _readData(spi, 27);

        sendPort.send(data);

        // Process data
        // final result = DeviceDataProcessorService.processRawDeviceData(data);

        // !!new version!! /open

        // for (var i = 0; i < result.length; i++) {
        //   // Apply the band-pass filter
        //   bandPassResult = bandPassFilterService.applyBandPassFilter(
        //     i,
        //     result[i],
        //   );
        // sendPort.send({
        //   'channelIndex': i,
        //   'sample': bandPassResult,
        // });
        // }

        // !!new version!! /close

        // !!previous veriosn!! /open

        // for (var i = 0; i < result.length; i++) {
        //   final bandPassResult =
        //       bandPassFilterService.applyBandPassFilter(i, result[i]);
        //   buffers[i].add(bandPassResult);
        // }
        // counter++;

        // if (counter >= 250) {
        //   counter = 0;
        //   final dataToSend = buffers.map((buffer) => buffer.getData()).toList();
        //   sendPort.send(dataToSend);
        // }

        // !!previous veriosn!! /close
      }
    }
  }
}
