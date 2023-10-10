import 'package:core_ui/widgets/app_button.dart';
import 'package:core_ui/widgets/app_custom_paint.dart';
import 'package:core_ui/widgets/app_loader.dart';
import 'package:core_ui/widgets/render_controls.dart';
import 'package:data/data.dart' hide Colors;
import 'package:data/entities/render_object_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:data/parser/obj_parser.dart';
import 'package:flutter/material.dart';

class RenderScreen extends StatefulWidget {
  final String _rawContent;

  const RenderScreen({
    required String rawContent,
    super.key,
  }) : _rawContent = rawContent;

  @override
  _RenderScreenState createState() => _RenderScreenState();
}

class _RenderScreenState extends State<RenderScreen> {
  Vector3 _position = Vector3(0, 0, 0);
  Vector3 _scale = Vector3(1, 1, 1);
  Vector3 _rotation = Vector3(0, 0, 0);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      color: Colors.blue,
      child: FutureBuilder<List<RenderObjectEntity>>(
        future: Future(() => ObjParser().parseContent(widget._rawContent)),
        builder: (_, AsyncSnapshot<List<RenderObjectEntity>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AppCustomPaint(
                  entities: _fetchVectors(
                    Size(size.width, size.height),
                    snapshot.data!,
                  ),
                ),
                RenderControls(
                  scaleHandler: _scaleHandler,
                  translationHandler: _translationHandler,
                  rotationHandler: _rotationHandler,
                  scale: _scale,
                  position: _position,
                  rotation: _rotation,
                ),
                AppButton(
                  text: 'Back to picking',
                  handler: Navigator.of(context).pop,
                ),
              ],
            );
          }
          return const AppLoader(
            text: 'Your file is parsing',
          );
        },
      ),
    );
  }

  Map<int, List<Vector4>> _fetchVectors(
    Size size,
    List<RenderObjectEntity> entities,
  ) {
    final Map<int, List<Vector4>> result = <int, List<Vector4>>{};

    for (RenderObjectEntity entity in entities) {
      for (int j = 0; j < entity.faces.length; j++) {
        result.addAll(
          {
            j: VectorTransformation.transform(
              vertices: entity.faces[j].vertices,
              translate: _position,
              scale: _scale,
              rotation: _rotation,
              size: size,
            ),
          },
        );
      }
    }

    return result;
  }

  void _scaleHandler(double value) {
    _scale = Vector3.all(value);
    setState(() {});
  }

  void _translationHandler({double? xValue, double? yValue, double? zValue}) {
    _position = Vector3(
      xValue ?? _position.x,
      yValue ?? _position.y,
      zValue ?? _position.z,
    );
    setState(() {});
  }

  void _rotationHandler({double? xValue, double? yValue, double? zValue}) {
    _rotation = Vector3(
      xValue ?? _rotation.x,
      yValue ?? _rotation.y,
      zValue ?? _rotation.z,
    );
    setState(() {});
  }
}
