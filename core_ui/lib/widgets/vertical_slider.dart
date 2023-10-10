import 'package:core_ui/app_text_style.dart';
import 'package:flutter/material.dart';

class VerticalSlider extends StatelessWidget {
  final String _description;
  final void Function(double scaleFactor) _slideHandler;
  final double _slideValue;
  final double _min;
  final double _max;

  const VerticalSlider({
    required String description,
    required void Function(double) slideHandler,
    required double slideValue,
    required double min,
    required double max,
  })  : _max = max,
        _min = min,
        _slideValue = slideValue,
        _slideHandler = slideHandler,
        _description = description;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: <Widget>[
          RotatedBox(
            quarterTurns: 3,
            child: Material(
              color: Colors.blue,
              child: Slider(
                secondaryActiveColor: Colors.black,
                inactiveColor: Colors.black,
                activeColor: Colors.black,
                thumbColor: Colors.black,
                min: _min,
                max: _max,
                value: _slideValue,
                onChanged: _slideHandler,
              ),
            ),
          ),
          Text(
            _description,
            style: appTextStyle.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
