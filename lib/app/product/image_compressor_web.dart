import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'image_compressor.dart';

/// Draws the image on a canvas at a bounded size and asks the browser for a
/// WebP blob. Every failure path falls back to the original bytes.
Future<CompressedImage> compressImageForUpload(
  Uint8List bytes,
  String fileName, {
  int maxSide = 1280,
  double quality = 0.8,
}) async {
  String? objectUrl;
  try {
    final blob = web.Blob(
      <JSUint8Array>[bytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/*'),
    );
    objectUrl = web.URL.createObjectURL(blob);

    final image = web.HTMLImageElement();
    final loaded = Completer<bool>();
    image.addEventListener(
        'load',
        (web.Event _) {
          if (!loaded.isCompleted) loaded.complete(true);
        }.toJS);
    image.addEventListener(
        'error',
        (web.Event _) {
          if (!loaded.isCompleted) loaded.complete(false);
        }.toJS);
    image.src = objectUrl;
    if (!await loaded.future) {
      return CompressedImage(bytes, fileName);
    }

    final width = image.naturalWidth;
    final height = image.naturalHeight;
    if (width == 0 || height == 0) return CompressedImage(bytes, fileName);

    final scale = width > height
        ? (width > maxSide ? maxSide / width : 1.0)
        : (height > maxSide ? maxSide / height : 1.0);
    final targetWidth = (width * scale).round();
    final targetHeight = (height * scale).round();

    final canvas = web.HTMLCanvasElement()
      ..width = targetWidth
      ..height = targetHeight;
    final context = canvas.getContext('2d') as web.CanvasRenderingContext2D?;
    if (context == null) return CompressedImage(bytes, fileName);
    context.drawImage(image, 0, 0, targetWidth.toDouble(),
        targetHeight.toDouble());

    final encoded = Completer<web.Blob?>();
    canvas.toBlob(
      (web.Blob? result) {
        if (!encoded.isCompleted) encoded.complete(result);
      }.toJS,
      'image/webp',
      quality.toJS,
    );
    final webpBlob = await encoded.future;
    if (webpBlob == null || webpBlob.size == 0) {
      return CompressedImage(bytes, fileName);
    }

    final buffer = await webpBlob.arrayBuffer().toDart;
    final webpBytes = buffer.toDart.asUint8List();
    // A browser without WebP encoding silently returns PNG, which can be
    // larger than the original - keep whichever is smaller.
    if (webpBytes.length >= bytes.length) {
      return CompressedImage(bytes, fileName);
    }
    return CompressedImage(webpBytes, _webpName(fileName));
  } catch (_) {
    return CompressedImage(bytes, fileName);
  } finally {
    if (objectUrl != null) web.URL.revokeObjectURL(objectUrl);
  }
}

String _webpName(String fileName) {
  final dot = fileName.lastIndexOf('.');
  final base = dot > 0 ? fileName.substring(0, dot) : fileName;
  return '$base.webp';
}
