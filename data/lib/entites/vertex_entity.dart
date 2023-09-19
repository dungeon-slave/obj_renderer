import 'geometric_vertex_entity.dart';
import 'texture_vertex_entity.dart';
import 'vertex_normal_entity.dart';

class VertexEntity {
  final GeometricVertexEntity? v;
  final TextureVertexEntity? vt;
  final NormalVertexEntity? vn;

  const VertexEntity({
    this.v,
    this.vt,
    this.vn,
  });
}
