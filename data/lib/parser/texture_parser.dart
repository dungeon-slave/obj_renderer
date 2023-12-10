import 'dart:io';
import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/cupertino.dart';

abstract class TextureParser {
  static Future<Map<String, Uint8List>> parseTexture({
    required String normalPath,
    required String mirrorPath,
    required String diffusePath,
  }) {
    return Future<Map<String, Uint8List>>(
      () async {
        return {
          'diffuse': await _parseTextureFile(diffusePath),
          'mirror': await _parseTextureFile(mirrorPath),
          'normal': await _parseTextureFile(diffusePath),
        };
      },
    );
  }

  static Future<Uint8List> _parseTextureFile(String path) async {
    final ImageProvider textureProvider = Image.file(File(path)).image;
    final Bitmap bitmap = await Bitmap.fromProvider(textureProvider);

    print('taeasd');
    return bitmap.content;
  }
}
