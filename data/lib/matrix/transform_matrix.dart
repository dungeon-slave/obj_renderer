import 'package:vector_math/vector_math.dart';

class TransformMatrix {
  static final Vector3 _eye = Vector3(3, 3, 4);
  static final Vector3 _target = Vector3(4, 8, 2);
  static final Vector3 _up = Vector3(5, 10, 4);

  static const double _fov = 3;
  static const double _aspect = 4;
  static const double _zFar = 4;
  static const double _zNear = 1;

  static const double width = 10;
  static const double height = 10;

  static const double xMin = 1;
  static const double yMin = 1;

  static Matrix4 scaleMatrix(Vector3 scale) {
    return Matrix4.diagonal3(scale);
  }

  static Matrix4 translateMatrix(Vector3 translation) {
    return Matrix4.translation(translation);
  }

  static Matrix4 xRotationMatrix(double radians) {
    return Matrix4.rotationX(radians);
  }

  static Matrix4 yRotationMatrix(double radians) {
    return Matrix4.rotationY(radians);
  }

  static Matrix4 zRotationMatrix(double radians) {
    return Matrix4.rotationZ(radians);
  }

  static Matrix4 createViewMatrix() {
    return makeViewMatrix(_eye, _target, _up);
  }

  static Matrix4 createPerspectiveMatrix() {
    return makePerspectiveMatrix(_fov, _aspect, _zNear, _zFar);
  }

  static Matrix4 createViewPort() {
    return Matrix4(
        width/ 2, 0, 0, xMin + width/2,
        0, -height/2, 0, yMin + height/2,
        0, 0, 1, 0,
        0, 0, 0, 1,
    );
  }
}
