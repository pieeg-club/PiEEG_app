import 'dart:math';
import 'package:flutter/material.dart';

class PowerDisplayWidget extends StatelessWidget {
  final List<double> powerValues;

  /// Expects exactly 8 power values between 0.0 and 1.0.
  const PowerDisplayWidget({
    Key? key,
    required this.powerValues,
  })  : assert(powerValues.length == 8,
            "Provide 8 power values for the electrodes."),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // CustomPaint lets us draw the head and electrodes exactly how we want.
    return CustomPaint(
      size: const Size(300, 300),
      painter: _PowerPainter(powerValues),
    );
  }
}

class _PowerPainter extends CustomPainter {
  final List<double> powerValues;

  _PowerPainter(this.powerValues);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final headRadius = min(size.width, size.height) / 2;

    // Draw the head circle
    final headPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawCircle(center, headRadius, headPaint);

    final electrodeDistance = headRadius * 0.6;
    final electrodeRadius = headRadius * 0.1;

    // Compute min and max from your actual power values
    final minValue = powerValues.reduce(min);
    final maxValue = powerValues.reduce(max);
    final range = maxValue - minValue;

    // Draw each electrode
    for (int i = 0; i < 8; i++) {
      double angle = (2 * pi * i / 8) - (pi / 2);
      final electrodeCenter = Offset(
        center.dx + electrodeDistance * cos(angle),
        center.dy + electrodeDistance * sin(angle),
      );

      // Normalize the power value to be between 0 and 1
      final normalizedValue = range > 0
          ? (powerValues[i] - minValue) / range
          : 0.5; // default in case all values are equal

      // Interpolate color: blue for low power, red for high power.
      final electrodeColor =
          Color.lerp(Colors.blue, Colors.red, normalizedValue)!;
      final electrodePaint = Paint()..color = electrodeColor;

      canvas.drawCircle(electrodeCenter, electrodeRadius, electrodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PowerPainter oldDelegate) {
    // Repaint if the power values have changed.
    return true;
  }
}
