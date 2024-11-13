import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_spi/rpi_spi.dart';
import 'package:rpi_spi/spi.dart';
import 'package:test_project/buffer.dart';
import 'package:test_project/data_notifier2.dart';
import 'package:test_project/process_data.dart';

import 'deice_data_process.dart';

part 'test.g.dart';

@riverpod
ADS1299Reader dataListener(Ref ref) {
  final dataNotifier = ref.read(dataNotifier2Provider.notifier);
  return ADS1299Reader(dataNotifier);
}

class ADS1299Reader {
  late RpiSpi spi;
  late SpiDevice _device;

  final DataNotifier2 dataNotifier;

  ADS1299Reader(this.dataNotifier);

  static void _initializeADS1299(SpiDevice device) {
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

    _sendCommand(device, wakeup);
    _sendCommand(device, stop);
    _sendCommand(device, reset);
    _sendCommand(device, sdatac);

    _writeByte(device, 0x14, 0x80); // GPIO

    _writeByte(device, config1, 0x96);
    _writeByte(device, config2, 0xD4);
    _writeByte(device, config3, 0xFF);
    _writeByte(device, 0x04, 0x00);
    _writeByte(device, 0x0D, 0x00);
    _writeByte(device, 0x0E, 0x00);
    _writeByte(device, 0x0F, 0x00);
    _writeByte(device, 0x10, 0x00);
    _writeByte(device, 0x11, 0x00);
    _writeByte(device, 0x15, 0x20);

    _writeByte(device, 0x17, 0x00);
    _writeByte(device, ch1set, 0x00);
    _writeByte(device, ch2set, 0x00);
    _writeByte(device, ch3set, 0x00);
    _writeByte(device, ch4set, 0x00);
    _writeByte(device, ch5set, 0x00);
    _writeByte(device, ch6set, 0x00);
    _writeByte(device, ch7set, 0x00);
    _writeByte(device, ch8set, 0x00);

    _sendCommand(device, rdatac); // RDATAC
    _sendCommand(device, start); // START
  }

