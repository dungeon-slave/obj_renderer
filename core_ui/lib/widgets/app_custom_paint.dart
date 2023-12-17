import 'package:bitmap/bitmap.dart';
import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPaint extends StatefulWidget {
  final Map<int, List<Vector4>> _entities;
  final Map<String, Bitmap> _objectData;
  final List<Vector4> _world;
  final List<Vector3> _normals;
  final List<Vector3> _textures;
  final Vector3 _lightDirection;

  const AppCustomPaint({
    required Map<int, List<Vector4>> entities,
    required Map<String, Bitmap> objectData,
    required List<Vector4> world,
    required List<Vector3> normals,
    required List<Vector3> textures,
    required Vector3 lightDirection,
    super.key,
  })  : _entities = entities,
        _objectData = objectData,
        _normals = normals,
        _textures = textures,
        _lightDirection = lightDirection,
        _world = world;

  @override
  _AppCustomPaintState createState() => _AppCustomPaintState();
}

class _AppCustomPaintState extends State<AppCustomPaint> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: size,
        painter: AppCustomPainter(
          entities: widget._entities,
          screenSize: size,
          world: widget._world,
          normals: widget._normals,
          textures: widget._textures,
          lightDirection: widget._lightDirection,
          objectData: widget._objectData,
        ),
      ),
    );
  }
}
