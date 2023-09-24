import '../entities/face_entity.dart';
import '../entities/geometric_vertex_entity.dart';
import '../entities/render_object_entity.dart';
import '../entities/texture_vertex_entity.dart';
import '../entities/vertex_entity.dart';
import '../entities/vertex_normal_entity.dart';

class ObjParser {
  static const List<String> _objectKeywords = <String>[
    'o ',
    'v',
    'vn',
    'vt',
    'f',
  ];
  final List<RegExp> _faceRegExps = <RegExp>[
    RegExp(r'[0-9]+'),
    RegExp(r'[0-9]+(/[0-9]+)'),
    RegExp(r'[0-9]+(/[0-9]+){2}'),
  ];
  final List<GeometricVertexEntity> _vertexGeometrics =
      <GeometricVertexEntity>[];
  final List<TextureVertexEntity> _vertexTextures = <TextureVertexEntity>[];
  final List<NormalVertexEntity> _vertexNormales = <NormalVertexEntity>[];
  final List<FaceEntity> _faces = <FaceEntity>[];

  List<RenderObjectEntity> parseContent(String rawContent) {
    final List<RenderObjectEntity> renderObjects = <RenderObjectEntity>[];
    final List<String> content = rawContent.split('\n');
    String currObjName = "";

    for (int i = 0; i < content.length; i++) {
      if (content[i].startsWith(_objectKeywords[0])) {
        if (currObjName.isEmpty) {
          currObjName = (content[i].split(' ')..removeAt(0))[0];
        } else {
          renderObjects.add(_addObject(currObjName));
          currObjName = (content[i].split(' ')..removeAt(0))[0];
        }
      }
      if (content[i].startsWith(_objectKeywords[1])) {
        _vertexGeometrics.add(_parseGeometry(content[i]));
        continue;
      }
      if (content[i].startsWith(_objectKeywords[2])) {
        _vertexNormales.add(_parseNormal(content[i]));
        continue;
      }
      if (content[i].startsWith(_objectKeywords[3])) {
        _vertexTextures.add(_parseTexture(content[i]));
        continue;
      }
      if (content[i].startsWith(_objectKeywords[4])) {
        _faces.add(_parseFace(content[i]));
        continue;
      }
    }
    renderObjects.add(_addObject(currObjName));
    return renderObjects;
  }

  RenderObjectEntity _addObject(String name) {
    RenderObjectEntity result =
        RenderObjectEntity(name: name, faces: [..._faces]);
    _vertexGeometrics.clear();
    _vertexTextures.clear();
    _vertexNormales.clear();
    _faces.clear();
    return result;
  }

  GeometricVertexEntity _parseGeometry(String line) {
    List<String> coords = line.split(' ')..removeAt(0);
    return GeometricVertexEntity(
      x: double.parse(coords[0]),
      y: double.parse(coords[1]),
      z: double.parse(coords[2]),
      w: coords.length > 3 ? double.parse(coords[3]) : 1,
    );
  }

  NormalVertexEntity _parseNormal(String line) {
    List<String> coords = line.split(' ')..removeAt(0);
    return NormalVertexEntity(
      i: double.parse(coords[0]),
      j: double.parse(coords[1]),
      k: double.parse(coords[2]),
    );
  }

  TextureVertexEntity _parseTexture(String line) {
    List<String> coords = line.split(' ')..removeAt(0);
    return TextureVertexEntity(
      u: double.parse(coords[0]),
      v: coords.length > 1 ? double.parse(coords[1]) : 0,
      w: coords.length > 2 ? double.parse(coords[2]) : 0,
    );
  }

  FaceEntity _parseFace(String line) {
    List<String> faceVertices = line.split(' ')..removeAt(0);
    List<VertexEntity> objectVertices = <VertexEntity>[];
    for (String vertex in faceVertices) {
      List<String> vertexParts = vertex.split('/');
      objectVertices.add(
        VertexEntity(
          v: _faceRegExps[0].allMatches(vertex).isNotEmpty
              ? _vertexGeometrics[int.parse(vertexParts[0]) - 1]
              : null,
          vt: _faceRegExps[1].allMatches(vertex).isNotEmpty
              ? _vertexTextures[int.parse(vertexParts[1]) - 1]
              : null,
          vn: _faceRegExps[2].allMatches(vertex).isNotEmpty
              ? _vertexNormales[int.parse(vertexParts[2]) - 1]
              : null,
        ),
      );
    }
    return FaceEntity(vertices: objectVertices);
  }
}
