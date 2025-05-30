import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool isInitialized = false;
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initializeSocket();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);

    await controller.initialize();
    setState(() {
      isInitialized = true;
    });
  }

  void initializeSocket() {
    _socket = IO.io(
      "http://192.168.93.176:3000", // Replace with your server's IP and port
      IO.OptionBuilder()
          .setTransports(['websocket']) // Use WebSocket transport
          .disableAutoConnect()
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print("Connected to the server");
    });

    _socket.on("uploadStatus", (data) {
      bool success = data['success'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Image uploaded successfully!"
              : "Failed to upload image."),
        ),
      );
    });

    _socket.onDisconnect((_) {
      print("Disconnected from the server");
    });
  }

  Future<void> sendImageToSocket(XFile image) async {
    try {
      // Read the image as bytes
      final imageBytes = await image.readAsBytes();

      // Convert the image bytes to a Base64 string
      final base64Image = base64Encode(imageBytes);

      // Emit the image to the server
      _socket.emit("sendImage", {
        "image": base64Image, // Send the Base64-encoded string
        "name": "mynamew",
      });

      print("Image sent to the server");
    } catch (e) {
      print("Error sending image to socket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending image: $e')),
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Access')),
      body: CameraPreview(controller), // Display the camera feed
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () async {
          try {
            // Capture the image and save it to a file
            final image = await controller.takePicture();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Picture saved at ${image.path}')),
            );

            // Send the image to the server
            sendImageToSocket(image);
          } catch (e) {
            print('Error capturing image: $e');
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: CameraApp()));
}
