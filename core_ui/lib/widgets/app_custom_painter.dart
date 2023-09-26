import 'package:data/data.dart' hide Colors;
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final List<Vector4> entities;

  AppCustomPainter({
    required this.entities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < entities.length - 1; i++) {
      canvas.drawLine(
        Offset(entities[i].x, entities[i].y),
        Offset(entities[i + 1].x, entities[i + 1].y),
        Paint()..color = Colors.black,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
