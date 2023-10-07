import 'package:flutter/material.dart';

class VerticalSlider extends StatelessWidget {
  final void Function(double scaleFactor) scaleHandler;
  final double scaleFactor;
  final double min;
  final double max;

  const VerticalSlider(
    this.scaleHandler,
    this.scaleFactor,
    this.min,
    this.max,
  );

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 3,
      child: Material(
        child: Slider(
          min: min,
          max: max,
          value: scaleFactor,
          onChanged: (double value) => scaleHandler(value),
        ),
      ),
    );
  }
}
