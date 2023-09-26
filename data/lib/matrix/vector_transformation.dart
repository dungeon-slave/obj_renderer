import 'package:data/entities/face_entity.dart';
import 'package:data/entities/vertex_entity.dart';
import 'package:vector_math/vector_math.dart';

abstract class VectorTransformation {
  static List<Vector4> transformToWorldSpace({
    required List<FaceEntity> faces,
    required Vector3 translate,
    required Vector3 scale,
  }) {
    final List<Vector4> vectors = <Vector4>[];

    for (FaceEntity face in faces) {
      for (VertexEntity vertex in face.vertices) {
        vectors.add(
          Vector4(
            vertex.v!.x,
            vertex.v!.y,
            vertex.v!.z,
            vertex.v!.w,
          ),
        );
      }
    }

    final Matrix4 matrix = Matrix4.compose(
      translate,
      Quaternion.fromRotation(
        Matrix3.columns(
          Vector3(1, 0, 0),
          Vector3(0, 1, 0),
          Vector3(0, 0, 1),
        ),
      ),
      scale * 3,
    );

    //TODO: if we add rotateMatrix it then multiplication should look like this -> scaleMatrix * rotateMatrix * translateMatrix

    final List<dynamic> result =
        vectors.map((Vector4 vector) => matrix * vector).toList();

    return result.cast<Vector4>();
  }
}
