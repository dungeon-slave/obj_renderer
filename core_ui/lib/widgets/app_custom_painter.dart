import 'dart:math';

import 'package:core_ui/app_colors.dart';
import 'package:core_ui/core_ui.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final Map<int, List<Vector4>> _entities;
  final List<Vector4> _world;
  final List<Vector3> _normals;
  final List<Vector3> _textures;
  final Paint _paint = Paint();
  final Size _screenSize;
  final double _dotSize = 1;
  final Vector3 _lightDirection;

  Map<Vector3, List<Vector3>> triangleNormals = <Vector3, List<Vector3>>{};
  Map<Vector3, Vector3> vertexNormals = <Vector3, Vector3>{};

  double ambientFactor = 0.1;
  double diffuseFactor = 30;
  double specularFactor = 100;
  double glossFactor = 50;

  AppCustomPainter({
    required Map<int, List<Vector4>> entities,
    required List<Vector4> world,
    required List<Vector3> normals,
    required List<Vector3> textures,
    required Size screenSize,
    required Vector3 lightDirection,
  })  : _entities = entities,
        _screenSize = screenSize,
        _normals = normals,
        _textures = textures,
        _lightDirection = lightDirection,
        _world = world;

  @override
  void paint(Canvas canvas, _) {
    List<double?> zBuffer = List.filled(
      (_screenSize.height.toInt()) * (_screenSize.width.toInt()),
      null,
      growable: false,
    );

    //findNormals();

    for (int i = 0, length = _entities.values.length; i < length - 3; i++) {
      final List<Vector4> triangle = _entities.values.elementAt(i);
      int pos = i * 3;
      final List<Vector4> triangleWorld = _world.sublist(pos, pos + 3);
      final List<Vector3> normals = _normals.sublist(pos, pos + 3);
      final List<Vector3> textures = _textures.sublist(pos, pos + 3);

      // Формирование треугольников в экранных и мировых координатах
      // Vector4 edge1World = triangleWorld[1] - triangleWorld[0];
      // Vector4 edge2World = triangleWorld[2] - triangleWorld[0];

      Vector4 edge1 = triangle[1] - triangle[0];
      Vector4 edge2 = triangle[2] - triangle[0];

      // Vector3 normalWorld = Vector3(
      //   edge1World.y * edge2World.z - edge1World.z * edge2World.y,
      //   edge1World.z * edge2World.x - edge1World.x * edge2World.z,
      //   edge1World.x * edge2World.y - edge1World.y * edge2World.x,
      // ).normalized();

      final Vector3 normal = Vector3(
        edge1.y * edge2.z - edge1.z * edge2.y,
        edge1.z * edge2.x - edge1.x * edge2.z,
        edge1.x * edge2.y - edge1.y * edge2.x,
      ).normalized();

      // Отбраковка поверхностей

      if (normal.z >= 0) {
        continue;
      }

      // triangleWorld[0] *= triangle[0].w;
      // triangleWorld[1] *= triangle[1].w;
      // triangleWorld[2] *= triangle[2].w;

      // Поиск нормали по вершинам.
      Vector3 vertexNormal0 = normals[0].normalized() * triangle[0].w;
      Vector3 vertexNormal1 = normals[1].normalized() * triangle[1].w;
      Vector3 vertexNormal2 = normals[2].normalized() * triangle[2].w;

      Vector3 texture0 = textures[0] * triangle[0].w;
      Vector3 texture1 = textures[1] * triangle[1].w;
      Vector3 texture2 = textures[2] * triangle[2].w;

      // // Поиск нормали по вершинам треугольника
      // Vector3 vertexNormal0 = vertexNormals[
      //     Vector3(triangleWorld[0].x, triangleWorld[0].y, triangleWorld[0].z)]!.normalized();
      // Vector3 vertexNormal1 = vertexNormals[
      //     Vector3(triangleWorld[1].x, triangleWorld[1].y, triangleWorld[1].z)]!.normalized();
      // Vector3 vertexNormal2 = vertexNormals[
      //     Vector3(triangleWorld[2].x, triangleWorld[2].y, triangleWorld[2].z)]!.normalized();

      // triangleWorld[0] *= triangle[0].w;
      // triangleWorld[1] *= triangle[1].w;
      // triangleWorld[2] *= triangle[2].w;

      // Инетнсивность света для 2ой лабы
      // Vector3 lightDirection = Vector3(-1, -1, -1).normalized();
      // double intensity = max(normalWorld.dot(-lightDirection), 0);
      //
      // List<int> ambientValues = ambientLightning();
      // List<int> diffuseValues = diffuseLightning(intensity);

      // _paint.color = Color.fromARGB(
      //   255,
      //   (AppColors.vertexColor.red * intensity).toInt(),
      //   (AppColors.vertexColor.green * intensity).toInt(),
      //   (AppColors.vertexColor.blue * intensity).toInt(),
      // );

      // _paint.color = Color.fromARGB(
      //   255,
      //   min(ambientValues[0] + diffuseValues[0], 255),
      //   min(ambientValues[1] + diffuseValues[1], 255),
      //   min(ambientValues[2] + diffuseValues[2], 255),
      // );

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
      //
      // // Поиск нормали по вершинам треугольника
      // Vector3 vertexNormal0 = vertexNormals[
      //     Vector3(triangleWorld[0].x, triangleWorld[0].y, triangleWorld[0].z)]!.normalized();
      // Vector3 vertexNormal1 = vertexNormals[
      //     Vector3(triangleWorld[1].x, triangleWorld[1].y, triangleWorld[1].z)]!.normalized();
      // Vector3 vertexNormal2 = vertexNormals[
      //     Vector3(triangleWorld[2].x, triangleWorld[2].y, triangleWorld[2].z)]!.normalized();

      // Нахождение коэффицентов в экранных и мировых координатах и коэффицента для нормалей.
      Vector4 coefficient1 =
          (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
      Vector4 coefficient2 =
          (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
      Vector4 coefficient3 =
          (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

      Vector4 coefficient1World = (triangleWorld[1] - triangleWorld[0]) /
          (triangle[1].y - triangle[0].y);
      Vector4 coefficient2World = (triangleWorld[2] - triangleWorld[0]) /
          (triangle[2].y - triangle[0].y);
      Vector4 coefficient3World = (triangleWorld[2] - triangleWorld[1]) /
          (triangle[2].y - triangle[1].y);

      Vector3 coefficient1Normal =
          (vertexNormal1 - vertexNormal0) / (triangle[1].y - triangle[0].y);
      Vector3 coefficient2Normal =
          (vertexNormal2 - vertexNormal0) / (triangle[2].y - triangle[0].y);
      Vector3 coefficient3Normal =
          (vertexNormal2 - vertexNormal1) / (triangle[2].y - triangle[1].y);

      Vector3 coefficient1Texture =
          (texture1 - texture0) / (triangle[1].y - triangle[0].y);
      Vector3 coefficient2Texture =
          (texture2 - texture0) / (triangle[2].y - triangle[0].y);
      Vector3 coefficient3Texture =
          (texture2 - texture1) / (triangle[2].y - triangle[1].y);

      for (int minY = max(triangle[0].y.ceil(), 0),
              y = minY,
              maxY = min(triangle[2].y.ceil(), _screenSize.height.toInt() - 1);
          y < maxY;
          y++) {
        // Нахождение левого и правого Y
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

        double yD = y.toDouble();

        if (a.x > b.x) {
          (a, b) = (b, a);
          (worldA, worldB) = (worldB, worldA);
          (normalA, normalB) = (normalB, normalA);
          (textureA, textureB) = (textureB, textureA);
        }

        // Нахождение коэффицентов изменения X в экранных и мировых координатах, коэффицента изменения нормали.
        Vector4 coeff_ab = (b - a) / (b.x - a.x);
        Vector4 coeff_world_ab = (worldB - worldA) / (b.x - a.x);
        Vector3 coeff_normal_ab = (normalB - normalA) / (b.x - a.x);
        Vector3 coeff_texture_ab = (textureB - textureA) / (b.x - a.x);

        for (int minX = max(a.x.ceil(), 0),
                x = minX,
                maxX = min(b.x.ceil(), _screenSize.width.toInt() - 1);
            x < maxX;
            x++) {
          double xD = x.toDouble();

          Vector4 p = a + coeff_ab * (xD - a.x);
          Vector4 pWorld = worldA + coeff_world_ab * (xD - a.x);

          int width = _screenSize.width.toInt();
          int pos = y * width + x;
          if (zBuffer[pos] == null || zBuffer[pos]! > p.z) {
            zBuffer[pos] = p.z;

            final Vector3 pWorld3 = Vector3(pWorld.x, pWorld.y, pWorld.z);
            //final Vector3 lightDirection = Vector3(10, 0, -10).normalized();
            final Vector3 viewDirection =
                (SceneSettings.eye - pWorld3).normalized();

            final Vector3 texture =
                (textureA + coeff_texture_ab * (xD - a.x)) / p.w;

            final Vector3 n =
                (normalA + coeff_normal_ab * (xD - a.x)).normalized();

            final double intensity = max(n.dot(-_lightDirection), 0);

            // Затенение объекта в зависимости от дистанции света до модели.
            final double distance = _lightDirection.length2;
            final double attenuation = 1 / max(distance, 15);

            final List<int> ambientValues = ambientLightning();
            final List<int> diffuseValues =
                diffuseLightning(intensity * attenuation);
            final List<int> specularValues = specularLightning(
              viewDirection,
              _lightDirection,
              n,
            );

            _paint.color = Color.fromARGB(
              255,
              min(
                  AppColors.objectColor.red *
                      (ambientValues[0] +
                          diffuseValues[0] +
                          specularValues[0]) ~/
                      255,
                  255),
              min(
                  AppColors.objectColor.green *
                      (ambientValues[1] +
                          diffuseValues[1] +
                          specularValues[1]) ~/
                      255,
                  255),
              min(
                  AppColors.objectColor.blue *
                      (ambientValues[2] +
                          diffuseValues[2] +
                          specularValues[2]) ~/
                      255,
                  255),
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

  List<int> ambientLightning() {
    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (AppColors.lightColor.red * ambientFactor).toInt();
          case 1:
            return (AppColors.lightColor.green * ambientFactor).toInt();
          default:
            return (AppColors.lightColor.blue * ambientFactor).toInt();
        }
      },
      growable: false,
    );
  }

  List<int> diffuseLightning(double intensity) {
    final double scalar = intensity * diffuseFactor;

    return List.generate(
      3,
      (int index) {
        switch (index) {
          case 0:
            return (AppColors.lightColor.red * scalar).toInt();
          case 1:
            return (AppColors.lightColor.green * scalar).toInt();
          default:
            return (AppColors.lightColor.blue * scalar).toInt();
        }
      },
      growable: false,
    );
  }

  List<int> specularLightning(
    Vector3 view,
    Vector3 lightDirection,
    Vector3 normal,
  ) {
    final Vector3 reflection = (lightDirection).reflected(normal).normalized();
    final double rv = max(reflection.dot(view), 0);
    final num temp = pow(rv, glossFactor);

    return List.generate(
      3,
      (_) => (specularFactor * temp).toInt(),
      growable: false,
    );
  }

  void findNormals() {
    triangleNormals.clear();
    vertexNormals.clear();

    for (int i = 0, length = _entities.values.length; i < length - 3; i++) {
      int pos = i * 3;
      final List<Vector4> triangleWorld = _world.sublist(pos, pos + 3);

      Vector4 edge1World = triangleWorld[1] - triangleWorld[0];
      Vector4 edge2World = triangleWorld[2] - triangleWorld[0];

      Vector3 normalWorld = Vector3(
        edge1World.y * edge2World.z - edge1World.z * edge2World.y,
        edge1World.z * edge2World.x - edge1World.x * edge2World.z,
        edge1World.x * edge2World.y - edge1World.y * edge2World.x,
      ).normalized();

      for (final Vector4 vertex in triangleWorld) {
        final Vector3 tempVertex = Vector3(vertex.x, vertex.y, vertex.z);
        if (triangleNormals.containsKey(tempVertex)) {
          triangleNormals[tempVertex]!.add(normalWorld);
        } else {
          triangleNormals[tempVertex] = <Vector3>[normalWorld];
        }
      }
    }

    for (final item in triangleNormals.entries) {
      Vector3 temp = Vector3.zero();

      for (int i = 0; i < item.value.length; i++) {
        temp += item.value[i];
      }

      vertexNormals[item.key] = temp / item.value.length.toDouble();
    }
  }
}
