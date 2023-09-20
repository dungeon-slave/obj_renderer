import 'package:flutter/material.dart';

class PickerScreen extends StatelessWidget {
  final void Function() _handler;

  const PickerScreen({
    required void Function() handler,
    super.key,
  }) : _handler = handler;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _handler,
      child: const Flexible(
        child: Text(
          'Tap to select .obj file',
          style: TextStyle(
            fontSize: 30,
            decoration: TextDecoration.none,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
