import 'dart:io';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/cupertino.dart';

abstract class TextureParser {
  static Future<Map<String, Bitmap>> parseTexture({
    required String normalPath,
    required String mirrorPath,
    required String diffusePath,
  }) {
    return Future<Map<String, Bitmap>>(
      () async {
        return {
          'diffuse': await _parseTextureFile(diffusePath),
          'mirror': await _parseTextureFile(mirrorPath),
          'normal': await _parseTextureFile(diffusePath),
        };
      },
    );
  }

  static Future<Bitmap> _parseTextureFile(String path) async {
    final ImageProvider textureProvider = Image.file(File(path)).image;

    return await Bitmap.fromProvider(textureProvider);
  }
}
