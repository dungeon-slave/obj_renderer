import 'package:data/data.dart' hide Colors;
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final Paint _paint = Paint()..color = Colors.black;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
  }) : _entities = entities;

  @override
  void paint(Canvas canvas, _) {
    for (List<Vector4> entity in _entities.values) {
      for (int i = 0; i < entity.length - 1; i++) {
        canvas.drawLine(
          Offset(entity[i].x, entity[i].y),
          Offset(entity[i + 1].x, entity[i + 1].y),
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
