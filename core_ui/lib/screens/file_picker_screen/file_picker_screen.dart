import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core_ui/app_text_style.dart';
import 'package:core_ui/core_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerScreen extends StatelessWidget {
  const FilePickerScreen({super.key});

  void _tapHandler(NavigatorState navigatorState) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      Uint8List bytes = result.files.first.bytes == null
          ? await File(result.files.first.path!).readAsBytes()
          : result.files.first.bytes!;
      String rawContent = utf8.decode(bytes);

      navigatorState.push(
        MaterialPageRoute(
          builder: (_) => RenderScreen(
            rawContent: rawContent,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    NavigatorState navigatorState = Navigator.of(context);

    return SizedBox(
      child: ElevatedButton(
        onPressed: () => _tapHandler(navigatorState),
        child: const Text(
          'Tap to select .obj file',
          style: appTextStyle,
        ),
      ),
    );
  }
}
