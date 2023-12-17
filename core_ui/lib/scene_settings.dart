import 'dart:math';

import 'package:data/data.dart';

abstract class SceneSettings {
  static final Vector3 eye = Vector3(0, 0, 500);
  static final Vector3 target = Vector3(0, 0, 0);
  static final Vector3 up = Vector3(0, 1, 0);

  static const double fov = pi / 2;
  static double getAspect(double width, double height) => width / height;
  static const double zFar = 100;
  static const double zNear = 0.1;

  static const double xMin = 0;
  static const double yMin = 0;
}
