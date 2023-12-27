import 'package:bitmap/bitmap.dart';
import 'package:core_ui/app_colors.dart';
import 'package:core_ui/enums/allowed_actions.dart';
import 'package:core_ui/widgets/app_custom_paint.dart';
import 'package:core_ui/widgets/keyboard_service.dart';
import 'package:data/data.dart';
import 'package:data/entities/face_entity.dart';
import 'package:data/matrix/vector_transformation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class RenderScreen extends StatefulWidget {
  final List<FaceEntity> _defaultFaces;
  final Map<String, Bitmap> _objectData;
  final List<Vector3> _fileNormals;

  final Map<AllowedActions, Vector3> _objectParameters =
      <AllowedActions, Vector3>{
    AllowedActions.scaling: Vector3(1, 1, 1),
    AllowedActions.translation: Vector3(0, 0, 0),
    AllowedActions.rotation: Vector3(0, 0, 0),
    AllowedActions.lightDirection: Vector3(-10, 0, -10),
  };
  final Vector3 lightDirection = Vector3(-10, 0, -10);
  final List<Vector4> world = <Vector4>[];
  final List<Vector3> normals = <Vector3>[];
  final List<Vector3> textures = <Vector3>[];

  RenderScreen({
    required List<FaceEntity> defaultFaces,
    required Map<String, Bitmap> objectData,
    required List<Vector3> fileNormals,
    super.key,
  })  : _defaultFaces = defaultFaces,
        _fileNormals = fileNormals,
        _objectData = objectData;

  @override
  _RenderScreenState createState() => _RenderScreenState();
}

class _RenderScreenState extends State<RenderScreen>
    with TickerProviderStateMixin {
  late Ticker _currTicker;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Container(
      color: AppColors.backGroundColor,
      child: AppCustomPaint(
        entities: _fetchVectors(
          size,
          widget._defaultFaces,
        ),
        world: widget.world,
        normals: widget.normals,
        textures: widget.textures,
        lightDirection:
            widget._objectParameters[AllowedActions.lightDirection]!,
        objectData: widget._objectData,
        fileNormals: widget._fileNormals,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }

  void _createTicker(LogicalKeyboardKey key) {
    _currTicker = createTicker(
      (_) {
        KeyboardService.keyHandler(key, widget._objectParameters);
        setState(() {});
      },
    )..start();
  }

  void _disposeTicker() {
    _currTicker.stop();
    _currTicker.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
        return true;
      }
      _createTicker(event.logicalKey);
    }
    if (event is KeyUpEvent) {
      _disposeTicker();
    }

    return true;
  }

  Map<int, List<Vector4>> _fetchVectors(
    Size size,
    List<FaceEntity> entities,
  ) {
    final Map<int, List<Vector4>> result = <int, List<Vector4>>{};

    for (int i = 0, length = entities.length; i < length; i++) {
      final (
        List<Vector4>,
        List<Vector4>,
        List<Vector3>,
        List<Vector3>
      ) result1 = VectorTransformation.transform(
        vertices: entities[i].vertices,
        translate: widget._objectParameters[AllowedActions.translation]!,
        scale: widget._objectParameters[AllowedActions.scaling]!,
        rotation: widget._objectParameters[AllowedActions.rotation]!,
        size: size,
      );

      result.addAll(
        {
          i: result1.$1,
        },
      );
      widget.world.addAll(result1.$2);
      widget.normals.addAll(result1.$3);
      widget.textures.addAll(result1.$4);
    }

    return result;
  }
}
