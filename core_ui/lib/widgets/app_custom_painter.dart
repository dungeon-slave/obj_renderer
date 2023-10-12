import 'dart:math';
import 'dart:ui';

import 'package:data/data.dart' hide Colors;
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final Paint _paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
  }) : _entities = entities;

  @override
  void paint(Canvas canvas, _) {
    final List<Offset> points = [];

    for (List<Vector4> entity in _entities.values) {
      for (int i = 0; i < entity.length - 1; i++) {
        final double xStart = entity[i].x.roundToDouble();
        final double yStart = entity[i].y.roundToDouble();

        final double xEnd = entity[i + 1].x.roundToDouble();
        final double yEnd = entity[i + 1].y.roundToDouble();

        final double L = max((xEnd - xStart).abs(), (yEnd - yStart).abs());

        final double dX = (entity[i + 1].x - entity[i].x) / L;
        final double dY = (entity[i + 1].y - entity[i].y) / L;

        double x = entity[i].x;
        double y = entity[i].y;

        for (int i = 0; i <= L; i++) {
          x += dX;
          y += dY;

          points.add(Offset(x.floorToDouble(), y.floorToDouble()));
        }
      }
    }

    canvas.drawPoints(PointMode.points, points, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
