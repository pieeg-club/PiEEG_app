import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  final int chipSelectPin = 24;
  final int speed = 600000;
  final int mode = 1; // SPI Mode 1 for ADS1299

  final DataNitiifer dataNotifier;

  ADS1299Reader(this.dataNotifier);

  void _initializeADS1299() {
    _sendCommand(0x02); // WAKEUP
    _sendCommand(0x0A); // STOP
    _sendCommand(0x06); // RESET
    _sendCommand(0x11); // SDATAC

    _writeByte(0x14, 0x80); // GPIO

    // Write configuration registers
    _writeByte(0x01, 0x96); // CONFIG1
    _writeByte(0x02, 0xD4); // CONFIG2
    _writeByte(0x03, 0xFF); // CONFIG3

    const config1 = 0x01;
    const config2 = 0X02;
    const config3 = 0X03;

    const ch1set = 0x05;
    const ch2set = 0x06;
    const ch3set = 0x07;
    const ch4set = 0x08;
    const ch5set = 0x09;
    const ch6set = 0x0A;
    const ch7set = 0x0B;
    const ch8set = 0x0C;

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
    _sendCommand(0x10); // RDATAC
    _sendCommand(0x08); // START
  }

  void startDataRead() {
    spi = RpiSpi();
    _device = spi.device(0, chipSelectPin, speed, mode);
    _initializeADS1299();

    _sendCommand(0x10); // Set device to read mode
    _sendCommand(0x08); // Start data capture

    // Read and process data in a continuous loop
    Timer.periodic(const Duration(milliseconds: 4), (timer) {
      // Read 27 bytes from the SPI device, similar to the Python code
      final data = _readBytes(27);

      // Process and scale the data to obtain voltage values
      final result = DeviceDataProcessorService.processRawDeviceData(data);
      dataNotifier.addData(result);
    });

    print("Data reading started.");
  }

  // Commands and register configurations
  void _sendCommand(int command) {
    _device.send([command]);
  }

  void _writeByte(int register, int data) {
    final writeCommand = 0x40 | register;
    _device.send([writeCommand, data]);
  }

  Uint8List _readBytes(int length) {
    return _device.send(List<int>.filled(length, 0));
  }
}
