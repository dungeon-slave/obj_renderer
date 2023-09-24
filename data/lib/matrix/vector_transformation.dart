import 'package:data/matrix/transform_matrix.dart';
import 'package:vector_math/vector_math.dart';

import '../entities/geometric_vertex_entity.dart';

class VectorTransformation {
  static void transformToWorldSpace(
    List<GeometricVertexEntity> values,
    Vector3 translate,
    Vector3 scale,
  ) {
    final List<Vector4> vectors = values
        .map((GeometricVertexEntity e) => Vector4(e.x, e.y, e.z, e.w))
        .toList();

    final Matrix4 scaleMatrix = TransformMatrix.scaleMatrix(scale);
    //TODO: add rotateMatrix = TransformMatrix.rotate{X or Y or Z}(value) here
    //also we should discuss later what params we will pass to transformToWorldSpace method
    final Matrix4 translateMatrix = TransformMatrix.translateMatrix(translate);

    final Matrix4 matrix = scaleMatrix * translateMatrix;
    //TODO: if we add rotateMatrix it then multiplication should look like this -> scaleMatrix * rotateMatrix * translateMatrix

    final List<Vector4> res = vectors
        .map((Vector4 vector) => matrix * vector)
        .toList() as List<Vector4>;
  }
}
