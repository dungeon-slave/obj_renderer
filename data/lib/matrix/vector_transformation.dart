import 'package:data/entities/vertex_entity.dart';
import 'package:data/matrix/transform_matrix.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

abstract class VectorTransformation {
  //TODO: rename because we transform not only in world space (or separate)
  static List<math.Vector4> transformToWorldSpace({
    required List<VertexEntity> vertices,
    required math.Vector3 translate,
    required math.Vector3 scale,
    required math.Vector3 rotation,
    required Size size,
  }) {
    final List<math.Vector4> vectors = <math.Vector4>[];

    for (VertexEntity vertex in vertices) {
      vectors.add(
        math.Vector4(
          vertex.v!.x,
          vertex.v!.y,
          vertex.v!.z,
          vertex.v!.w,
        ),
      );
    }

    final math.Matrix4 model = TransformMatrix.scaleMatrix(scale) *
        TransformMatrix.xRotationMatrix(rotation.x) *
        TransformMatrix.yRotationMatrix(rotation.y) *
        TransformMatrix.zRotationMatrix(rotation.z) *
        TransformMatrix.translateMatrix(translate);

    final math.Matrix4 result = TransformMatrix.createViewPort(
          size.width,
          size.height,
        ) *
        TransformMatrix.createPerspectiveMatrix() *
        TransformMatrix.createViewMatrix() *
        model;

    final List<math.Vector4> vecResult = vectors
        .map<math.Vector4>(
          (math.Vector4 vector) => result * vector / vector.w,
        )
        .toList();

    return vecResult;
  }
}
