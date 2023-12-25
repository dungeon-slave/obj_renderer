import 'dart:math';

import 'package:bitmap/bitmap.dart';
import 'package:core_ui/app_colors.dart';
import 'package:core_ui/scene_settings.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  static const double _ambientFactor = 0.1;
  static const double _diffuseFactor = 30;
  static const double _glossFactor = 50;

  final Map<int, List<Vector4>> _entities;
  final Map<String, Bitmap> _objectData;
  final List<Vector4> _world;
  final List<Vector3> _normals;
  final List<Vector3> _textures;
  final Paint _paint = Paint();
  final Size _screenSize;
  final double _dotSize = 1;
  final Vector3 _lightDirection;
  final List<(List<Vector4>, Vector4, Vector4, Vector4)> _triangleValues =
      <(List<Vector4>, Vector4, Vector4, Vector4)>[];

  late final int _screenWidth = _screenSize.width.toInt();
  late final int _screenHeight = _screenSize.height.toInt();
  late final List<int> _deepnessBuffer = List.filled(
    _screenWidth * _screenHeight,
    0,
    growable: false,
  );
  late final List<int> _deepnessBuffer2 = List.filled(
    _screenWidth * _screenHeight,
    0,
    growable: false,
  );

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
    required Map<String, Bitmap> objectData,
    required List<Vector4> world,
    required List<Vector3> normals,
    required List<Vector3> textures,
    required List<Vector3> fileNormals,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, _) {
    for (int i = 0, length = _entities.values.length; i < length; i++) {
      _triangleValues.add(getValues(i));

      for (int minY = max(_triangleValues[i].$1[0].y.ceil(), 0),
              y = minY,
              maxY = min(_triangleValues[i].$1[2].y.ceil(), _screenHeight - 1);
          y < maxY;
          y++) {
        Vector4 a = _triangleValues[i].$1[0] +
            _triangleValues[i].$3 * (y - _triangleValues[i].$1[0].y);

        Vector4 b = y > _triangleValues[i].$1[1].y
            ? _triangleValues[i].$1[1] +
                _triangleValues[i].$4 * (y - _triangleValues[i].$1[1].y)
            : _triangleValues[i].$1[0] +
                _triangleValues[i].$2 * (y - _triangleValues[i].$1[0].y);

        if (a.x > b.x) {
          (a, b) = (b, a);
        }

        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenWidth - 1);
            x < maxX;
            x++) {
          final int pos = y * _screenWidth + x;

          _deepnessBuffer[pos]++;
        }
      }
    }

    for (int i = 0, len = _deepnessBuffer.length, curr = 0; i < len; i++) {
      curr += _deepnessBuffer[i];
      _deepnessBuffer[i] = curr;
    }

    final List<Vector3> offsetBuffer = List.filled(
      _deepnessBuffer.last,
      Vector3.zero(),
      growable: true,
    );

    for (int i = 0, length = _entities.values.length; i < length; i++) {
      for (int minY = max(_triangleValues[i].$1[0].y.ceil(), 0),
              y = minY,
              maxY = min(_triangleValues[i].$1[2].y.ceil(), _screenHeight - 1);
          y < maxY;
          y++) {
        Vector4 a = _triangleValues[i].$1[0] +
            _triangleValues[i].$3 * (y - _triangleValues[i].$1[0].y);

        Vector4 b = y > _triangleValues[i].$1[1].y
            ? _triangleValues[i].$1[1] +
                _triangleValues[i].$4 * (y - _triangleValues[i].$1[1].y)
            : _triangleValues[i].$1[0] +
                _triangleValues[i].$2 * (y - _triangleValues[i].$1[0].y);

        if (a.x > b.x) {
          (a, b) = (b, a);
        }

        final Vector4 coeff_ab = (b - a) / (b.x - a.x);

        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenWidth - 1);
            x < maxX;
            x++) {
          final double xD = x.toDouble();
          final Vector4 p = a + coeff_ab * (xD - a.x);
          final int pos = y * _screenWidth + x;
          final int value = _deepnessBuffer[pos] + _deepnessBuffer2[pos] - 1;

          if (value > offsetBuffer.length - 1) {
            break;
          }

          offsetBuffer[value] = Vector3(p.x, p.y, p.z);

          _deepnessBuffer2[pos]++;
        }
      }
    }

    final List<int> reducedArray =
        _deepnessBuffer.where((int element) => element != 0).toList();

    //SORT OFFSET ARRAY
    int index = 0;
    for (int i = 0, len = reducedArray.length; i < len; i++) {
      final int sublistEnd = reducedArray[i] - 1;
      final List<Vector3> sublist = offsetBuffer.sublist(index, sublistEnd);

      offsetBuffer.replaceRange(index, sublistEnd, insertionSort(sublist));
      index = sublistEnd;
    }

    for (int i = 0, length = _entities.values.length; i < length - 3; i++) {
      final int pos = i * 3;
      final int pos_3 = pos + 3;

      final List<Vector4> triangleWorld = _world.sublist(pos, pos_3);
      final List<Vector3> normals = _normals.sublist(pos, pos_3);
      final List<Vector3> textures = _textures.sublist(pos, pos_3);

      // Поиск нормали по вершинам.
      Vector3 vertexNormal0 =
          normals[0].normalized() * _triangleValues[i].$1[0].w;
      Vector3 vertexNormal1 =
          normals[1].normalized() * _triangleValues[i].$1[1].w;
      Vector3 vertexNormal2 =
          normals[2].normalized() * _triangleValues[i].$1[2].w;

      Vector3 texture0 = textures[0] * _triangleValues[i].$1[0].w;
      Vector3 texture1 = textures[1] * _triangleValues[i].$1[1].w;
      Vector3 texture2 = textures[2] * _triangleValues[i].$1[2].w;

      Vector4 temp;
      if (_triangleValues[i].$1[0].y > _triangleValues[i].$1[1].y) {
        temp = triangleWorld[0];
        triangleWorld[0] = triangleWorld[1];
        triangleWorld[1] = temp;

        (vertexNormal0, vertexNormal1) = (vertexNormal1, vertexNormal0);
        (texture0, texture1) = (texture1, texture0);
      }
      if (_triangleValues[i].$1[0].y > _triangleValues[i].$1[2].y) {
        temp = triangleWorld[0];
        triangleWorld[0] = triangleWorld[2];
        triangleWorld[2] = temp;

        (vertexNormal0, vertexNormal2) = (vertexNormal2, vertexNormal0);
        (texture0, texture2) = (texture2, texture0);
      }
      if (_triangleValues[i].$1[1].y > _triangleValues[i].$1[2].y) {
        temp = triangleWorld[1];
        triangleWorld[1] = triangleWorld[2];
        triangleWorld[2] = temp;

        (vertexNormal1, vertexNormal2) = (vertexNormal2, vertexNormal1);
        (texture1, texture2) = (texture2, texture1);
      }

      final Vector4 coefficient1World = (triangleWorld[1] - triangleWorld[0]) /
          (_triangleValues[i].$1[1].y - _triangleValues[i].$1[0].y);
      final Vector4 coefficient2World = (triangleWorld[2] - triangleWorld[0]) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[0].y);
      final Vector4 coefficient3World = (triangleWorld[2] - triangleWorld[1]) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[1].y);

      final Vector3 coefficient1Normal = (vertexNormal1 - vertexNormal0) /
          (_triangleValues[i].$1[1].y - _triangleValues[i].$1[0].y);
      final Vector3 coefficient2Normal = (vertexNormal2 - vertexNormal0) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[0].y);
      final Vector3 coefficient3Normal = (vertexNormal2 - vertexNormal1) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[1].y);

      final Vector3 coefficient1Texture = (texture1 - texture0) /
          (_triangleValues[i].$1[1].y - _triangleValues[i].$1[0].y);
      final Vector3 coefficient2Texture = (texture2 - texture0) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[0].y);
      final Vector3 coefficient3Texture = (texture2 - texture1) /
          (_triangleValues[i].$1[2].y - _triangleValues[i].$1[1].y);

      for (int minY = max(_triangleValues[i].$1[0].y.ceil(), 0),
              y = minY,
              maxY = min(_triangleValues[i].$1[2].y.ceil(), _screenHeight - 1);
          y < maxY;
          y++) {
        final double yD = y.toDouble();

        // Нахождение левого и правого Y
        Vector4 a = _triangleValues[i].$1[0] +
            _triangleValues[i].$3 * (y - _triangleValues[i].$1[0].y);
        Vector4 b = y > _triangleValues[i].$1[1].y
            ? _triangleValues[i].$1[1] +
                _triangleValues[i].$4 * (y - _triangleValues[i].$1[1].y)
            : _triangleValues[i].$1[0] +
                _triangleValues[i].$2 * (y - _triangleValues[i].$1[0].y);

        Vector4 worldA = triangleWorld[0] +
            coefficient2World * (y - _triangleValues[i].$1[0].y);
        Vector4 worldB = y > _triangleValues[i].$1[1].y
            ? triangleWorld[1] +
                coefficient3World * (y - _triangleValues[i].$1[1].y)
            : triangleWorld[0] +
                coefficient1World * (y - _triangleValues[i].$1[0].y);

        Vector3 normalA = vertexNormal0 +
            coefficient2Normal * (y - _triangleValues[i].$1[0].y);
        Vector3 normalB = y > _triangleValues[i].$1[1].y
            ? vertexNormal1 +
                coefficient3Normal * (y - _triangleValues[i].$1[1].y)
            : vertexNormal0 +
                coefficient1Normal * (y - _triangleValues[i].$1[0].y);

        Vector3 textureA =
            texture0 + coefficient2Texture * (y - _triangleValues[i].$1[0].y);
        Vector3 textureB = y > _triangleValues[i].$1[1].y
            ? texture1 + coefficient3Texture * (y - _triangleValues[i].$1[1].y)
            : texture0 + coefficient1Texture * (y - _triangleValues[i].$1[0].y);

        if (a.x > b.x) {
          (a, b) = (b, a);
          (worldA, worldB) = (worldB, worldA);
          (normalA, normalB) = (normalB, normalA);
          (textureA, textureB) = (textureB, textureA);
        }

        // Нахождение коэффицентов изменения X в экранных и мировых координатах, коэффицента изменения нормали.
        final Vector4 coeff_ab = (b - a) / (b.x - a.x);
        final Vector4 coeff_world_ab = (worldB - worldA) / (b.x - a.x);
        final Vector3 coeff_texture_ab = (textureB - textureA) / (b.x - a.x);

        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenWidth - 1);
            x < maxX;
            x++) {
          final double xD = x.toDouble();

          final Vector4 p = a + coeff_ab * (xD - a.x);
          final Vector4 pWorld = worldA + coeff_world_ab * (xD - a.x);

          //TODO maybe problem in this part
          final int value = _deepnessBuffer[pos] + _deepnessBuffer2[pos];
          final List<Vector3> drawable =
              offsetBuffer.sublist(_deepnessBuffer[pos], value);

          final Vector3 pWorld3 = Vector3(pWorld.x, pWorld.y, pWorld.z);
          final Vector3 viewDirection =
              (SceneSettings.eye - pWorld3).normalized();

          final Vector3 texture =
              (textureA + coeff_texture_ab * (xD - a.x)) / p.w;

          //DIFFUSE BITMAP
          final Bitmap diffuseBitmap = _objectData['diffuse']!;
          Color color = AppColors.lightColor;

          final int xDif = (texture.x * (diffuseBitmap.width)).toInt();
          final int yDif = ((1 - texture.y) * (diffuseBitmap.height)).toInt();
          final indexDif = (yDif * diffuseBitmap.width + xDif) * 4;

          color = Color.fromARGB(
            diffuseBitmap.content[indexDif + 3],
            diffuseBitmap.content[indexDif],
            diffuseBitmap.content[indexDif + 1],
            diffuseBitmap.content[indexDif + 2],
          );
          color = blendColor(drawable, color);

          //SPECULAR BITMAP
          final Bitmap mirrorBitmap = _objectData['mirror']!;
          Color specular = AppColors.lightColor;
          final int xMir = (texture.x * (mirrorBitmap.width)).toInt();
          final int yMir = ((1 - texture.y) * (mirrorBitmap.height)).toInt();
          final indexMir = (yMir * mirrorBitmap.width + xMir) * 4;

          specular = Color.fromARGB(
            mirrorBitmap.content[indexMir + 3],
            mirrorBitmap.content[indexMir],
            mirrorBitmap.content[indexMir + 1],
            mirrorBitmap.content[indexMir + 2],
          );

          //NORMAL BITMAP
          final Bitmap normalBitmap = _objectData['normal']!;
          Vector3 normal = Vector3(1, 1, 1);
          Color normalColor;
          final int xNor = (texture.x * (normalBitmap.width)).toInt();
          final int yNor = ((1 - texture.y) * (normalBitmap.height)).toInt();
          final indexNor = (yNor * normalBitmap.width + xNor) * 4;
          normalColor = Color.fromARGB(
            normalBitmap.content[indexNor + 3],
            normalBitmap.content[indexNor],
            normalBitmap.content[indexNor + 1],
            normalBitmap.content[indexNor + 2],
          );
          normal = Vector3(
            normalColor.red.toDouble(),
            normalColor.green.toDouble(),
            normalColor.blue.toDouble(),
          );
          normal = (normal * 2 - Vector3(1, 1, 1)).normalized();

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

  (
    List<Vector4> triangle,
    Vector4 coef1,
    Vector4 coef2,
    Vector4 coef3,
  ) getValues(int index) {
    final List<Vector4> triangle = _entities.values.elementAt(index);

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

    final Vector4 coef1 =
        (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
    final Vector4 coef2 =
        (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
    final Vector4 coef3 =
        (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

    return (triangle, coef1, coef2, coef3);
  }

  Color blendColor(List<Vector3> sublist, Color destColor) {
    Color currColor = Color.fromARGB(
      destColor.alpha,
      destColor.red,
      destColor.green,
      destColor.blue,
    );

    int alphaValue;
    double alphaMultiplier;
    for (int i = 0, len = sublist.length; i < len; i++) {
      alphaMultiplier = (255 - currColor.alpha) / 255;
      alphaValue =
          (currColor.alpha + destColor.alpha * alphaMultiplier).toInt();

      currColor = Color.fromARGB(
        alphaValue,
        (currColor.red * currColor.alpha + destColor.red * alphaMultiplier) ~/
            alphaValue,
        (currColor.green * currColor.alpha +
                destColor.green * alphaMultiplier) ~/
            alphaValue,
        (currColor.blue * currColor.alpha + destColor.blue * alphaMultiplier) ~/
            alphaValue,
      );

      //A0 = Aa + Ab * (1 - Aa)
      //C0 = (Ca * Aa + Cb * Ab * (1 - Aa)) ~/ A0
    }

    return currColor;
  }

  List<Vector3> insertionSort(List<Vector3> arr) {
    final int length = arr.length;

    for (int i = 1; i < length; i++) {
      final Vector3 key = arr[i];
      int j = i - 1;

      while (j >= 0 && arr[j].z > key.z) {
        arr[j + 1] = arr[j];
        j--;
      }

      arr[j + 1] = key;
    }

    return arr;
  }

  List<int> ambientLightning(Color lightColor) {
    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (lightColor.red * _ambientFactor).toInt();
          case 1:
            return (lightColor.green * _ambientFactor).toInt();
          default:
            return (lightColor.blue * _ambientFactor).toInt();
        }
      },
      growable: false,
    );
  }

  List<int> diffuseLightning(double intensity, Color lightColor) {
    final double scalar = intensity * _diffuseFactor;

    return List.generate(
      4,
      (int index) {
        switch (index) {
          case 0:
            return (lightColor.red * scalar).toInt();
          case 1:
            return (lightColor.green * scalar).toInt();
          case 2:
            return (lightColor.blue * scalar).toInt();
          case 3:
          default:
            return (lightColor.alpha * scalar).toInt();
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
    final num temp = pow(rv, _glossFactor);

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
