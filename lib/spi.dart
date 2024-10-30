import 'package:rpi_spi/rpi_spi.dart';
import 'package:rpi_spi/spi.dart';

/// class for interaction with device using spi
class SPI {
  RpiSpi? _spi;
  SpiDevice? _device;

  RpiSpi get spi {
    _spi ??= RpiSpi();
    return _spi!;
  }

  SpiDevice get device {
    _device ??= spi.device(0, 24, 600000, 1);
    return _device!;
  }

  void writeByte(RpiSpiDevice device, int register, int data) {
    final writeCommand =
        0x40 | register; // Use 0x40 as per ADS1299’s write command
    device.send([writeCommand, data]);
  }
}
