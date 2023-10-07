import 'package:data/entities/face_entity.dart';
import 'package:data/entities/vertex_entity.dart';
import 'package:data/matrix/transform_matrix.dart';
import 'package:vector_math/vector_math.dart';

abstract class VectorTransformation {
  static List<Vector4> transformToWorldSpace({
    required FaceEntity face,
    required Vector3 translate,
    required Vector3 scale,
    required double width,
    required double height,
    required double xRotationRadians,
    required double yRotationRadians,
    required double zRotationRadians,
  }) {
    final List<Vector4> vectors = <Vector4>[];

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

    // final Matrix4 model = Matrix4.compose(
    //   translate,
    //   //Quaternion(0, 0, 0, 0),
    //   Quaternion.fromRotation(
    //     Matrix3.rotationX(0),
    //   ),
    //   scale,
    // );

    final Matrix4 model = TransformMatrix.translateMatrix(translate) *
        TransformMatrix.xRotationMatrix(xRotationRadians) *
        TransformMatrix.yRotationMatrix(yRotationRadians) *
        TransformMatrix.zRotationMatrix(zRotationRadians) *
        TransformMatrix.scaleMatrix(scale);
    //Matrix4 perspective = TransformMatrix.createPerspectiveMatrix();

    final Matrix4 result = TransformMatrix.createViewPort(
          100,
          100,
        ) *
        TransformMatrix.createPerspectiveMatrix() *
        TransformMatrix.createViewMatrix() *
        model;

    // result = model * TransformMatrix.createViewMatrix() * TransformMatrix.createPerspectiveMatrix() * TransformMatrix.createViewPort();
    //matrix *

    //TODO: if we add rotateMatrix it then multiplication should look like this -> scaleMatrix * rotateMatrix * translateMatrix

    final List<dynamic> vecResult = vectors.map(
      (Vector4 vector) {
        Vector4 result1;
        result1 = result * vector;

        return result1 / vector.w;
      },
    ).toList();

    return vecResult.cast<Vector4>();
  }
}
