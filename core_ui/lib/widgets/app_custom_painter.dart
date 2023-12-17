import 'dart:math';

import 'package:bitmap/bitmap.dart';
import 'package:core_ui/app_colors.dart';
import 'package:core_ui/core_ui.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final Map<String, Bitmap> _objectData;
  final List<Vector4> _world;
  final List<Vector3> _normals;
  final List<Vector3> _textures;
  final Paint _paint = Paint();
  final Size _screenSize;
  final double _dotSize = 1;
  final Vector3 _lightDirection;
  late List<double?> _zBuffer;

  late List<List<double?>> zBufferOIT;

  final Map<Vector3, List<Vector3>> triangleNormals =
      <Vector3, List<Vector3>>{};
  final Map<Vector3, Vector3> vertexNormals = <Vector3, Vector3>{};

  double get _screenSizeInPixels => _screenSize.width * _screenSize.height;

  double? _previousSize;

  static const double ambientFactor = 0.1;
  static const double diffuseFactor = 30;
  static const double specularFactor = 100;
  static const double glossFactor = 50;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
    required Map<String, Bitmap> objectData,
    required List<Vector4> world,
    required List<Vector3> normals,
    required List<Vector3> textures,
    required Size screenSize,
    required Vector3 lightDirection,
  })  : _entities = entities,
        _objectData = objectData,
        _screenSize = screenSize,
        _normals = normals,
        _textures = textures,
        _lightDirection = lightDirection,
        _world = world;

  @override
  void paint(Canvas canvas, _) {
    _generateZBuffer();

    for (int i = 0, length = _entities.values.length; i < length - 3; i++) {
      final List<Vector4> triangle = _entities.values.elementAt(i);
      final int pos = i * 3;
      final List<Vector4> triangleWorld = _world.sublist(pos, pos + 3);
      final List<Vector3> normals = _normals.sublist(pos, pos + 3);
      final List<Vector3> textures = _textures.sublist(pos, pos + 3);
      final Vector4 edge1 = triangle[1] - triangle[0];
      final Vector4 edge2 = triangle[2] - triangle[0];
      final Vector3 normal = Vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x,
      ).normalized();

      // Отбраковка поверхностей

      if (normal.z >= 0) {
        continue;
      }

      // Поиск нормали по вершинам.
      Vector3 vertexNormal0 = normals[0].normalized() /* * triangle[0].w*/;
      Vector3 vertexNormal1 = normals[1].normalized() /* * triangle[1].w*/;
      Vector3 vertexNormal2 = normals[2].normalized() /* * triangle[2].w*/;

      Vector3 texture0 = textures[0] * triangle[0].w;
      Vector3 texture1 = textures[1] * triangle[1].w;
      Vector3 texture2 = textures[2] * triangle[2].w;

      // Сортировка вершин треугольников
      Vector4 temp;

      if (triangle[0].y > triangle[1].y) {
        temp = triangle[0];
        triangle[0] = triangle[1];
        triangle[1] = temp;

        temp = triangleWorld[0];
        triangleWorld[0] = triangleWorld[1];
        triangleWorld[1] = temp;

        (vertexNormal0, vertexNormal1) = (vertexNormal1, vertexNormal0);
        (texture0, texture1) = (texture1, texture0);
      }
      if (triangle[0].y > triangle[2].y) {
        temp = triangle[0];
        triangle[0] = triangle[2];
        triangle[2] = temp;

        temp = triangleWorld[0];
        triangleWorld[0] = triangleWorld[2];
        triangleWorld[2] = temp;

        (vertexNormal0, vertexNormal2) = (vertexNormal2, vertexNormal0);
        (texture0, texture2) = (texture2, texture0);
      }
      if (triangle[1].y > triangle[2].y) {
        temp = triangle[1];
        triangle[1] = triangle[2];
        triangle[2] = temp;

        temp = triangleWorld[1];
        triangleWorld[1] = triangleWorld[2];
        triangleWorld[2] = temp;

        (vertexNormal1, vertexNormal2) = (vertexNormal2, vertexNormal1);
        (texture1, texture2) = (texture2, texture1);
      }

      // Нахождение коэффицентов в экранных и мировых координатах и коэффицента для нормалей.
      final Vector4 coefficient1 =
          (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
      final Vector4 coefficient2 =
          (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
      final Vector4 coefficient3 =
          (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

      final Vector4 coefficient1World = (triangleWorld[1] - triangleWorld[0]) /
          (triangle[1].y - triangle[0].y);
      final Vector4 coefficient2World = (triangleWorld[2] - triangleWorld[0]) /
          (triangle[2].y - triangle[0].y);
      final Vector4 coefficient3World = (triangleWorld[2] - triangleWorld[1]) /
          (triangle[2].y - triangle[1].y);

      final Vector3 coefficient1Normal =
          (vertexNormal1 - vertexNormal0) / (triangle[1].y - triangle[0].y);
      final Vector3 coefficient2Normal =
          (vertexNormal2 - vertexNormal0) / (triangle[2].y - triangle[0].y);
      final Vector3 coefficient3Normal =
          (vertexNormal2 - vertexNormal1) / (triangle[2].y - triangle[1].y);

      final Vector3 coefficient1Texture =
          (texture1 - texture0) / (triangle[1].y - triangle[0].y);
      final Vector3 coefficient2Texture =
          (texture2 - texture0) / (triangle[2].y - triangle[0].y);
      final Vector3 coefficient3Texture =
          (texture2 - texture1) / (triangle[2].y - triangle[1].y);

      for (int minY = max(triangle[0].y.ceil(), 0),
              y = minY,
              maxY = min(triangle[2].y.ceil(), _screenSize.height.toInt() - 1);
          y < maxY;
          y++) {
        Vector4 a = triangle[0] + coefficient2 * (y - triangle[0].y);

        Vector4 b = y > triangle[1].y
            ? triangle[1] + coefficient3 * (y - triangle[1].y)
            : triangle[0] + coefficient1 * (y - triangle[0].y);

        Vector4 worldA =
            triangleWorld[0] + coefficient2World * (y - triangle[0].y);

        Vector4 worldB = y > triangle[1].y
            ? triangleWorld[1] + coefficient3World * (y - triangle[1].y)
            : triangleWorld[0] + coefficient1World * (y - triangle[0].y);

        Vector3 normalA =
            vertexNormal0 + coefficient2Normal * (y - triangle[0].y);

        Vector3 normalB = y > triangle[1].y
            ? vertexNormal1 + coefficient3Normal * (y - triangle[1].y)
            : vertexNormal0 + coefficient1Normal * (y - triangle[0].y);

        Vector3 textureA = texture0 + coefficient2Texture * (y - triangle[0].y);

        Vector3 textureB = y > triangle[1].y
            ? texture1 + coefficient3Texture * (y - triangle[1].y)
            : texture0 + coefficient1Texture * (y - triangle[0].y);

        final double yD = y.toDouble();

        if (a.x > b.x) {
          (a, b) = (b, a);
          (worldA, worldB) = (worldB, worldA);
          (normalA, normalB) = (normalB, normalA);
          (textureA, textureB) = (textureB, textureA);
        }

        // Нахождение коэффицентов изменения X в экранных и мировых координатах, коэффицента изменения нормали.
        final Vector4 coeff_ab = (b - a) / (b.x - a.x);
        final Vector4 coeff_world_ab = (worldB - worldA) / (b.x - a.x);
        final Vector3 coeff_normal_ab = (normalB - normalA) / (b.x - a.x);
        final Vector3 coeff_texture_ab = (textureB - textureA) / (b.x - a.x);

        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenSize.width.toInt() - 1);
            x < maxX;
            x++) {
          final double xD = x.toDouble();

          final Vector4 p = a + coeff_ab * (xD - a.x);
          final Vector4 pWorld = worldA + coeff_world_ab * (xD - a.x);

          final int width = _screenSize.width.toInt();
          final int pos = y * width + x;

          //TODO Implement zBufferOIT insted of zBuffer
          if (_zBuffer[pos] == null || _zBuffer[pos]! > p.z) {
            _zBuffer[pos] = p.z;

            final Vector3 pWorld3 = Vector3(pWorld.x, pWorld.y, pWorld.z);
            final Vector3 viewDirection =
                (SceneSettings.eye - pWorld3).normalized();

            final Vector3 texture =
                (textureA + coeff_texture_ab * (xD - a.x)) / p.w;

            final Bitmap? diffuseBitmap = _objectData['diffuse'];

            Color color = AppColors.lightColor;
            if (diffuseBitmap != null) {
              final transformedX = texture.x;
              final transformedY = texture.y;

              final int x = (transformedX * (diffuseBitmap.width - 1)).toInt();
              final int y =
                  ((1 - transformedY) * (diffuseBitmap.height - 1)).toInt();

              final index = (y * diffuseBitmap.width + x) * 4;
              color = Color.fromARGB(
                diffuseBitmap.content[index + 3],
                diffuseBitmap.content[index],
                diffuseBitmap.content[index + 1],
                diffuseBitmap.content[index + 2],
              );
            }

            final Bitmap? mirrorBitmap = _objectData['mirror'];

            Color specular = AppColors.lightColor;
            if (mirrorBitmap != null) {
              final int x = (texture.x * (mirrorBitmap.width /* - 1*/)).toInt();
              final int y =
                  ((1 - texture.y) * (mirrorBitmap.height /* - 1*/)).toInt();

              final index = (y * mirrorBitmap.width + x) * 4;
              specular = Color.fromARGB(
                mirrorBitmap.content[index + 3],
                mirrorBitmap.content[index],
                mirrorBitmap.content[index + 1],
                mirrorBitmap.content[index + 2],
              );
            }

            final Bitmap? normalBitmap = _objectData['normal'];

            Vector3 normal = Vector3(1, 1, 1);
            Color normalColor;
            if (normalBitmap != null) {
              final int x = (texture.x * (normalBitmap.width /* - 1*/)).toInt();
              final int y =
                  ((1 - texture.y) * (normalBitmap.height /* - 1*/)).toInt();

              final index = (y * normalBitmap.width + x) * 4;
              normalColor = Color.fromARGB(
                normalBitmap.content[index + 3] ~/ 255,
                normalBitmap.content[index] ~/ 255,
                normalBitmap.content[index + 1] ~/ 255,
                normalBitmap.content[index + 2] ~/ 255,
              );

              normal = Vector3(
                normalColor.red.toDouble(),
                normalColor.green.toDouble(),
                normalColor.blue.toDouble(),
              );

              normal = (normal * 2 - Vector3(1, 1, 1));
            }
            normal = (normalA + coeff_normal_ab * (xD - a.x)).normalized();

            final double intensity = max(normal.dot(-_lightDirection), 0);

            // Затенение объекта в зависимости от дистанции света до модели.
            final double distance = _lightDirection.length2;
            final double attenuation = 1 / max(distance, 15);

            final List<int> ambientValues = ambientLightning(color);
            final List<int> diffuseValues =
                diffuseLightning(intensity * attenuation, color);
            final List<int> specularValues = specularLightning(
              viewDirection,
              _lightDirection,
              normal,
              specular,
            );

            _paint.color = Color.fromARGB(
              255,
              min(ambientValues[0] + diffuseValues[0] + specularValues[0], 255),
              min(ambientValues[1] + diffuseValues[1] + specularValues[1], 255),
              min(ambientValues[2] + diffuseValues[2] + specularValues[2], 255),
            );

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

  void _generateZBuffer() {
    if (_previousSize != _screenSizeInPixels) {
      // _zBuffer = List.filled(
      //   _screenSizeInPixels.toInt(),
      //   null,
      //   growable: false,
      // );
      zBufferOIT = List<List<double?>>.filled(
        _screenSizeInPixels.toInt(),
        List<double?>.filled(
          0,
          null,
          growable: true,
        ),
        growable: false,
      );
      _previousSize = _screenSizeInPixels;
    }
  }

  List<int> ambientLightning(Color lightColor) {
    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (lightColor.red * ambientFactor).toInt();
          case 1:
            return (lightColor.green * ambientFactor).toInt();
          default:
            return (lightColor.blue * ambientFactor).toInt();
        }
      },
      growable: false,
    );
  }

  List<int> diffuseLightning(double intensity, Color lightColor) {
    final double scalar = intensity * diffuseFactor;

    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (lightColor.red * scalar).toInt();
          case 1:
            return (lightColor.green * scalar).toInt();
          default:
            return (lightColor.blue * scalar).toInt();
        }
      },
      growable: false,
    );
  }

  List<int> specularLightning(
    Vector3 view,
    Vector3 lightDirection,
    Vector3 normal,
    Color specular,
  ) {
    final Vector3 reflection = (lightDirection).reflected(normal).normalized();
    final double rv = max(reflection.dot(view), 0);
    final num temp = pow(rv, glossFactor);

    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (specular.red * temp).toInt();
          case 1:
            return (specular.green * temp).toInt();
          default:
            return (specular.blue * temp).toInt();
        }
      },
      growable: false,
    );
  }
}
