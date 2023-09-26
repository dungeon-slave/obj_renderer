import 'package:core_ui/app_text_style.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String _text;
  final void Function() _handler;

  const AppButton({
    required String text,
    required void Function() handler,
    super.key,
  })  : _text = text,
        _handler = handler;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: _handler,
      child: Container(
        height: size.height / 10,
        width: size.width * 0.75,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(width: 3),
        ),
        child: Text(
          _text,
          style: appTextStyle,
        ),
      ),
    );
  }
}
