import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart' as imglib;

// for IOS
// static imglib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
//   return imglib.Image.fromBytes(
//     width: cameraImage.planes[0].width!,
//     height: cameraImage.planes[0].height!,
//     bytes: cameraImage.planes[0].bytes.buffer,
//     order: imglib.ChannelOrder.bgra,
//   );
// }

imglib.Image convertYUV420ToImage(CameraImage cameraImage) {
  final imageWidth = cameraImage.width;
  final imageHeight = cameraImage.height;

  final yBuffer = cameraImage.planes[0].bytes;
  final uBuffer = cameraImage.planes[1].bytes;
  final vBuffer = cameraImage.planes[2].bytes;

  final int yRowStride = cameraImage.planes[0].bytesPerRow;
  final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

  final image = imglib.Image(width: imageWidth, height: imageHeight);

  for (int h = 0; h < imageHeight; h++) {
    int uvh = (h / 2).floor();

    for (int w = 0; w < imageWidth; w++) {
      int uvw = (w / 2).floor();

      final yIndex = (h * yRowStride) + (w * yPixelStride);

      // Y plane should have positive values belonging to [0...255]
      final int y = yBuffer[yIndex];

      // U/V Values are subsampled i.e. each pixel in U/V chanel in a
      // YUV_420 image act as chroma value for 4 neighbouring pixels
      final int uvIndex = (uvh * uvRowStride) + (uvw * uvPixelStride);

      // U/V values ideally fall under [-0.5, 0.5] range. To fit them into
      // [0, 255] range they are scaled up and centered to 128.
      // Operation below brings U/V values to [-128, 127].
      final int u = uBuffer[uvIndex];
      final int v = vBuffer[uvIndex];

      // Compute RGB values per formula above.
      int r = (y + v * 1436 / 1024 - 179).round();
      int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
      int b = (y + u * 1814 / 1024 - 227).round();

      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      // Use 255 for alpha value, no transparency.
      image.setPixelRgb(w, h, r, g, b);
    }
  }

  return image;
}

InputImage convertCameraImageToInputImage(CameraImage image) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final inputImageData = InputImageMetadata(
    // bytes: bytes,
    // inputImageData: InputImageData(
    size: Size(image.width.toDouble(), image.height.toDouble()),
    rotation: _getRotation(image),
    format: InputImageFormat.nv21,
    bytesPerRow: image.planes[0].bytesPerRow, // Assuming the format is NV21
  );
  final inputImage = InputImage.fromBytes(
    bytes: bytes,
    metadata: inputImageData,
  );

  return inputImage;
}

InputImageRotation _getRotation(CameraImage image) {
  switch (image.planes[0].bytes[1]) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    default:
      return InputImageRotation.rotation270deg;
  }
}
