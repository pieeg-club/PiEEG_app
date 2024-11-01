import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rpi_spi/rpi_spi.dart';
import 'package:rpi_spi/spi.dart';
import 'package:test_project/data_notifier.dart';

import 'deice_data_process.dart';

part 'test_2.g.dart';

@riverpod
ADS1299Reader dataListener2(Ref ref) {
  final dataNotifier = ref.read(dataNitiiferProvider.notifier);
  return ADS1299Reader(dataNotifier);
}

class ADS1299Reader {
  late RpiSpi spi;
  late SpiDevice _device1;
  late SpiDevice _device2;
  final int chipSelectPin1 = 24;
  final int chipSelectPin2 = 19;
  final int speed = 4000000;
  final int mode = 1; // SPI Mode 1 for ADS1299

  final DataNitiifer dataNotifier;

  ADS1299Reader(this.dataNotifier);

  Future<void> _initializeADS1299(RpiSpi spi) async {
    // Constants and commands
    const int config1 = 0x01;
    const int config2 = 0x02;
    const int config3 = 0x03;
    const int reset = 0x06;
    const int stop = 0x0A;
    const int start = 0x08;
    const int sdatac = 0x11;
    const int rdatac = 0x10;
    const int wakeup = 0x02;

    final List<int> channelSetRegisters = [
      0x05,
      0x06,
      0x07,
      0x08,
      0x09,
      0x0A,
      0x0B,
      0x0C
    ];

    // Setup SPI devices for both channels
    _device1 = spi.device(0, 0, speed, mode); // SPI device 1 on channel 0
    _device2 = spi.device(0, 1, speed, mode); // SPI device 2 on channel 1

    // Initialize both SPI devices
    _sendCommand(_device1, wakeup);
    _sendCommand(_device1, stop);
    _sendCommand(_device1, reset);
    _sendCommand(_device1, sdatac);
    _writeByte(_device1, config1, 0x96);
    _writeByte(_device1, config2, 0xD4);
    _writeByte(_device1, config3, 0xFF);

    for (var reg in channelSetRegisters) {
      _writeByte(_device1, reg, 0x00);
    }

    _sendCommand(_device1, rdatac);
    _sendCommand(_device1, start);

    // Configure the second SPI device similarly
    _sendCommand(_device2, wakeup);
    _sendCommand(_device2, stop);
    _sendCommand(_device2, reset);
    _sendCommand(_device2, sdatac);
    _writeByte(_device2, config1, 0x96);
    _writeByte(_device2, config2, 0xD4);
    _writeByte(_device2, config3, 0xFF);

    for (var reg in channelSetRegisters) {
      _writeByte(_device2, reg, 0x00);
    }

    _sendCommand(_device2, rdatac);
    _sendCommand(_device2, start);

    print("ADS1299 initialized for both SPI devices.");
  }

  Future<void> startDataRead() async {
    final spi = RpiSpi();
    await _initializeADS1299(spi);

    // Read and process data in a continuous loop for both devices
    Timer.periodic(const Duration(milliseconds: 4), (timer) async {
      // Read data from SPI device 1
      final data1 = _readBytes(_device1, 27);

      // Process and scale data for device 1
      final result1 = DeviceDataProcessorService.processRawDeviceData(data1);

      // Set chip select line for device 2

      // Read data from SPI device 2
      final data2 = _readBytes(_device2, 27);

      // Process and scale data for device 2
      final result2 = DeviceDataProcessorService.processRawDeviceData(data2);
      dataNotifier.addData(result1, result2);
    });

    print("Data reading started for both SPI devices.");
  }

  // Send a command to a specified device
  void _sendCommand(SpiDevice device, int command) {
    device.send([command]);
  }

  // Write a byte to a register on a specified device
  void _writeByte(SpiDevice device, int register, int data) {
    final writeCommand = 0x40 | register;
    device.send([writeCommand, data]);
  }

  // Read a specific number of bytes from a specified device
  Uint8List _readBytes(SpiDevice device, int length) {
    return device.send(List<int>.filled(length, 0));
  }
}
