import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:app/style.dart' as style;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:supabase_flutter/supabase_flutter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({required this.cameras, Key? key}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final supabase = Supabase.instance.client;
  String shopName = ''; // Variable to store the shop name

  late CameraController _controller;
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
  // late Stopwatch _frameStopwatch;
  @override
  void initState() {
    super.initState();
    fetchShopName();
    // _frameStopwatch = Stopwatch()..start();

    _imageSendTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      _takeAndSendPicture();
    });
    _controller = CameraController(widget.cameras[0], ResolutionPreset.low);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });

    // Initialize socket connection with initial IP and port
    _initializeSocket(ipML, portML);

    _reconnectTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!socket.connected) {
        print('Attempting to reconnect...');
        _initializeSocket(ipML, portML);
      }
    });
    // socket.onConnect((_) {
    //   setState(() {
    //     connectionStatus = 'Connected to server';
    //   });
    // });
  }

  void _initializeSocket(String ip, int port) {
    // Close existing socket connection
    // if (socket != null) {
    socket.disconnect();
    socket.destroy();
    // }

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
    if (!_controller.value.isInitialized) {
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
          Expanded(
            child: CameraPreview(_controller),
          ),
          TextButton(
            onPressed: () async {
              _isCapturing = false;
              // final XFile imageFile = await _controller.takePicture();
              // final List<int> imageBytes = await imageFile.readAsBytes();
              // _sendImage(Uint8List.fromList(imageBytes));
              _initializeSocket(ipML, portML);
            },
            child: const Text('Classification!'),
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
