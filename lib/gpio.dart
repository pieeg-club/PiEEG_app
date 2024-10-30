import 'package:rpi_gpio/rpi_gpio.dart';

/// class for interaction with device using gpio
class GPIO {
  RpiGpio? _gpio;

  /// returns a new Bpio if it was not created before otherwise
  /// returns curent value of _gpio
  Future<RpiGpio> get gpio async {
    _gpio ??= await initialize_RpiGpio();
    return _gpio!;
  }
}
