import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that displays a head (large circle) with 8 electrodes placed
/// at approximate 10-20 system positions:
///   0: Fp1
///   1: Fp2
///   2: T3
///   3: T4
///   4: C3
///   5: C4
///   6: O1
///   7: O2
///
/// [powerValues] can be any range. We do a min-max normalization
/// so the smallest value becomes fully blue and the largest becomes fully red.
class PowerDisplayWidget extends StatelessWidget {
  final List<double> powerValues;

  const PowerDisplayWidget({
    Key? key,
    required this.powerValues,
  })  : assert(powerValues.length == 8,
            "Provide exactly 8 power values for the electrodes."),
        super(key: key);

  @override
  Widget build(BuildContext context) {
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

    // Approximate positions for Fp1, Fp2, T3, T4, C3, C4, O1, O2
    // in normalized (x,y) coordinates relative to the center.
    // Multiply by headRadius to get actual screen positions.
    final List<Offset> electrodeOffsets = [
      const Offset(-0.35, -0.65), // Fp1 (top-left)
      const Offset(0.35, -0.65), // Fp2 (top-right)
      const Offset(-0.60, 0.00), // T3  (left)
      const Offset(0.60, 0.00), // T4  (right)
      const Offset(-0.30, 0.00), // C3  (mid-left)
      const Offset(0.30, 0.00), // C4  (mid-right)
      const Offset(-0.30, 0.60), // O1  (bottom-left)
      const Offset(0.30, 0.60), // O2  (bottom-right)
    ];

    // Electrode circle size (tweak as needed)
    final electrodeRadius = headRadius * 0.08;

    // Find the min & max in your powerValues for dynamic color scaling
    final minValue = powerValues.reduce(min);
    final maxValue = powerValues.reduce(max);
    final range = maxValue - minValue;

    // Draw each electrode
    for (int i = 0; i < 8; i++) {
      final offset = electrodeOffsets[i];
      final electrodeCenter = Offset(
        center.dx + offset.dx * headRadius,
        center.dy + offset.dy * headRadius,
      );

      // Normalize current value to [0..1]
      final normalizedValue = (range > 0)
          ? (powerValues[i] - minValue) / range
          : 0.5; // default if all values are equal

      // Map normalizedValue => color from Blue (low) to Red (high)
      final electrodeColor =
          Color.lerp(Colors.blue, Colors.red, normalizedValue)!;

      canvas.drawCircle(
        electrodeCenter,
        electrodeRadius,
        Paint()..color = electrodeColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PowerPainter oldDelegate) {
    return oldDelegate.powerValues != powerValues;
  }
}
