import 'package:core_ui/widgets/file_picker_screen/file_picker_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FilePickerScreen(),
    );
  }
}
