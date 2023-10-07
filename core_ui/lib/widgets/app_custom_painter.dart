import 'package:data/data.dart' hide Colors;
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> entities;

  AppCustomPainter({
    required this.entities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.black;

    for (var entity in entities.values) {
      for (int i = 0; i < entity.length - 1; i++) {
        canvas.drawLine(
          Offset(entity[i].x, entity[i].y),
          Offset(entity[i + 1].x, entity[i + 1].y),
          paint,
        );
      }
    }

    // canvas.drawLine(
    //   Offset(entities[entities.length - 1].x, entities[entities.length - 1].y),
    //   Offset(entities[0].x, entities[0].y),
    //   paint,
    // );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
