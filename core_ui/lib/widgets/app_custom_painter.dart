import 'package:data/entities/render_object_entity.dart';
import 'package:flutter/material.dart';

class AppCustomPainter extends CustomPainter {
  final List<RenderObjectEntity> entities;

  AppCustomPainter({
    required this.entities,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}