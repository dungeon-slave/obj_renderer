import 'dart:math';

import 'package:core_ui/app_colors.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final List<Vector4> _world;
  final Paint _paint = Paint() /*..color = AppColors.vertexColor*/;
  final Size _screenSize;
  final double _dotSize = 1;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
    required List<Vector4> world,
    required Size screenSize,
  })  : _entities = entities,
        _screenSize = screenSize,
        _world = world;

  @override
  void paint(Canvas canvas, _) {
    List<double?> zBuffer = List.generate(
      (_screenSize.height.toInt()) * (_screenSize.width.toInt()),
      (int index) => null,
      growable: false,
    );

    for (int i = 0, length = _entities.values.length; i < length - 3; i++) {
      final List<Vector4> triangle =
          _entities.values.elementAt(i) /*.sublist(0, 3)*/;
      int pos = i * 3;
      final List<Vector4> triangleWorld = _world.sublist(pos, pos + 3);

      Vector4 edge1World = triangleWorld[1] - triangleWorld[0];
      Vector4 edge2World = triangleWorld[2] - triangleWorld[0];

      Vector4 edge1 = triangle[1] - triangle[0];
      Vector4 edge2 = triangle[2] - triangle[0];

      Vector3 normalWorld = Vector3(
        edge1World.y * edge2World.z - edge1World.z * edge2World.y,
        edge1World.z * edge2World.x - edge1World.x * edge2World.z,
        edge1World.x * edge2World.y - edge1World.y * edge2World.x,
      ).normalized();

      Vector3 normal = Vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x,
      ).normalized();

      //Vector3 newTriangle = Vector3(triangle[0].x, triangle[0].y, triangle[0].z);
      if (normal.z >= 0) {
        continue;
      }

      Vector3 lightDirection = Vector3(-1, -1, -1).normalized();
      double intensity = max(normalWorld.dot(-lightDirection), 0);

      _paint.color = Color.fromARGB(
        255,
        (AppColors.vertexColor.red * intensity).toInt(),
        (AppColors.vertexColor.green * intensity).toInt(),
        (AppColors.vertexColor.blue * intensity).toInt(),
      );

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
          y < maxY;
          y++) {
        Vector4 a = y > triangle[1].y
            ? triangle[1] + coefficient3 * (y - triangle[1].y)
            : triangle[0] + coefficient1 * (y - triangle[0].y);
        Vector4 b = triangle[0] + coefficient2 * (y - triangle[0].y);
        double yD = y.toDouble();

        if (a.x > b.x) {
          (a, b) = (b, a);
        }

        Vector4 coeff_ab = (b - a) / (b.x - a.x);
        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenSize.width.toInt() - 1);
            x < maxX;
            x++) {
          double xD = x.toDouble();

          Vector4 p = a + coeff_ab * (xD - a.x);
          p = p.normalized();

          int width = _screenSize.width.toInt();
          int pos = y * width + x;
          if (zBuffer[pos] == null || zBuffer[pos]! > p.z) {
            zBuffer[pos] = p.z;
            canvas.drawRect(
              Rect.fromPoints(
                Offset(xD, yD),
                Offset(xD + _dotSize, yD + _dotSize),
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
