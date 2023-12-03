import 'dart:ui' as ui;

import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:flutter/material.dart';

// class AppCustomPaint extends StatefulWidget {
//   final Map<int, List<Vector4>> _entities;
//   final List<Vector4> _world;
//
//   const AppCustomPaint({
//     required Map<int, List<Vector4>> entities,
//     required List<Vector4> world,
//     super.key,
//   }) : _entities = entities, _world = world;
//
//   @override
//   _AppCustomPaintState createState() => _AppCustomPaintState();
// }
//
// class _AppCustomPaintState extends State<AppCustomPaint> {
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.sizeOf(context);
//
//     return Container(
//       decoration: BoxDecoration(border: Border.all()),
//       child: CustomPaint(
//         size: size,
//         painter: AppCustomPainter(
//           entities: widget._entities,
//           screenSize: size, world: widget._world,
//         ),
//       ),
//     );
//   }
// }

class AppCustomPaint extends StatefulWidget {
  final ui.Image _image;

  const AppCustomPaint({
    required ui.Image image,
    super.key,
  }) : _image = image;

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
          image: widget._image,
        ),
      ),
    );
  }
}
