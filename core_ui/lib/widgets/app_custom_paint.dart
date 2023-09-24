import 'package:flutter/cupertino.dart';

class AppCustomPaint extends StatelessWidget {
  const AppCustomPaint({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: CustomPaint(
        size: size * 0.75,
      ),
    );
  }
}
