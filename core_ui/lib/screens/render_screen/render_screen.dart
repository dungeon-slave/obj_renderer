import 'package:core_ui/app_colors.dart';
import 'package:core_ui/widgets/app_button.dart';
import 'package:core_ui/widgets/app_custom_paint.dart';
import 'package:core_ui/widgets/render_controls.dart';
import 'package:data/data.dart';
import 'package:data/entities/face_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:flutter/material.dart';

class RenderScreen extends StatefulWidget {
  final List<FaceEntity> _defaultFaces;

  const RenderScreen({
    required List<FaceEntity> defaultFaces,
    super.key,
  }) : _defaultFaces = defaultFaces;

  @override
  _RenderScreenState createState() => _RenderScreenState();
}

class _RenderScreenState extends State<RenderScreen> {
  Vector3 _position = Vector3(0, 0, 0);
  Vector3 _scale = Vector3(1, 1, 1);
  Vector3 _rotation = Vector3(0, 0, 0);
  Size _painterSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backGroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          AppCustomPaint(
            entities: _fetchVectors(
              _painterSize,
              widget._defaultFaces,
            ),
            setSize: _setSize,
          ),
          RenderControls(
            scaleHandler: _scaleHandler,
            translationHandler: _translationHandler,
            rotationHandler: _rotationHandler,
            scale: _scale,
            position: _position,
            rotation: _rotation,
          ),
          AppButton(
            text: 'Back to picking',
            handler: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }

  void _setSize(Size size) {
    _painterSize = size;
    setState(() {});
  }

  Map<int, List<Vector4>> _fetchVectors(
    Size size,
    List<FaceEntity> entities,
  ) {
    final Map<int, List<Vector4>> result = <int, List<Vector4>>{};

    for (int i = 0, length = entities.length; i < length; i++) {
      result.addAll(
        {
          i: VectorTransformation.transform(
            vertices: entities[i].vertices,
            translate: _position,
            scale: _scale,
            rotation: _rotation,
            size: size,
          ),
        },
      );
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
}
