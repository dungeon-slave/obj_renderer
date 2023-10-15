import 'package:core_ui/widgets/app_custom_painter.dart';
import 'package:data/data.dart';
import 'package:flutter/material.dart';

class AppCustomPaint extends StatefulWidget {
  final Map<int, List<Vector4>> _entities;
  final void Function(Size size) _setSize;

  const AppCustomPaint({
    required Map<int, List<Vector4>> entities,
    required void Function(Size size) setSize,
    super.key,
  })  : _entities = entities,
        _setSize = setSize;

  @override
  _AppCustomPaintState createState() => _AppCustomPaintState();
}

class _AppCustomPaintState extends State<AppCustomPaint> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    Size newSize = Size(size.width * 0.98, size.height * 0.6);

    Future(() => widget._setSize(newSize));

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: newSize,
        painter: AppCustomPainter(
          entities: widget._entities,
        ),
      ),
    );
  }
}
