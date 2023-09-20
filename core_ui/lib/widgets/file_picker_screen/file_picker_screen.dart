import 'dart:io';
import 'package:core_ui/widgets/file_picker_screen/components/parsing_screen.dart';
import 'package:core_ui/widgets/file_picker_screen/components/picker_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerState();
}

class _FilePickerState extends State<FilePickerScreen> {
  bool _isParsing = false;

  void _tapHandler() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    setState(() => _isParsing = true);

    if (result != null) {
      File file = File(result.files.single.path!);
    }
  }

  Future<bool> _cancelHandler() async {
    setState(() => _isParsing = false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isParsing) {
      return ParsingScreen(
        cancelHandler: _cancelHandler,
      );
    }
    return PickerScreen(handler: _tapHandler);
  }
}
