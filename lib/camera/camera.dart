import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:app/camera/utils/imageConverter.dart';
import 'package:app/service/cart.dart';
import 'package:app/service/productService.dart';
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
import 'package:visibility_detector/visibility_detector.dart';

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
  final cartController = Get.find<CartController>();
  final productService = ProductService();
  String shopName = ''; // Variable to store the shop name
  String barcode = '';
  late CameraController controller;
  late Throttler throttler;
  late StreamSubscription<int> timer;
  static String ipML = "192.168.1.160"; // Use the server IP here
  static int portML = 80; // Use the server port here
  static late IO.Socket socket;
  bool showPanel = false; // Initially show the panel

  String connectionStatus = "enter ip...";
  String predictionText = "";
  late Timer _reconnectTimer;
  late Timer _imageSendTimer;
  bool _streamPaused = false;
  // bool _isCapturing =
  //     false; // Flag to track whether a picture is being captured
  bool _isUseAI = false; //
  bool _isUseBarcode = false; //
  late Timer _timer;

  late BarcodeScanner barcodeScanner;
  String fristProductPredict = '';
  int qty = 1;
  double initialRotation = 0.0;
  double currentRotation = 0.0;
  int initialQty = 1;
  @override
  void initState() {
    super.initState();
    fetchShopName();
    barcodeScanner = BarcodeScanner();
    throttler = Throttler(milliSeconds: 500);

    _initializeCamera();

    setState(() {});
  }

  void _initializeCamera() {
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

      // For Android,
      controller.startImageStream((image) async {
        throttler.run(() async {
          try {
            if (!_streamPaused) {
              processImage(image);
            }
          } on PlatformException catch (e) {
            debugPrint(
                "==== checkLiveness Method is not implemented ${e.message}");
          }
        });
      });
    });
  }

  void _initializeSocket(String ip, int port) {
    // disconnectSocket();
    // socket.disconnect();
    // socket.destroy();
    setState(() {
      connectionStatus = 'Connecting...';
    });
    print('connecting $ip:$port');
    socket = IO.io('http://$ip:$port', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      setState(() {
        connectionStatus = 'Connected';
      });
    });
    socket.onDisconnect((_) {
      setState(() {
        connectionStatus = 'Disconnected';
      });
    });
    socket.connect();
    socket.on('prediction', (data) {
      // Handle the predicted text received from Python
      String prediction = data['text'];
      print('Received prediction: $prediction');
      setState(() {
        predictionText = prediction.replaceAll("#", "\n");
        fristProductPredict = prediction.split('#').first.split(':').first;
        if (fristProductPredict == 'null') {
          fristProductPredict = '';
        }
      });
    });

    // Add listeners for other events as needed
  }

  void disconnectSocket() {
    if (socket.connected) {
      socket.disconnect();
      socket.onDisconnect((_) {
        setState(() {
          connectionStatus = 'Disconnected';
        });
      });
    }
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
        imglib.Image imageData = convertYUV420ToImage(image);
        final List<int> imageBytes = imglib.encodeJpg(imageData);

        String base64Image = base64Encode(imageBytes);

        socket.emit('image', {'image': base64Image});
      }
    } catch (e) {
      print('Error processing image: $e');
    } finally {
      // _isCapturing = false;
    }
  }

  Future<String> _readBarcode(CameraImage image) async {
    try {
      final inputImage = convertCameraImageToInputImage(image);
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

    return VisibilityDetector(
        key: const Key('camera_screen_detector'),
        onVisibilityChanged: (visibilityInfo) {
          print(visibilityInfo.visibleFraction);
          setState(() {
            _streamPaused = !(visibilityInfo.visibleFraction > 0.8);
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Camera Streaming'),
          ),
          body: Stack(children: [
            Column(
              children: <Widget>[
                Text('Shop Name: $shopName'),
                Text('Status: $connectionStatus'),

                Text('Prediction: $fristProductPredict'),
                // Expanded(
                // child:

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!showPanel)
                      RawMaterialButton(
                        onPressed: () async => {
                          setState(() {
                            showPanel = !showPanel; // Toggle show/hide panel
                          })
                        },
                        elevation: 2.0,
                        padding: const EdgeInsets.all(15.0),
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.settings,
                          size: 18.0,
                        ),
                      ),
                    RawMaterialButton(
                      onPressed: () async => {
                        !_isUseAI
                            ? _initializeSocket(ipML, portML)
                            : () {
                                disconnectSocket();
                              }(),
                        setState(() {
                          _isUseAI = !_isUseAI;
                        }),
                      },
                      elevation: 2.0,
                      fillColor: _isUseAI ? Colors.red : Colors.grey,
                      padding: const EdgeInsets.all(15.0),
                      shape: const CircleBorder(),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                    RawMaterialButton(
                      onPressed: () async => {
                        // _isCapturing = false,
                        setState(() {
                          _isUseBarcode = !_isUseBarcode;
                        }),
                      },
                      elevation: 2.0,
                      fillColor: _isUseBarcode ? Colors.red : Colors.grey,
                      padding: const EdgeInsets.all(15.0),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 18.0,
                      ),
                    ),
                  ],
                ),

                Text('Result: $barcode'),
                Expanded(
                  child: CameraPreview(controller),
                ),
                const SizedBox(height: 16),
                if (fristProductPredict != '')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('add: $fristProductPredict'),
                                Text('Qty: ${qty.toInt()}'),
                              ]),
                          Slider(
                            value: qty.toDouble(),
                            min: 1,
                            max: 10,
                            divisions:
                                9, // Number of discrete divisions between min and max
                            onChanged: (newValue) {
                              setState(() {
                                qty = newValue.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final product = await productService
                              .getProductByName(fristProductPredict);
                          cartController.addToCart(product, qty.toInt());
                        },
                        child: const Text('to cart'),
                      ),
                    ],
                  ),
              ],
            ),
            Visibility(
              visible: showPanel,
              child: Container(
                color: Colors.black
                    .withOpacity(0.2), // Semi-transparent background
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ML Server IP: $ipML:80'),
                      Text(predictionText),
                      TextField(
                        keyboardType: TextInputType.phone,
                        onSubmitted: (text) {
                          setState(() {
                            ipML = text;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter ML Server IP',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPanel = !showPanel; // Toggle show/hide panel
                          });
                        },
                        child: const Text('Hide Panel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ));
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
