import 'dart:typed_data';

import 'image_compressor.dart';

/// Non-web platforms rely on image_picker's own resizing, so the bytes are
/// passed through untouched.
Future<CompressedImage> compressImageForUpload(
  Uint8List bytes,
  String fileName, {
  int maxSide = 1280,
  double quality = 0.8,
}) async =>
    CompressedImage(bytes, fileName);
