import 'package:core_ui/widgets/app_button.dart';
import 'package:core_ui/widgets/app_custom_paint.dart';
import 'package:core_ui/widgets/app_loader.dart';
import 'package:data/entities/render_object_entity.dart';
import 'package:data/parser/obj_parser.dart';
import 'package:flutter/material.dart';

class RenderScreen extends StatelessWidget {
  final String _rawContent;

  const RenderScreen({
    required String rawContent,
    super.key,
  }) : _rawContent = rawContent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: FutureBuilder<List<RenderObjectEntity>>(
        future: Future(() => ObjParser().parseContent(_rawContent)),
        builder: (_, AsyncSnapshot<List<RenderObjectEntity>> snapshot) {
          if (snapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AppCustomPaint(entities: snapshot.data!),
                const AppButton(text: 'Back to picking')
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
}
