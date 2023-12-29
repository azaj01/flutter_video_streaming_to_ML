import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<CameraDescription> cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late IO.Socket socket;
  String ipML = "192.168.1.160"; // Use the server IP here
  int portML = 80; // Use the server port here
  String connectionStatus = "Connecting...";
  String predictionText = "";
  late Timer _reconnectTimer;
  late Timer _imageSendTimer;
  bool _isCapturing =
      false; // Flag to track whether a picture is being captured
  // late Stopwatch _frameStopwatch;
  @override
  void initState() {
    super.initState();

    // _frameStopwatch = Stopwatch()..start();

    _imageSendTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      _takeAndSendPicture();
    });
    _controller = CameraController(widget.cameras[0], ResolutionPreset.low);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      // _controller.startImageStream((CameraImage image) {
      //   if (_frameStopwatch.elapsedMilliseconds > (1000 ~/ 5)) {
      //     _frameStopwatch.reset();
      //     _sendImage(Uint8List.fromList(image.planes[0].bytes));
      //   }
      // });
      setState(() {});
    });

    socket = IO.io('http://$ipML:$portML', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _reconnectTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!socket.connected) {
        print('Attempting to reconnect...');
        _attemptReconnect();
      }
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
  }

  void _attemptReconnect() {
    socket.connect(); // Reconnect to the server
  }

  void _sendImage(Uint8List imageBytes) {
    socket.emit('image', {'image': base64Encode(imageBytes)});
  }

  void _takeAndSendPicture() async {
    if (!_isCapturing) {
      _isCapturing =
          true; // Set the flag to indicate that capture is in progress
      try {
        // await _controller.setFocusMode(FocusMode.locked);
        // await _controller.setExposureMode(ExposureMode.locked);
        await _controller.setFlashMode(FlashMode.off);
        final XFile imageFile = await _controller.takePicture();
        final List<int> imageBytes = await imageFile.readAsBytes();
        _sendImage(Uint8List.fromList(imageBytes));
      } catch (e) {
        print('Error capturing and sending picture: $e');
      } finally {
        _isCapturing = false; // Reset the flag when capture is complete
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Video Streaming'),
      ),
      body: Column(
        children: <Widget>[
          Text('Status: $connectionStatus'),
          Text('ML Server IP: $ipML:80'),
          // Text('Prediction: $predictionText'),
          Text(
            predictionText.replaceAll("#", "\n"),
            // Other styling properties if needed
          ),
          Expanded(
            child: CameraPreview(_controller),
          ),
          TextButton(
            onPressed: () async {
              _isCapturing = false;
              final XFile imageFile = await _controller.takePicture();
              final List<int> imageBytes = await imageFile.readAsBytes();
              _sendImage(Uint8List.fromList(imageBytes));
            },
            child: const Text('Take Picture'),
          ),
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
    _imageSendTimer.cancel(); // Cancel the image send timer
    _reconnectTimer.cancel(); // Cancel the timer when disposing the widget
    _controller.dispose();
    socket.disconnect();
    super.dispose();
  }
}
