import 'dart:math';

import 'package:core_ui/app_colors.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

import '../scene_settings.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final Paint _paint = Paint()
    ..color = AppColors.vertexColor
    ..style = PaintingStyle.fill;
  final Size _screenSize;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
    required Size screenSize,
  })  : _entities = entities,
        _screenSize = screenSize;

  @override
  void paint(Canvas canvas, _) {
    List<double?> zBuffer = List.generate(
      (_screenSize.height.toInt()) * (_screenSize.width.toInt()),
      (int index) => null,
      growable: false,
    );

    for (int i = 0, length = _entities.values.length; i < length; i++) {
      List<Vector4> triangle = _entities.values.elementAt(i).sublist(0, 3);

      Vector4 edge1 = triangle[1] - triangle[0];
      Vector4 edge2 = triangle[2] - triangle[0];
      // if (edge1.x * edge2.y - edge1.y * edge2.x < 0) {
      //   continue;
      // }

      Vector3 normal = Vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x,
      ).normalized();

      if (normal.dot(SceneSettings.eye) < 0) {
        continue;
      }

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

      for (int minY = max(triangle[0].y.ceil(), 0),
              y = minY,
              maxY = min(triangle[2].y.ceil(), _screenSize.height.toInt() - 1);
          y <= maxY;
          y++) {
        Vector4 a = y > triangle[1].y
            ? triangle[1] + coefficient3 * (y - triangle[1].y)
            : triangle[0] + coefficient1 * (y - triangle[0].y);
        Vector4 b = triangle[0] + coefficient2 * (y - triangle[0].y);
        double yd = y.toDouble();

        if (a.x > b.x) {
          (a, b) = (b, a);
        }

        Vector4 koeff_ab = (b - a) / (b.x - a.x);
        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenSize.width.toInt() - 1);
            x < maxX;
            x++) {
          double xD = x.toDouble();

          Vector4 p = a + koeff_ab * (xD - a.x);
          p = p.normalized();

          int width = _screenSize.width.toInt();
          int pos = y * width + x;
          if (zBuffer[pos] == null || zBuffer[pos]! > p.z) {
            zBuffer[pos] = p.z;
            canvas.drawRect(
              Rect.fromPoints(
                Offset(xD, yd),
                Offset(xD + 0.5, yd + 0.5),
              ),
              _paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
