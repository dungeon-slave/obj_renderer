import '../entities/face_entity.dart';
import '../entities/geometric_vertex_entity.dart';
import '../entities/texture_vertex_entity.dart';
import '../entities/vertex_entity.dart';
import '../entities/vertex_normal_entity.dart';

class ObjParser {
  final List<RegExp> _faceRegExps = <RegExp>[
    RegExp(r'[0-9]+'),
    RegExp(r'[0-9]+(/[0-9]+)'),
    RegExp(r'[0-9]+(/[0-9]+){2}'),
  ];

  final List<GeometricVertexEntity> _vList = <GeometricVertexEntity>[];
  final List<TextureVertexEntity> _vtList = <TextureVertexEntity>[];
  final List<NormalVertexEntity> _vnList = <NormalVertexEntity>[];

  List<FaceEntity> parseContent(List<String> content) {
    final List<FaceEntity> faces = <FaceEntity>[];

    for (int i = 0, length = content.length; i < length; i++) {
      List<String> stringParts = content[i].split(' ');
      stringParts.removeWhere((element) => element == "");

      if(stringParts.isEmpty) {
        continue;
      }

      String startPart = stringParts[0];

      switch (startPart) {
        case 'v':
          {
            _vList.add(_parseGeometry(stringParts.sublist(1)));
            break;
          }
        case 'vt':
          {
            _vtList.add(_parseTexture(stringParts.sublist(1)));
            break;
          }
        case 'vn':
          {
            _vnList.add(_parseNormal(stringParts.sublist(1)));
            break;
          }
        case 'f':
          {
            faces.add(_parseFace(stringParts.sublist(1)));
            break;
          }
        default:
          {
            break;
          }
      }
    }

    return faces;
  }

  GeometricVertexEntity _parseGeometry(List<String> coords) {
    return GeometricVertexEntity(
      x: double.parse(coords[0]),
      y: double.parse(coords[1]),
      z: double.parse(coords[2]),
      w: coords.length > 3 ? double.parse(coords[3]) : 1,
    );
  }

  TextureVertexEntity _parseTexture(List<String> coords) {
    return TextureVertexEntity(
      u: double.parse(coords[0]),
      v: coords.length > 1 ? double.parse(coords[1]) : 0,
      w: coords.length > 2 ? double.parse(coords[2]) : 0,
    );
  }

  NormalVertexEntity _parseNormal(List<String> coords) {
    return NormalVertexEntity(
      i: double.parse(coords[0]),
      j: double.parse(coords[1]),
      k: double.parse(coords[2]),
    );
  }

  FaceEntity _parseFace(List<String> faceVertices) {
    List<VertexEntity> objectVertices = <VertexEntity>[];

    for (int i = 0, length = faceVertices.length; i < length; i++) {
      String vertex = faceVertices[i];
      List<String> vertexParts = vertex.split('/');

      objectVertices.add(
        VertexEntity(
          v: _faceRegExps[0].allMatches(vertex).isNotEmpty
              ? _vList[int.parse(vertexParts[0]) - 1]
              : null,
          vt: _faceRegExps[1].allMatches(vertex).isNotEmpty
              ? _vtList[int.parse(vertexParts[1]) - 1]
              : null,
          vn: _faceRegExps[2].allMatches(vertex).isNotEmpty
              ? _vnList[int.parse(vertexParts[2]) - 1]
              : null,
        ),
      );
    }

    return FaceEntity(vertices: objectVertices);
  }
}
