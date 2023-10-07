import 'package:core_ui/scene_settings.dart';
import 'package:vector_math/vector_math.dart';

abstract class TransformMatrix {
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
    return makeViewMatrix(
      SceneSettings.eye,
      SceneSettings.target,
      SceneSettings.up,
    );
  }

  static Matrix4 createPerspectiveMatrix() {
    return makePerspectiveMatrix(
      SceneSettings.fov,
      SceneSettings.aspect,
      SceneSettings.zNear,
      SceneSettings.zFar,
    );
  }

  static Matrix4 createViewPort(double width, double height) {
    return Matrix4(
      width / 2,
      0,
      0,
      0,
      0,
      -height / 2,
      0,
      0,
      0,
      0,
      1,
      0,
      SceneSettings.xMin + width / 2,
      SceneSettings.yMin + height / 2,
      0,
      1,
    );
  }
}
