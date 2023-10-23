import 'package:core_ui/app_colors.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final Paint _paint = Paint()..color = AppColors.vertexColor;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
  }) : _entities = entities;

  @override
  void paint(Canvas canvas, _) {
    for (int i = 0, length = _entities.values.length; i < length; i++) {
      List<Vector4> entity = _entities.values.elementAt(i);
      
      for (int j = 0, entityLen = entity.length - 1; j < entityLen; j++) {
        canvas.drawLine(
          Offset(entity[j].x, entity[j].y),
          Offset(entity[j + 1].x, entity[j + 1].y),
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
