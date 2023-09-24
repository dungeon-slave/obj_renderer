import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:data/entities/render_object_entity.dart';
import 'package:flutter/cupertino.dart';

class AppCustomPaint extends StatelessWidget {
  final List<RenderObjectEntity> entities;

  const AppCustomPaint({
    required this.entities,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: size * 0.75,
        painter: AppCustomPainter(entities: entities),
      ),
    );
  }
}
