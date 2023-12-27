import 'package:data/entities/vertex_entity.dart';
import 'package:data/matrix/transform_matrix.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

abstract class VectorTransformation {
  static (
    List<math.Vector4> viewPort,
    List<math.Vector4> world,
    List<math.Vector3> normals,
    List<math.Vector3> textures,
  ) transform({
    required List<VertexEntity> vertices,
    required math.Vector3 translate,
    required math.Vector3 scale,
    required math.Vector3 rotation,
    required Size size,
  }) {
    final List<math.Vector3> textures = List.filled(
      vertices.length,
      math.Vector3.zero(),
    );
    final List<math.Vector4> world = List.filled(
      vertices.length,
      math.Vector4.zero(),
    );
    final List<math.Vector4> vectors = List.filled(
      vertices.length,
      math.Vector4.zero(),
    );
    final List<math.Vector3> normals = List.filled(
      vertices.length,
      math.Vector3.zero(),
    );

    final math.Matrix4 model = TransformMatrix.translateMatrix(translate) *
        TransformMatrix.xRotationMatrix(rotation.x) *
        TransformMatrix.yRotationMatrix(rotation.y) *
        TransformMatrix.zRotationMatrix(rotation.z) *
        TransformMatrix.scaleMatrix(scale);
    final math.Matrix4 perspectiveMatrix =
        TransformMatrix.createPerspectiveMatrix(
      size.width,
      size.height,
    );
    final math.Matrix4 viewMatrix = TransformMatrix.createViewMatrix();
    final math.Matrix4 viewPort = TransformMatrix.createViewPort(
      size.width,
      size.height,
    );

    for (int i = 0, len = vertices.length; i < len; i++) {
      final worldVector = model *
          math.Vector4(
            vertices[i].v!.x,
            vertices[i].v!.y,
            vertices[i].v!.z,
            vertices[i].v!.w,
          );
      final viewPortVector = perspectiveMatrix * viewMatrix * worldVector;
      final viewVectorEnd = viewPort * viewPortVector / viewPortVector.w;

      vectors[i] = viewVectorEnd;
      world[i] = worldVector;
      normals[i] = model *
          math.Vector3(
            vertices[i].vn!.i,
            vertices[i].vn!.j,
            vertices[i].vn!.k,
          );
      textures[i] = math.Vector3(
        vertices[i].vt!.u,
        vertices[i].vt!.v,
        vertices[i].vt!.w,
      );
    }

    return (vectors, world, normals, textures);
  }
}
