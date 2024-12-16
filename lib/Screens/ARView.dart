import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';

class ARView extends StatefulWidget {
  @override
  _ARViewState createState() => _ARViewState();
}

class _ARViewState extends State<ARView> {
  ArCoreController? arCoreController;

  @override
  void dispose() {
    _disposeArCoreController(); // Ensure ARCoreController is disposed properly
    super.dispose();
  }

  // Function to dispose ARCoreController
  void _disposeArCoreController() {
    if (arCoreController != null) {
      arCoreController?.dispose();
      arCoreController = null; // Reset to avoid dangling references
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clean up ARCore resources before navigating back
        _disposeArCoreController();
        return true; // Allow navigation to proceed
      },
      child: Scaffold(
        appBar: AppBar(title: Text('AR View')),
        body: ArCoreView(
          onArCoreViewCreated: onArCoreViewCreated,
        ),
      ),
    );
  }

  void onArCoreViewCreated(ArCoreController controller) async {
    arCoreController = controller;

    try {
      // Load the PNG image as a texture
      final ByteData textureBytes = await rootBundle.load('assets/images/first.jpg');
      final material = ArCoreMaterial(textureBytes: textureBytes.buffer.asUint8List());

      // Use a thin cube to simulate a plane
      final shape = ArCoreCube(
        materials: [material],
        size: Vector3(1.0, 1.0, 0.01), // Very thin along the Z-axis
      );

      final node = ArCoreNode(
        shape: shape,
        position: Vector3(0, 0, -1), // 1 meter in front of the camera
      );

      arCoreController?.addArCoreNode(node);
    } catch (e) {
      debugPrint("Error adding ARCore node: $e");
    }
  }
}