  Future<void> startDataRead() async {
    RpiGpio gpio = await initialize_RpiGpio(spi: false);
    const int buttonPin = 37;
    final button = gpio.input(buttonPin);
    int testDRDY = 5;

    print('Rpigpio initialized');

    spi = RpiSpi();
    _device = spi.device(0, 24, 2000000, 1);
    _initializeADS1299(_device);

    print('Rpispi initialized');

    print("Data reading started.");

    // await for (final buttonState in button.allValues) {
    //   print('Button state: $buttonState');
    //   if (buttonState) {
    //     testDRDY = 10;
    //   } else if (testDRDY == 10) {
    //     testDRDY = 0;

    //     // Read 27 bytes from the SPI device, similar to the Python code
    //     final data = _readBytes(27);

    //     // Process and scale the data to obtain voltage values
    //     final result = DeviceDataProcessorService.processRawDeviceData(data);
    //     dataNotifier.addData(result);
    //   }
    // }

    var buffer = List<List<double>>.generate(8, (i) => []);

    bool buttonState = false;

    // bandpass filter
    BandPassFilterService bandPassFilterService = BandPassFilterService();

    while (true) {
      buttonState = await button.value;
      // print('Button state: $buttonState');
      if (buttonState) {
        testDRDY = 10;
      }
      if (testDRDY == 10 && !buttonState) {
        testDRDY = 0;

        // Read 27 bytes from the SPI device
        final data = _readBytes(_device, 27);
        print(
            'Raw SPI Data: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

        // Process and scale the data to obtain voltage values
        final result = DeviceDataProcessorService.processRawDeviceData(data);
        for (var i = 0; i < result.length; i++) {
          final bandPassResult =
              bandPassFilterService.applyBandPassFilter(i, result[i]);
          buffer[i].add(bandPassResult);
        }

        if (buffer[0].length >= 250) {
          dataNotifier.addData(buffer);
          buffer = List<List<double>>.generate(8, (i) => []);
        }

        // if (buffer[0].length >= 250) {
        //   final bandPassResult = List<List<double>>.generate(8, (i) => []);
        //   for (var i = 0; i < 8; i++) {
        //     final bandPassData =
        //         bandPassFilterService.applyBandPassFilter(i, buffer[i]);
        //     bandPassResult[i] = bandPassData;
        //   }
        //   dataNotifier.addData(bandPassResult);
        //   buffer = List<List<double>>.generate(8, (i) => []);
        // }
      }
      // await Future<void>.delayed(const Duration(microseconds: 10));
    }
  }

  // Commands and register configurations
  static void _sendCommand(SpiDevice device, int command) {
    device.send([command]);
  }

  static void _writeByte(SpiDevice device, int register, int data) {
    final writeCommand = 0x40 | register;
    device.send([writeCommand, 0x00, data]);
  }

  static Uint8List _readBytes(SpiDevice device, int length) {
    return device.send(List<int>.filled(length, 0));
  }

  // Future<void> startDataReadIsolate() async {
  //   ReceivePort receivePort = ReceivePort();

  //   // Start the isolate
  //   await Isolate.spawn(dataAcquisitionIsolate, receivePort.sendPort);

  //   // Listen for data from the isolate
  //   receivePort.listen((data) {
  //     if (data is List<List<double>>) {
  //       dataNotifier.addData(data);
  //     }
  //   });
  // }

  // static Future<void> dataAcquisitionIsolate(SendPort sendPort) async {
  //   // Initialize SPI and GPIO here
  // RpiGpio gpio = await initialize_RpiGpio(spi: false);
  // const int buttonPin = 37;
  // final button = gpio.input(buttonPin);
  // int testDRDY = 5;

  // final spi = RpiSpi();
  // final device = spi.device(0, 24, 1200000, 1);

  //   // Initialize ADS1299
  //   _initializeADS1299(device);

  //   final bandPassFilterService = BandPassFilterService();

  //   final buffers =
  //       List<CircularBuffer>.generate(8, (_) => CircularBuffer(250));

  //   bool buttonState = false;

  //   int counter = 0;

  //   while (true) {
  //     buttonState = await button.value;
  //     // print('Button state: $buttonState');
  //     if (buttonState) {
  //       testDRDY = 10;
  //     }
  //     if (testDRDY == 10 && !buttonState) {
  //       testDRDY = 0;

  //       // Read 27 bytes from the SPI device
  //       final data = _readBytes(device, 27);

  //       // Process data
  //       final result = DeviceDataProcessorService.processRawDeviceData(data);

  //       for (var i = 0; i < result.length; i++) {
  //         final bandPassResult =
  //             bandPassFilterService.applyBandPassFilter(i, result[i]);
  //         buffers[i].add(bandPassResult);
  //       }
  //       counter++;

  //       if (counter >= 250) {
  //         counter = 0;
  //         final dataToSend = buffers.map((buffer) => buffer.getData()).toList();
  //         sendPort.send(dataToSend);
  //       }
  //     }
  //   }
  // }

  Future<void> startDataReadIsolate() async {
    ReceivePort receivePort = ReceivePort();

    // !!new version!! /open

    final buffers =
        List<CircularBuffer>.generate(8, (_) => CircularBuffer(250));

    int counter = 0;
    int channelCounter = 0;

    final dataToSend = List<List<double>>.generate(
      buffers.length,
      (i) => buffers[i].getData(),
    ).toList();

    // Start the isolate
    await Isolate.spawn(dataAcquisitionIsolate, receivePort.sendPort);

    // Listen for data from the isolate
    receivePort.listen((data) {
      if (data is Map) {
        final channelIndex = data['channelIndex'] as int;
        final bandPassData = data['sample'] as double;

        if (counter >= 250) {
          // move data from buffer to dataToSend
          for (var i = 0; i < buffers.length; i++) {
            dataToSend[i] = buffers[i].getData();
          }

          dataNotifier.addData(dataToSend);
          counter = 0;
        }

        channelCounter++;

        buffers[channelIndex].add(bandPassData);

        if (channelCounter == 8) {
          channelCounter = 0;
          counter++;
        }
      }
    });
  }

  static Future<void> dataAcquisitionIsolate(SendPort sendPort) async {
    // Initialize SPI and GPIO here
    final gpio = await initialize_RpiGpio(spi: false);
    const int buttonPin = 37;
    final button = gpio.input(buttonPin);

    final spi = RpiSpi();
    final device = spi.device(0, 24, 1200000, 1);

    // Initialize ADS1299
    _initializeADS1299(device);

    bool testDRDY = false;
    bool buttonState = false;

    // final bandPassFilterService = BandPassFilterService();
    // double bandPassResult = 0;

    while (true) {
      buttonState = await button.value;

      if (buttonState) {
        testDRDY = true;
      } else if (testDRDY) {
        testDRDY = false;

        // Read data from SPI
        final data = _readBytes(device, 27);

        // Process data
        final result = DeviceDataProcessorService.processRawDeviceData(data);

        // !!new version!! /open

        for (var i = 0; i < result.length; i++) {
          // Apply the band-pass filter
          // bandPassResult = bandPassFilterService.applyBandPassFilter(
          //   i,
          //   result[i],
          // );
          sendPort.send({
            'channelIndex': i,
            'sample': result[i],
          });
        }
      }
    }
  }
}
