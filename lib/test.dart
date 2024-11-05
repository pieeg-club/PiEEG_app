import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rpi_gpio/gpio.dart';
import 'package:rpi_gpio/rpi_gpio.dart';
import 'package:rpi_spi/rpi_spi.dart';
import 'package:rpi_spi/spi.dart';
import 'package:test_project/data_notifier.dart';

import 'deice_data_process.dart';

part 'test.g.dart';

@riverpod
ADS1299Reader dataListener(Ref ref) {
  final dataNotifier = ref.read(dataNitiiferProvider.notifier);
  return ADS1299Reader(dataNotifier);
}

class ADS1299Reader {
  late RpiSpi spi;
  late SpiDevice _device;

  final DataNitiifer dataNotifier;

  ADS1299Reader(this.dataNotifier);

  void _initializeADS1299() {
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

    _sendCommand(wakeup);
    _sendCommand(stop);
    _sendCommand(reset);
    _sendCommand(sdatac);

    _writeByte(0x14, 0x80); // GPIO

    _writeByte(config1, 0x96);
    _writeByte(config2, 0xD4);
    _writeByte(config3, 0xFF);
    _writeByte(0x04, 0x00);
    _writeByte(0x0D, 0x00);
    _writeByte(0x0E, 0x00);
    _writeByte(0x0F, 0x00);
    _writeByte(0x10, 0x00);
    _writeByte(0x11, 0x00);
    _writeByte(0x15, 0x20);

    _writeByte(0x17, 0x00);
    _writeByte(ch1set, 0x00);
    _writeByte(ch2set, 0x00);
    _writeByte(ch3set, 0x00);
    _writeByte(ch4set, 0x00);
    _writeByte(ch5set, 0x00);
    _writeByte(ch6set, 0x00);
    _writeByte(ch7set, 0x00);
    _writeByte(ch8set, 0x00);

    _sendCommand(rdatac); // RDATAC
    _sendCommand(start); // START
  }

  Future<void> startDataRead() async {
    RpiGpio gpio = await initialize_RpiGpio(spi: false);
    const int buttonPin = 26;
    final button = gpio.input(buttonPin, Pull.up);
    int testDRDY = 5;

    print('Rpigpio initialized');

    spi = RpiSpi();
    _device = spi.device(0, 24, 600000, 1); // ???
    _initializeADS1299();

    print('Rpispi initialized');

    _sendCommand(0x10); // Set device to read mode
    _sendCommand(0x08); // Start data capture

    print("Data reading started.");

    await for (final buttonState in button.values) {
      print('Button state: $buttonState');
      if (buttonState) {
        testDRDY = 10;
      } else if (testDRDY == 10) {
        testDRDY = 0;

        // Read 27 bytes from the SPI device, similar to the Python code
        final data = _readBytes(27);

        // Process and scale the data to obtain voltage values
        final result = DeviceDataProcessorService.processRawDeviceData(data);
        dataNotifier.addData(result);
      }
    }

    // // Read and process data in a continuous loop
    // Timer.periodic(const Duration(milliseconds: 4), (timer) {

    // });
  }

  // Commands and register configurations
  void _sendCommand(int command) {
    _device.send([command]);
  }

  void _writeByte(int register, int data) {
    final writeCommand = 0x40 | register;
    _device.send([writeCommand, 0x00, data]);
  }

  Uint8List _readBytes(int length) {
    return _device.send(List<int>.filled(length, 0));
  }
}
