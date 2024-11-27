import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'dart:math' as math;

class ARObjectScreen extends StatefulWidget {
  final String imgUrl;  // Add a field for the image URL

  // Update the constructor to accept imgUrl
  ARObjectScreen({required this.imgUrl});

  @override
  _ARObjectScreenState createState() => _ARObjectScreenState();
}

class _ARObjectScreenState extends State<ARObjectScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  double _scale = 1.0;  // Scale factor for zooming
  double _previousScale = 1.0;
  double _rotation = 0.0;  // Rotation angle in radians
  double _previousRotation = 0.0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.high);
    await _cameraController?.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("AR View Of Product")),
      body: Stack(
        children: <Widget>[
          CameraPreview(_cameraController!),  // Camera feed as the background

          // Gesture detector for zoom and rotation
          GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              _previousScale = _scale;
              _previousRotation = _rotation;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _scale = _previousScale * details.scale;
                _rotation = _previousRotation + details.rotation;  // Update rotation angle
              });
            },
            onScaleEnd: (ScaleEndDetails details) {
              _previousScale = _scale;
              _previousRotation = _rotation;
            },
            child: Align(
              alignment: Alignment.center,  // Image centered in the view
              child: Opacity(
                opacity: 1,  // Adjust opacity if needed
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(_scale)
                    ..rotateZ(_rotation),  // Apply rotation
                  child: Image.network( // Use Image.network to display the image from the URL
                    widget.imgUrl,  // Use the imgUrl parameter
                    width: 200,  // Initial width
                    height: 200, // Initial height
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

