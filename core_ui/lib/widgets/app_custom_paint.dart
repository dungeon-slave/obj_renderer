import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:core_ui/widgets/vertical_slider.dart';
import 'package:data/data.dart';
import 'package:data/entities/render_object_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:flutter/material.dart';

class AppCustomPaint extends StatefulWidget {
  final List<RenderObjectEntity> _entities;

  const AppCustomPaint({
    required List<RenderObjectEntity> entities,
    super.key,
  }) : _entities = entities;

  @override
  _AppCustomPaintState createState() => _AppCustomPaintState();
}

class _AppCustomPaintState extends State<AppCustomPaint> {
  Vector3 _position = Vector3(0, 0, 0);
  Vector3 _scale = Vector3(1, 1, 1);
  Vector3 _rotation = Vector3(0, 0, 0);

  Map<int, List<Vector4>> _fetchVectors(Size size) {
    final Map<int, List<Vector4>> result = <int, List<Vector4>>{};

    for (RenderObjectEntity entity in widget._entities) {
      for (int j = 0; j < entity.faces.length; j++) {
        result.addAll(
          {
            j: VectorTransformation.transformToWorldSpace(
              vertices: entity.faces[j].vertices,
              translate: _position,
              scale: _scale,
              rotation: _rotation,
              size: size,
            ),
          },
        );
      }
    }

    return result;
  }

  void _scaleHandler(double value) {
    _scale = Vector3.all(value);
    setState(() {});
  }

  void _translationHandler({double? xValue, double? yValue, double? zValue}) {
    _position = Vector3(
      xValue ?? _position.x,
      yValue ?? _position.y,
      zValue ?? _position.z,
    );
    setState(() {});
  }

  void _rotationHandler({double? xValue, double? yValue, double? zValue}) {
    _rotation = Vector3(
      xValue ?? _rotation.x,
      yValue ?? _rotation.y,
      zValue ?? _rotation.z,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: <Row>[
          Row(
            children: <Widget>[
              CustomPaint(
                size: size * 0.5,
                painter: AppCustomPainter(
                  entities: _fetchVectors(Size(100, 100)),
                ),
              ),

              //TODO: We should separate controls and drawing
              VerticalSlider(
                description: 'Scaling',
                slideHandler: _scaleHandler,
                slideValue: _scale.x,
                min: 1,
                max: 2,
              ),
              VerticalSlider(
                description: 'X translation',
                slideHandler: (double value) =>
                    _translationHandler(xValue: value),
                slideValue: _position.x,
                min: 0,
                max: 10,
              ),
              VerticalSlider(
                description: 'Y translation',
                slideHandler: (double value) =>
                    _translationHandler(yValue: value),
                slideValue: _position.y,
                min: 0,
                max: 10,
              ),
              VerticalSlider(
                description: 'Z translation',
                slideHandler: (double value) =>
                    _translationHandler(zValue: value),
                slideValue: _position.z,
                min: 0,
                max: 10,
              ),
            ],
          ),
          Row(
            children: <VerticalSlider>[
              VerticalSlider(
                description: 'X rotation',
                slideHandler: (double value) => _rotationHandler(xValue: value),
                slideValue: _rotation.x,
                min: 0,
                //TODO: fix bug: when set maximum rotation program drops exception
                max: 3.14,
              ),
              VerticalSlider(
                description: 'Y rotation',
                slideHandler: (double value) => _rotationHandler(yValue: value),
                slideValue: _rotation.y,
                min: 0,
                max: 3.14,
              ),
              VerticalSlider(
                description: 'Z rotation',
                slideHandler: (double value) => _rotationHandler(zValue: value),
                slideValue: _rotation.z,
                min: 0,
                max: 3.14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
