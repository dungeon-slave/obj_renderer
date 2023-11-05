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
      List<Vector4> triangle = _entities.values.elementAt(i).sublist(0, 3);

      Vector4 temp;
      if (triangle[0].y > triangle[1].y) {
        temp = triangle[0];
        triangle[0] = triangle[1];
        triangle[1] = temp;
      }
      if (triangle[0].y > triangle[2].y) {
        temp = triangle[0];
        triangle[0] = triangle[2];
        triangle[2] = temp;
      }
      if (triangle[1].y > triangle[2].y) {
        temp = triangle[1];
        triangle[1] = triangle[2];
        triangle[2] = temp;
      }

      Vector4 coefficient1 =
          (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
      Vector4 coefficient2 =
          (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
      Vector4 coefficient3 =
          (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

      for (int minY = triangle[0].y.ceil(),
              y = minY,
              maxY = triangle[2].y.ceil();
          y <= maxY;
          y++) {
        Vector4 a = y > triangle[1].y
            ? triangle[1] + coefficient3 * (y - triangle[1].y)
            : triangle[0] + coefficient1 * (y - triangle[0].y);
        Vector4 b = triangle[0] + coefficient2 * (y - triangle[0].y);
        double yd = y.toDouble();
        double xD;

        if (a.x > b.x) {
          (a, b) = (b, a);
        }

        for (int minX = a.x.ceil(), x = minX, maxX = b.x.ceil();
            x < maxX;
            x++) {
          xD = x.toDouble();
          canvas.drawLine(
            Offset(xD, yd),
            Offset(xD + 0.1, yd + 0.1),
            _paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
