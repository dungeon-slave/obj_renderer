import 'package:core_ui/app_text_style.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String _text;

  const AppButton({
    required String text,
    super.key,
  }) : _text = text;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    NavigatorState navigatorState = Navigator.of(context);

    return GestureDetector(
      onTap: navigatorState.pop,
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
