import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ARImageViewerWithAndroid extends StatefulWidget {
  final String imageUrl; // Image URL parameter

  // Constructor to accept imageUrl
  ARImageViewerWithAndroid({required this.imageUrl});

  @override
  _ARImageViewerWithAndroidState createState() =>
      _ARImageViewerWithAndroidState();
}

class _ARImageViewerWithAndroidState extends State<ARImageViewerWithAndroid> {
  ArCoreController? arCoreController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR Image Viewer')),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator()), // Show a loading indicator
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _requestCameraPermission();
    arCoreController = controller;
    _addImageToScene(widget.imageUrl);  // Pass imageUrl
  }

  void _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      print("Permission granted for AR");
    } else {
      print("Camera permission denied for AR");
    }
  }

  // Add image to the scene
  void _addImageToScene(String imageUrl) async {
    try {
      final imageBytes = await loadImageFromUrl(imageUrl);

      // Apply image as texture with transparent background
      final material = ArCoreMaterial(
        color: Colors.blue, // Transparent background
        textureBytes: imageBytes,
      );

      // Use ArCoreCube but make it flat like a plane by adjusting the size
      final cube = ArCoreCube(
        materials: [material],
        size: vector.Vector3(0.5, 0.5, 0), // Make it flat
      );

      final node = ArCoreNode(
        //scale: vector.Vector3(0, 0, -1),
        shape: cube,
        position: vector.Vector3(0, 0, -1), // Position it 1 meter away
      );

      // Add node to the AR scene
      arCoreController?.addArCoreNode(node);

      setState(() {
        isLoading = false; // Hide loading indicator when image is ready
      });
    } catch (e) {
      print("Error loading image: $e");
      setState(() {
        isLoading = false; // Hide loading even on error
      });
    }
  }



  // Load image from URL
  Future<Uint8List> loadImageFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image from URL');
    }
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
