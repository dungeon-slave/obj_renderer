import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:data/data.dart';
import 'package:data/entities/render_object_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:flutter/cupertino.dart';

class AppCustomPaint extends StatelessWidget {
  final List<RenderObjectEntity> entities;

  const AppCustomPaint({
    required this.entities,
    super.key,
  });

  List<Vector4> _fetchVectors() {
    List<Vector4> result = <Vector4>[];

    for (RenderObjectEntity entity in entities) {
      List<Vector4> currResult = VectorTransformation.transformToWorldSpace(
        faces: entity.faces,
        translate: Vector3(200, 200, 0),
        scale: Vector3(50, 50, 50),
      );
      result.addAll(currResult);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    List<Vector4> entities1 = _fetchVectors();

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: size * 0.75,
        painter: AppCustomPainter(entities: entities1),
      ),
    );
  }
}
