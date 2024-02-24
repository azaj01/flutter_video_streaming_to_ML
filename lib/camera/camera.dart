import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app/style.dart' as style;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image/image.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as imglib;

class Throttler {
  Throttler({required this.milliSeconds});

  final int milliSeconds;

  int? lastActionTime;

  void run(VoidCallback action) {
    if (lastActionTime == null) {
      action();
      lastActionTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      if (DateTime.now().millisecondsSinceEpoch - lastActionTime! >
          (milliSeconds)) {
        action();
        lastActionTime = DateTime.now().millisecondsSinceEpoch;
      }
    }
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final supabase = Supabase.instance.client;
  String shopName = ''; // Variable to store the shop name
  String barcode = '';
  late CameraController controller;
  late Throttler throttler;
  late StreamSubscription<int> timer;
  String ipML = "192.168.1.160"; // Use the server IP here
  int portML = 80; // Use the server port here
  late IO.Socket socket = IO.io('http://$ipML:$portML', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  String connectionStatus = "Connecting...";
  String predictionText = "";
  late Timer _reconnectTimer;
  late Timer _imageSendTimer;
  bool _isCapturing =
      false; // Flag to track whether a picture is being captured
  bool _isUseAI = false; //
  bool _isUseBarcode = false; //
  late Timer _timer;

  late BarcodeScanner barcodeScanner;
  @override
  void initState() {
    super.initState();
    fetchShopName();
    throttler = Throttler(milliSeconds: 500);

    _initializeCamera();
    barcodeScanner = BarcodeScanner();
// Initialize socket connection with initial IP and port
    // _initializeSocket(ipML, portML);
    // _imageSendTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
    //   if (_isUseBarcode || _isUseAI) {
    //     _takeAndSendPicture();
    //   }
    // });

    setState(() {});
    const duration = Duration(milliseconds: 3000);
    _timer = Timer.periodic(duration, (timer) {
      if (!_isCapturing) {
        _isCapturing = true;
        controller.startImageStream((CameraImage image) {
          processImage(image);
        });
      }
    });
    // _controller.startImageStream(
    //   (CameraImage image) {
    //     if (!_isCapturing) {
    //       _isCapturing = true;
    //       processImage(image);
    //     }
    //   },
    // );
    _reconnectTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!socket.connected) {
        print('Attempting to reconnect...');
        _initializeSocket(ipML, portML);
      }
    });
  }

  // void _startImageStream() {
  //   const fps = 10; // Desired frames per second
  //   const frameDuration = Duration(milliseconds: (33));
  //   streamSubscription = Stream.periodic(frameDuration).listen((_) {
  //     if (!_isCapturing) {
  //       _isCapturing = true;
  //       _controller.startImageStream((CameraImage image) {
  //         streamSubscription
  //             .pause(); // Pause the stream while processing the image
  //         processImage(image);
  //       });
  //     }
  //   });
  // }

  void _initializeCamera() {
    // controller = CameraController(widget.cameras[0], ResolutionPreset.low);

    // controller.initialize().then((_) {
    //   if (!mounted) {
    //     return;
    //   }
    //   setState(() {});
    //   controller.startImageStream((CameraImage image) {
    //     if (!_isCapturing) {
    //       _isCapturing = true;
    //       processImage(image);
    //     }
    //   });
    // });
    controller = CameraController(widget.cameras[0], ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
      Future.delayed(const Duration(milliseconds: 500));

      // Only open and close camera in iOS for low-tier device
      if (Platform.isIOS) {
        timer = Stream.periodic(const Duration(milliseconds: 500), (v) => v)
            .listen((count) async {
          throttler.run(() async {
            controller.startImageStream((image) async {
              if (Platform.isIOS) {
                try {
                  await const MethodChannel('com.benamorn.liveness')
                      .invokeMethod<Uint8List>("checkLiveness", {
                    'platforms': image.planes.first.bytes,
                    'height': image.height,
                    'width': image.width,
                    "bytesPerRow": image.planes.first.bytesPerRow
                  });
                } on PlatformException catch (e) {
                  debugPrint(
                      "==== checkLiveness Method is not implemented ${e.message}");
                }
              }
            });

            Future.delayed(const Duration(milliseconds: 50), () async {
              await controller.stopImageStream();
            });
          });
        });
      } else {
        // For Android, we can open it all the time
        controller.startImageStream((image) async {
          throttler.run(() async {
            try {
              // Uint8List imageData = image.planes[1].bytes;

              // // Encode the image data to base64
              // String base64Image = base64Encode(imageData);

              // // Emit the base64 encoded image data to Python server
              // socket.emit('image', {'image': base64Image});
              // Convert the image bytes to Uint8List
              imglib.Image imageData = convertYUV420ToImage(image);
              final List<int> imageBytes = imglib.encodeJpg(imageData);

              // List<int> imageData = await convertImagetoPng(image);

              // Encode the image data to base64
              String base64Image = base64Encode(imageBytes);

              // Emit the base64 encoded image to the socket
              socket.emit('image', {'image': base64Image});

              // });
            } on PlatformException catch (e) {
              debugPrint(
                  "==== checkLiveness Method is not implemented ${e.message}");
            }
          });
        });
      }
    });

    // Future<List<int>> convertImagetoPng(CameraImage image) async {
    //   imglib.Image img;
    //   img = _convertYUV420(image);

    //   imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

    //   // Convert to png
    //   List<int> png = pngEncoder.encode(img);
    //   return png;
    // }
  }

  static imglib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    return imglib.Image.fromBytes(
      width: cameraImage.planes[0].width!,
      height: cameraImage.planes[0].height!,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: imglib.ChannelOrder.bgra,
    );
  }

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

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black

  // Future<List<int>> convertImagetoPng(CameraImage image) async {
  //   imglib.Image img;
  //   img = _convertYUV420(image);

  //   imglib.PngEncoder pngEncoder = new imglib.PngEncoder();

  //   // Convert to png
  //   List<int> png = pngEncoder.encode(img);
  //   return png;
  // }

// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
// Black
  // imglib.Image _convertYUV420(CameraImage image) {
  //   var img = imglib.Image(
  //       width: image.width, height: image.height); // Create Image buffer

  //   Plane? plane = image.planes.isNotEmpty ? image.planes[0] : null;
  //   const int shift = (0xFF << 24);

  //   // Check if plane is not null
  //   if (plane != null) {
  //     // Fill image buffer with plane[0] from YUV420_888
  //     for (int x = 0; x < image.width; x++) {
  //       for (int planeOffset = 0;
  //           planeOffset < image.height * image.width;
  //           planeOffset += image.width) {
  //         final pixelColor = plane.bytes?[planeOffset + x] ?? 0;
  //         // color: 0x FF  FF  FF  FF
  //         //           A   B   G   R
  //         // Calculate pixel color
  //         var newVal =
  //             shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

  //         img.setPixelRgba(x, y, r, g, b, a)[planeOffset + x] = newVal;
  //       }
  //     }
  //   }

  //   return img;
  // }

  // Future<Uint8List> toJpg(CameraImage image) async {
  //   // Convert CameraImage to Image (using image package)
  //   img.Image convertedImage = img.Image.fromBytes(
  //     width: image.width,
  //     height: image.height,
  //     bytes: ,
  //   );

  Future<Uint8List> convertToUint8List(List<List<int>> bytes) async {
    List<int> flattenedBytes = bytes.expand((element) => element).toList();
    return Uint8List.fromList(flattenedBytes);
  }

  Future<Uint8List> getImageData(CameraImage image) async {
    List<int> bytes = [];
    for (Plane plane in image.planes) {
      bytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(bytes);
  }

//  Future<Uint8List> toJpg(CameraImage image) async {
//   // Convert CameraImage to Image (using image package)
//   img.Image convertedImage = img.Image(
//     width: image.width,
//     height: image.height,
//    b: Plane.channelColors.map((c) => image.planes[c].bytes).toList(),
//     format: Format.uint8, // Assuming BGRA format, adjust if necessary
//   );

//   // Encode image to JPG format
//   Uint8List jpgBytes = Uint8List.fromList(img.encodeJpg(convertedImage));
//   return jpgBytes;
// }
  // Future<Uint8List> convertCameraImageToJpg(
  //     CameraImage image, List<Uint8List> bytes) async {
  //   img.Image convertedImage = img.Image.(
  //     width: bytes[0].length, // Assume all planes have the same length
  //     height:
  //         bytes[0].length ~/ bytes.length, // Height based on number of planes
  //     bytes: bytes.expand((byteList) => byteList).toList(), // Flatten bytes
  //   );

  //   // Encode the image to JPG format
  //   Uint8List jpgBytes = Uint8List.fromList(img.encodeJpg(convertedImage));
  //   return jpgBytes;
  // }

  // Future<Uint8List> getImageData(CameraImage image) async {
  //   List<int> bytes = [];
  //   for (Plane plane in image.planes) {
  //     bytes.addAll(plane.bytes);
  //   }
  //   return Uint8List.fromList(bytes);
  // }

  Future<Uint8List> getImageBytes(CameraImage image) async {
    List<int> bytes = [];
    for (Plane plane in image.planes) {
      bytes.addAll(plane.bytes);
    }
    return Uint8List.fromList(bytes);
  }

  void _initializeSocket(String ip, int port) {
    socket.disconnect();
    socket.destroy();

    socket = IO.io('http://$ip:$port', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      setState(() {
        connectionStatus = 'Connected to server';
      });
    });
    socket.on('prediction', (data) {
      // Handle the predicted text received from Python
      String prediction = data['text'];
      print('Received prediction: $prediction');
      setState(() {
        predictionText = prediction;
      });
    });

    // Add listeners for other events as needed
  }

  void _attemptReconnect() {
    socket.connect(); // Reconnect to the server
  }

  void _sendImage(Uint8List imageBytes) {
    socket.emit('image', {'image': base64Encode(imageBytes)});
  }

  void processImage(CameraImage image) async {
    try {
      if (_isUseBarcode) {
        final barcode =
            await _readBarcode(image); // Read barcode from the captured image
        setState(() {
          this.barcode = barcode;
        });
      }
      if (_isUseAI) {
        // final Uint8List imageBytes = _convertImageToBytes(image);
        // final String base64Image = base64Encode(imageBytes);
        // socket.emit('image', {'image': base64Image});
      }

      // void _sendImage(Uint8List imageBytes) {
      //   socket.emit('image', {'image': base64Encode(imageBytes)});
      // }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      _isCapturing = false;
    }
  }

  // Uint8List _convertImageToBytes(CameraImage image) {
  //   late Uint8List bytes;
  //   if (image.format.group == ImageFormatGroup.yuv420) {
  //     // Convert YUV420 image to JPEG bytes
  //     // Here, we assume the YUV420 image is in NV21 format, you may need to adjust the conversion based on your camera format
  //     final planes = image.planes;
  //     final int width = image.width;
  //     final int height = image.height;
  //     final int uvStride = planes[1].bytesPerRow;
  //     final int uvHeight = height ~/ 2;
  //     bytes = Uint8List(width * height * 3 ~/ 2);
  //     int yIndex = 0;
  //     int uvIndex = 0;
  //     for (int i = 0; i < height; i++) {
  //       for (int j = 0; j < width; j++) {
  //         final int uvOffset = uvStride * (i ~/ 2) + (j ~/ 2) * 2;
  //         bytes[yIndex++] = planes[0].bytes[i * width + j];
  //         bytes[width * height + uvIndex++] = planes[1].bytes[uvOffset + 1];
  //         bytes[width * height + uvIndex++] = planes[1].bytes[uvOffset];
  //       }
  //     }
  //   }
  //   return bytes;
  // }
  // Uint8List _convertImageToBytes(CameraImage image) {
  //   late Uint8List bytes;
  //   print(image.format.group);
  //   if (image.format.group == ImageFormatGroup.yuv420) {
  //   final planes = image.planes;
  //   final int width = image.width;
  //   final int height = image.height;
  //   final int uvStride = planes[1].bytesPerRow;
  //   final int uvHeight = height ~/ 2;
  //   bytes = Uint8List(width * height * 3 ~/ 2);
  //   int yIndex = 0;
  //   int uvIndex = 0;
  //   for (int i = 0; i < height; i++) {
  //     for (int j = 0; j < width; j++) {
  //       bytes[yIndex++] = planes[0].bytes[i * width + j];
  //     }
  //   }
  //   for (int i = 0; i < uvHeight; i++) {
  //     for (int j = 0; j < width; j++) {
  //       bytes[width * height + uvIndex++] =
  //           planes[1].bytes[i * uvStride + j * 2];
  //       bytes[width * height + uvIndex++] =
  //           planes[1].bytes[i * uvStride + j * 2 + 1];
  //     }
  //   }
  //   }
  //   return bytes;
  // }

  //

  Uint8List _convertImageToBytes(CameraImage image) {
    // Convert YUV420 to RGB
    var width = image.width;
    var height = image.height;

    var uvRowStride = image.planes[1].bytesPerRow;
    var uvPixelStride = image.planes[1].bytesPerPixel;

    var data = image.planes[0].bytes;
    var dataU = image.planes[1].bytes;
    var dataV = image.planes[2].bytes;

    var imageSize = height * width;
    var uvSize = height * width ~/ 4;

    var bytes = Uint8List(imageSize * 3);

    var uvIndex = 0;

    for (var y = 0; y < height; y++) {
      var pYIndex = y * width;
      var pUVIndex = uvIndex;

      for (var x = 0; x < width; x++) {
        var uvIndex = pUVIndex + (x ~/ 2) * uvPixelStride!;

        var y = data[pYIndex++];
        var u = dataU[uvIndex];
        var v = dataV[uvIndex];

        // Adjust and clamp the pixel values
        y = (y < 0) ? 0 : ((y > 255) ? 255 : y);
        u -= 128;
        v -= 128;

        var r = (y + 1.402 * v);
        var g = (y - 0.3441363 * u - 0.71413636 * v);
        var b = (y + 1.772 * u);

        // Adjust and clamp the RGB values
        r = (r < 0) ? 0 : ((r > 255) ? 255 : r);
        g = (g < 0) ? 0 : ((g > 255) ? 255 : g);
        b = (b < 0) ? 0 : ((b > 255) ? 255 : b);

        // Assign RGB values to the correct position, considering the rotation
        // var index = (x * height + (height - y - 1)) * 3;
        var index = ((width - x - 1) * height + y) * 3;
        bytes[index] = r.round();
        bytes[index + 1] = g.round();
        bytes[index + 2] = b.round();
      }

      if (y % 2 == 1) {
        uvIndex += uvRowStride;
      }
    }

    // Create Image from RGB data
    var rgbImage = imglib.Image.fromBytes(
        width: height, height: width, bytes: bytes.buffer);

    // Encode RGB image to JPEG
    Uint8List jpegBytes = Uint8List.fromList(imglib.encodeJpg(rgbImage));
    return jpegBytes;
  }

  // import 'dart:typed_data';
