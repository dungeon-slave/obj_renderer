import 'package:core_ui/app_text_style.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String _text;

  const AppLoader({
    required String text,
    super.key,
  }) : _text = text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox.square(
          dimension: size.aspectRatio * size.height / 3,
          child: const CircularProgressIndicator(
            color: Colors.black,
            strokeWidth: 30,
          ),
        ),
        SizedBox(
          height: size.height / 10,
        ),
        Text(
          _text,
          style: appTextStyle,
        ),
      ],
    );
  }
}
