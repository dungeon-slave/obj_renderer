import 'package:data/entities/vertex_entity.dart';
import 'package:data/matrix/transform_matrix.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as math;

abstract class VectorTransformation {
  static List<math.Vector4> transform({
    required List<VertexEntity> vertices,
    required math.Vector3 translate,
    required math.Vector3 scale,
    required math.Vector3 rotation,
    required Size size,
  }) {
    final List<math.Vector4> vectors = <math.Vector4>[];

    for (VertexEntity vertex in vertices) {
      if (vertex.v == null) {
        continue;
      }
      vectors.add(
        math.Vector4(
          vertex.v!.x,
          vertex.v!.y,
          vertex.v!.z,
          vertex.v!.w,
        ),
      );
    }

    final math.Matrix4 model = TransformMatrix.translateMatrix(translate) *
        TransformMatrix.xRotationMatrix(rotation.x) *
        TransformMatrix.yRotationMatrix(rotation.y) *
        TransformMatrix.zRotationMatrix(rotation.z) *
        TransformMatrix.scaleMatrix(scale);

    // final math.Matrix4 result = TransformMatrix.createViewPort(
    //       size.width,
    //       size.height,
    //     ) *
    //     TransformMatrix.createPerspectiveMatrix() *
    //     TransformMatrix.createViewMatrix() *
    //     model;

    //model * vector
    //view * newVector
    //perspective * newVector2
    //newVector2 / newVector2.w
    //viewPort * newVector3

    final List<math.Vector4> vecResult = vectors.map<math.Vector4>(
      (math.Vector4 vector) {
        final newVector = model * vector;
        final viewMatrix = TransformMatrix.createViewMatrix();
        final newVector2 = viewMatrix * newVector;

        final perspectiveMatrix = TransformMatrix.createPerspectiveMatrix();
        final newVector3 = perspectiveMatrix * newVector2;
        final newVector4 = newVector3 / newVector3.w;

        final viewPort = TransformMatrix.createViewPort(
          size.width,
          size.height,
        );
        final newVector5 = viewPort * newVector4;

        return newVector5;
      } /*result * vector / vector.w*/,
    ).toList();

    return vecResult;
  }
}
