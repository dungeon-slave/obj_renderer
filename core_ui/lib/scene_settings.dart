import 'package:data/data.dart';

abstract class SceneSettings {
  static final Vector3 eye = Vector3(0, 0, 2);
  static final Vector3 target = Vector3(0, 0, 0);
  static final Vector3 up = Vector3(0, 1, 0);

  static const double fov = 0.8;
  static const double aspect = 1;
  static const double zFar = 100;
  static const double zNear = 0.1;

  static const double xMin = 0;
  static const double yMin = 0;
}
