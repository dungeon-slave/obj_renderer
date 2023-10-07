import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:core_ui/widgets/vertical_slider.dart';
import 'package:data/data.dart';
import 'package:data/entities/render_object_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:flutter/material.dart';

class AppCustomPaint extends StatefulWidget {
  final List<RenderObjectEntity> entities;

  const AppCustomPaint({
    required this.entities,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => AppCustomPaintState();
}

class AppCustomPaintState extends State<AppCustomPaint> {
  double scaleFactor = 1;
  double xPos = 0;
  double yPos = 0;
  double zPos = 0;
  double xRotation = 0;
  double yRotation = 0;
  double zRotation = 0;

  late Map<int, List<Vector4>> entities1 = _fetchVectors(Size(100, 100));

  Map<int, List<Vector4>> _fetchVectors(Size size) {
    final Map<int, List<Vector4>> result = <int, List<Vector4>>{};
    final Vector3 translate = Vector3(xPos, yPos, zPos);
    final Vector3 scale = Vector3(scaleFactor, scaleFactor, scaleFactor);

    for (RenderObjectEntity entity in widget.entities) {
      for (int j = 0; j < entity.faces.length; j++) {
        List<Vector4> currResult = VectorTransformation.transformToWorldSpace(
          face: entity.faces[j],
          translate: translate,
          scale: scale,
          width: size.width,
          height: size.height,
          xRotationRadians: xRotation,
          yRotationRadians: yRotation,
          zRotationRadians: zRotation,
        );
        result.addAll({j: currResult});
      }
    }

    return result;
  }

  void scaleHandler(double value) {
    scaleFactor = value;
    entities1 = _fetchVectors(Size(100, 100));

    setState(() {});
  }

  void translationHandler({double? xValue, double? yValue, double? zValue}) {
    xPos = xValue ?? xPos;
    yPos = yValue ?? yPos;
    zPos = zValue ?? zPos;
    entities1 = _fetchVectors(Size(100, 100));

    setState(() {});
  }

  void rotationHandler({double? xValue, double? yValue, double? zValue}) {
    xRotation = xValue ?? xRotation;
    yRotation = yValue ?? yRotation;
    zRotation = zValue ?? zRotation;
    entities1 = _fetchVectors(Size(100, 100));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              CustomPaint(
                size: size * 0.75,
                painter: AppCustomPainter(entities: entities1),
              ),
              //scaling
              VerticalSlider(
                scaleHandler,
                scaleFactor,
                1,
                2,
              ),
              //x translation
              VerticalSlider(
                (double value) => translationHandler(xValue: value),
                xPos,
                0,
                10,
              ),
              //y translation
              VerticalSlider(
                (double value) => translationHandler(yValue: value),
                yPos,
                0,
                10,
              ),
              //z translation
              VerticalSlider(
                (double value) => translationHandler(zValue: value),
                zPos,
                0,
                10,
              ),
            ],
          ),
          Row(
            children: [
              //x rotation
              VerticalSlider(
                (double value) => rotationHandler(xValue: value),
                xRotation,
                0,
                3.14,
              ),
              //y rotation
              VerticalSlider(
                (double value) => rotationHandler(yValue: value),
                yRotation,
                0,
                3.14,
              ),
              //z rotation
              VerticalSlider(
                (double value) => rotationHandler(zValue: value),
                zRotation,
                0,
                3.14,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
