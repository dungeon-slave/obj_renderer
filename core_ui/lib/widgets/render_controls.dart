import 'package:core_ui/widgets/vertical_slider.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class RenderControls extends StatelessWidget {
  final void Function(double value) _scaleHandler;
  final void Function({double xValue, double yValue, double zValue})
      _translationHandler;
  final void Function({double xValue, double yValue, double zValue})
      _rotationHandler;

  final Vector3 _scale;
  final Vector3 _position;
  final Vector3 _rotation;

  const RenderControls({
    required void Function(double value) scaleHandler,
    required void Function({double xValue, double yValue, double zValue})
        translationHandler,
    required void Function({double xValue, double yValue, double zValue})
        rotationHandler,
    required Vector3 scale,
    required Vector3 position,
    required Vector3 rotation,
  })  : _scaleHandler = scaleHandler,
        _translationHandler = translationHandler,
        _rotationHandler = rotationHandler,
        _scale = scale,
        _position = position,
        _rotation = rotation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // TODO: create keyboard handling instead of sliders
        VerticalSlider(
          description: 'Scaling',
          slideHandler: _scaleHandler,
          slideValue: _scale.x,
          min: 1,
          max: 200,
        ),
        VerticalSlider(
          description: 'X translation',
          slideHandler: (double value) => _translationHandler(xValue: value),
          slideValue: _position.x,
          min: 0,
          max: 10,
        ),
        VerticalSlider(
          description: 'Y translation',
          slideHandler: (double value) => _translationHandler(yValue: value),
          slideValue: _position.y,
          min: -1000,
          max: 1000,
        ),
        VerticalSlider(
          description: 'Z translation',
          slideHandler: (double value) => _translationHandler(zValue: value),
          slideValue: _position.z,
          min: 0,
          max: 10,
        ),
        VerticalSlider(
          description: 'X rotation',
          slideHandler: (double value) => _rotationHandler(xValue: value),
          slideValue: _rotation.x.floorToDouble(),
          min: 0,
          max: 6.4,
        ),
        VerticalSlider(
          description: 'Y rotation',
          slideHandler: (double value) => _rotationHandler(yValue: value),
          slideValue: _rotation.y.floorToDouble(),
          min: 0,
          max: 6.4,
        ),
        VerticalSlider(
          description: 'Z rotation',
          slideHandler: (double value) => _rotationHandler(zValue: value),
          slideValue: _rotation.z.floorToDouble(),
          min: 0,
          max: 6.4,
        ),
      ],
    );
  }
}
