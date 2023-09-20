import 'package:flutter/material.dart';

class ParsingScreen extends StatelessWidget {
  final Future<bool> Function() _cancelHandler;

  const ParsingScreen({
    required Future<bool> Function() cancelHandler,
    super.key,
  }) : _cancelHandler = cancelHandler;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _cancelHandler,
      child: Container(
        color: Colors.blue,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.square(
              dimension: 150,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 20,
              ),
            ),
            SizedBox(
              height: 75,
            ),
            Text(
              'Your file is parsing',
              style: TextStyle(
                fontSize: 30,
                decoration: TextDecoration.none,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
