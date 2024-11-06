import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:test_project/data_notifier.dart';
import 'package:dart_periphery/dart_periphery.dart';

import 'deice_data_process.dart';

part 'test2.g.dart';

@riverpod
ADS1299Reader2 dataListener2(Ref ref) {
  final dataNotifier = ref.read(dataNitiiferProvider.notifier);
  return ADS1299Reader2(dataNotifier);
}

class ADS1299Reader2 {
  final DataNitiifer dataNotifier;

  ADS1299Reader2(this.dataNotifier);

  void _initializeADS1299(SPI spi) {
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
    _writeByte(spi, ch1set, 0x01);
    _writeByte(spi, ch2set, 0x01);
    _writeByte(spi, ch3set, 0x01);
    _writeByte(spi, ch4set, 0x01);
    _writeByte(spi, ch5set, 0x01);
    _writeByte(spi, ch6set, 0x01);
    _writeByte(spi, ch7set, 0x01);
    _writeByte(spi, ch8set, 0x01);

    _sendCommand(spi, rdatac); // RDATAC
    _sendCommand(spi, start); // START
  }

  Future<void> startDataRead() async {
    const int buttonPin = 26;
    const int gpioChip = 4;
    var gpioConfig = GPIOconfig.defaultValues();
    gpioConfig.bias = GPIObias.gpioBiasPullDown;
    final gpio = GPIO.advanced(buttonPin, gpioConfig, gpioChip);
    // var gpio = GPIO(buttonPin, GPIOdirection.gpioDirIn, gpioChip);

    // rpi_gpio
    // RpiGpio gpio = await initialize_RpiGpio(spi: false);
    // const int buttonPin = 37;
    // final button = gpio.input(buttonPin);

    int testDRDY = 5;

    print('Rpigpio initialized');

    var spi = SPI(0, 0, SPImode.mode1, 600000);
    spi.setSPIbitsPerWord(8);
    spi.setSPIbitOrder(BitOrder.msbFirst); // ???

    _initializeADS1299(spi);

    print('Rpispi initialized');

    print("Data reading started.");

    var buffer = List<List<double>>.filled(8, []);

    var buttonState = false;

    while (true) {
      buttonState = gpio.read();
      // rpi_gpio
      // buttonState = await button.value;
      print('Button state: $buttonState');

      if (buttonState) {
        testDRDY = 10;
      } else if (testDRDY == 10) {
        testDRDY = 0;

        // Read 27 bytes from the SPI device
        final data = _readData(spi, 27);

        // Process and scale the data to obtain voltage values
        final result = DeviceDataProcessorService.processRawDeviceData(data);
        for (var i = 0; i < result.length; i++) {
          buffer[i].add(result[i]);
        }

        if (buffer[0].length >= 250) {
          dataNotifier.addData(buffer);
          buffer = List<List<double>>.filled(8, []);
        }
      }

      await Future<void>.delayed(const Duration(microseconds: 10));
    }
  }

  void _sendCommand(SPI spi, int command) {
    final sendData = [command];
    spi.transfer(sendData, false);
  }

  void _writeByte(SPI spi, int register, int data) {
    final writeCommand = 0x40 | register;
    final sendData = [writeCommand, 0x00, data];
    spi.transfer(sendData, false);
  }

  List<int> _readData(SPI spi, int length) {
    return spi.transfer(List.filled(length, 0), false);
  }
}
