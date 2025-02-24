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
    print(this.powerValues);
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
    // Center of the head circle
    final center = Offset(size.width / 2, size.height / 2);
    // Head radius is half the smallest dimension
    final headRadius = min(size.width, size.height) / 2;

    // Draw the head circle
    final headPaint = Paint()..color = Colors.grey.shade300;
    canvas.drawCircle(center, headRadius, headPaint);

    // Define parameters for electrode circles
    // Electrode centers will be evenly distributed along a smaller circle inside the head
    final electrodeDistance =
        headRadius * 0.6; // distance from center to each electrode
    final electrodeRadius = headRadius * 0.1; // radius of each electrode circle

    // Draw each electrode
    for (int i = 0; i < 8; i++) {
      // Calculate position around the circle using polar coordinates.
      // Start from the top (-pi/2) and distribute evenly.
      double angle = (2 * pi * i / 8) - (pi / 2);
      final electrodeCenter = Offset(
        center.dx + electrodeDistance * cos(angle),
        center.dy + electrodeDistance * sin(angle),
      );

      // Normalize the power value between 0.0 and 1.0.
      final value = powerValues[i].clamp(0.0, 1.0);
      // Interpolate color: blue for low power, red for high power.
      final electrodeColor = Color.lerp(Colors.blue, Colors.red, value)!;
      final electrodePaint = Paint()..color = electrodeColor;

      canvas.drawCircle(electrodeCenter, electrodeRadius, electrodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PowerPainter oldDelegate) {
    // Repaint if the power values have changed.
    return oldDelegate.powerValues != powerValues;
  }
}
