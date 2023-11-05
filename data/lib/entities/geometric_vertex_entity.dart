import '../data.dart';

class GeometricVertexEntity {
  final double x;
  final double y;
  final double z;
  final double w;

  const GeometricVertexEntity({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
  });

  Vector4 toVector4() {
    return Vector4(x, y, z, w);
  }
}
