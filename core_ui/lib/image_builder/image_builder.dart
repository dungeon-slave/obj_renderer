import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bitmap/bitmap.dart';
import 'package:core_ui/app_colors.dart';
import 'package:core_ui/image_builder/pre_build_image_values.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart' as material;

abstract class ImageBuilder {
  static Future<ui.Image> build(
    material.Size size,
    Map<int, List<Vector4>> vectors,
    List<Vector4> _world,
  ) async {
    final PreBuildImageValues preBuildValues = _getPreBuildValues(
      size,
      vectors,
      _world,
    );

    final Bitmap bitmap = Bitmap.fromHeadless(
      preBuildValues.$1,
      preBuildValues.$2,
      preBuildValues.$3,
    );

    return await bitmap.buildImage();
  }

  static PreBuildImageValues _getPreBuildValues(
    material.Size size,
    Map<int, List<Vector4>> _entities,
    List<Vector4> _world,
  ) {
    final int width = size.width.toInt();
    final int height = size.height.toInt();

    return (
      width,
      height,
      _generateContent(height, width, _entities, _world),
    );
  }

  static Uint8List _generateContent(
    int height,
    int width,
    Map<int, List<Vector4>> vectors,
    List<Vector4> worldVectors,
  ) {
    final List<material.Color> coloredContent = _getColoredContent(
      height,
      width,
      vectors,
      worldVectors,
    );

    return Uint8List.fromList(
      List.generate(
        width * height * 4,
        (int index) => _generatePixelPart(index, coloredContent[index ~/ 4]),
        growable: false,
      ),
    );
  }

  static List<material.Color> _getColoredContent(
    int height,
    int width,
    Map<int, List<Vector4>> vectors,
    List<Vector4> worldVectors,
  ) {
    final List<(double z, material.Color color)?> coloredZBuffer = List.filled(
      height * width,
      null,
      growable: false,
    );

    for (int i = 0, length = vectors.values.length; i < length - 3; i++) {
      final List<Vector4> triangle = vectors.values.elementAt(i);
      final int worldPos = i * 3;
      final List<Vector4> triangleWorld =
          worldVectors.sublist(worldPos, worldPos + 3);

      final Vector4 edge1World = triangleWorld[1] - triangleWorld[0];
      final Vector4 edge2World = triangleWorld[2] - triangleWorld[0];

      final Vector4 edge1 = triangle[1] - triangle[0];
      final Vector4 edge2 = triangle[2] - triangle[0];

      final Vector3 normalWorld = Vector3(
        edge1World.y * edge2World.z - edge1World.z * edge2World.y,
        edge1World.z * edge2World.x - edge1World.x * edge2World.z,
        edge1World.x * edge2World.y - edge1World.y * edge2World.x,
      ).normalized();

      final Vector3 normal = Vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x,
      ).normalized();

      if (normal.z >= 0) {
        continue;
      }

      final Vector3 lightDirection = Vector3(-1, -1, -1).normalized();
      final double intensity = max(normalWorld.dot(-lightDirection), 0);

      final material.Color color = material.Color.fromARGB(
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

      final Vector4 coefficient1 =
          (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
      final Vector4 coefficient2 =
          (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
      final Vector4 coefficient3 =
          (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

      for (int minY = max(triangle[0].y.ceil(), 0),
              y = minY,
              maxY = min(triangle[2].y.ceil(), height);
          y < maxY;
          y++) {
        Vector4 a = y > triangle[1].y
            ? triangle[1] + coefficient3 * (y - triangle[1].y)
            : triangle[0] + coefficient1 * (y - triangle[0].y);
        Vector4 b = triangle[0] + coefficient2 * (y - triangle[0].y);

        if (a.x > b.x) (a, b) = (b, a);

        final Vector4 coeff_ab = (b - a) / (b.x - a.x);
        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), width);
            x < maxX;
            x++) {
          final Vector4 p = (a + coeff_ab * (x - a.x)).normalized();

          final int pos = y * width + x;
          if (coloredZBuffer[pos] == null || coloredZBuffer[pos]!.$1 > p.z) {
            coloredZBuffer[pos] = (p.z, color);
          }
        }
      }
    }

    return coloredZBuffer.map<material.Color>(
      ((double, material.Color)? e) {
        return e == null ? material.Color.fromARGB(255, 0, 0, 0) : e.$2;
      },
    ).toList();
  }

  static int _generatePixelPart(int pixelPartIndex, material.Color pixelColor) {
    int modResult = pixelPartIndex % 4;
    int pixelPartValue = 1;

    switch (modResult) {
      case 0:
        pixelPartValue = pixelColor.red;
      case 1:
        pixelPartValue = pixelColor.green;
      case 2:
        pixelPartValue = pixelColor.blue;
      case 3:
        pixelPartValue = pixelColor.alpha;
    }

    return pixelPartValue;
  }
}