// import 'package:image/image.dart' as img;

  // Uint8List _convertImageToBytes(CameraImage image) {
  //   // Convert YUV420 to RGB
  //   var width = image.width;
  //   var height = image.height;

  //   var uvRowStride = image.planes[1].bytesPerRow;
  //   var uvPixelStride = image.planes[1].bytesPerPixel;

  //   var data = image.planes[0].bytes;
  //   var dataU = image.planes[1].bytes;
  //   var dataV = image.planes[2].bytes;

  //   var imageSize = height * width;
  //   var uvSize = height * width ~/ 4;

  //   var bytes = Uint8List(imageSize * 3);

  //   var yIndex = 0;
  //   var uvIndex = 0;

  //   for (var y = 0; y < height; y++) {
  //     var pYIndex = yIndex;
  //     var pUVIndex = uvIndex;

  //     for (var x = width; x >= 0; x--) {
  //       var uvIndex = pUVIndex + (x ~/ 2) * uvPixelStride!;

  //       var y = data[pYIndex++];
  //       var u = dataU[uvIndex];
  //       var v = dataV[uvIndex];

  //       // Adjust and clamp the pixel values
  //       y = (y < 0) ? 0 : ((y > 255) ? 255 : y);
  //       u -= 128;
  //       v -= 128;

  //       var r = (y + 1.402 * v);
  //       var g = (y - 0.3441363 * u - 0.71413636 * v);
  //       var b = (y + 1.772 * u);

  //       // Adjust and clamp the RGB values
  //       r = (r < 0) ? 0 : ((r > 255) ? 255 : r);
  //       g = (g < 0) ? 0 : ((g > 255) ? 255 : g);
  //       b = (b < 0) ? 0 : ((b > 255) ? 255 : b);

  //       bytes[(pYIndex - 1) * 3] = r.round();
  //       bytes[(pYIndex - 1) * 3 + 1] = g.round();
  //       bytes[(pYIndex - 1) * 3 + 2] = b.round();
  //     }

  //     if (y % 2 == 1) {
  //       uvIndex += uvRowStride;
  //     }
  //   }

  //   // Create Image from RGB data
  //   var rgbImage =
  //       img.Image.fromBytes(width: width, height: height, bytes: bytes.buffer);

  //   // Encode RGB image to JPEG
  //   Uint8List jpegBytes = Uint8List.fromList(img.encodeJpg(rgbImage));
  //   return jpegBytes;
  // }

  // static int yuv2rgb(int y, int u, int v) {
  //   // Convert yuv pixel to rgb
  //   var r = (y + v * 1436 / 1024 - 179).round();
  //   var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
  //   var b = (y + u * 1814 / 1024 - 227).round();

  //   // Clipping RGB values to be inside boundaries [ 0 , 255 ]
  //   r = r.clamp(0, 255);
  //   g = g.clamp(0, 255);
  //   b = b.clamp(0, 255);

  //   return 0xff000000 |
  //       ((b << 16) & 0xff0000) |
  //       ((g << 8) & 0xff00) |
  //       (r & 0xff);
  // }

  Future<String> _readBarcode(CameraImage image) async {
    try {
      final inputImage = _convertCameraImageToInputImage(image);
      // final BarcodeScanner barcodeScanner = GoogleMlKit.vision.barcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      for (final barcode in barcodes) {
        return barcode.displayValue ?? '';
      }
      return ''; // Return empty string if no barcode found
    } catch (e) {
      print('Error reading barcode: $e');
      return ''; // Return empty string in case of an error
    }
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
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

  Future<void> fetchShopName() async {
    // Replace 'shop_data_table' with your actual table name
    final data = await supabase
        .from('store_data')
        .select(); // Use execute directly on the PostgrestClient instance

    setState(() {
      shopName = data[0]['store_name'].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Video Streaming'),
      ),
      body: Column(
        children: <Widget>[
          Text('Shop Name: $shopName'),
          Text('Status: $connectionStatus'),
          Text('ML Server IP: $ipML:80'),
          // Text('Prediction: $predictionText'),
          // Expanded(
          // child:
          Text(
            predictionText.replaceAll("#", "\n"),
            // Other styling properties if needed
          ),
          // ),
          ElevatedButton(
            onPressed: () async => {
              !_isUseAI
                  ? _initializeSocket(ipML, portML)
                  : () {
                      socket.disconnect();
                      socket.destroy();
                    }(),
              setState(() {
                _isCapturing = false;
                _isUseAI = !_isUseAI;
              }),
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isUseAI ? Colors.red : Colors.grey, // This is what you need!
            ),
            child: const Text('AI'),
          ),
          ElevatedButton(
            onPressed: () async => {
              _isCapturing = false,
              setState(() {
                _isUseBarcode = !_isUseBarcode;
              }),
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUseBarcode ? Colors.red : Colors.grey,
            ),
            child: const Text('Barcode'),
          ),
          Text('Result: $barcode'),
          Expanded(
            child: CameraPreview(controller),
          ),
          // TextButton(
          //   onPressed: _scanBarcode,
          //   child: const Text('Scan Barcode'),
          // ),
          // TextButton(
          //   onPressed: () async {
          //     _isCapturing = false;
          //     _i
          //     // final XFile imageFile = await _controller.takePicture();
          //     // final List<int> imageBytes = await imageFile.readAsBytes();
          //     // _sendImage(Uint8List.fromList(imageBytes));
          //     _initializeSocket(ipML, portML);
          //   },
          //   child: const Text('Classification!'),
          // ),
          TextField(
            onSubmitted: (text) {
              setState(() {
                ipML = text;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter ML Server IP',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _imageSendTimer.cancel(); // Cancel the image send timer
    _reconnectTimer.cancel(); // Cancel the timer when disposing the widget
    controller.dispose();
    socket.disconnect();
    super.dispose();
  }
}
