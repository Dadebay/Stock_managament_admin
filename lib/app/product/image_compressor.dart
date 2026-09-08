import 'dart:typed_data';

import 'image_compressor_stub.dart'
    if (dart.library.js_interop) 'image_compressor_web.dart' as impl;

/// Result of shrinking a picked image before upload.
class CompressedImage {
  const CompressedImage(this.bytes, this.fileName);

  final Uint8List bytes;
  final String fileName;
}

/// Scales the image down to [maxSide] and re-encodes it as WebP so uploads stay
/// small (nginx rejects big bodies and the API stores WebP anyway).
///
/// Returns the original bytes unchanged when the platform cannot re-encode or
/// when the result would not be smaller.
Future<CompressedImage> compressImageForUpload(
  Uint8List bytes,
  String fileName, {
  int maxSide = 1280,
  double quality = 0.8,
}) =>
    impl.compressImageForUpload(bytes, fileName,
        maxSide: maxSide, quality: quality);
