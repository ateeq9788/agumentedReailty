import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARImageViewer extends StatefulWidget {
  @override
  _ARImageViewerState createState() => _ARImageViewerState();
}

class _ARImageViewerState extends State<ARImageViewer> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  ARNode? imageNode;

  @override
  void dispose() {
    arSessionManager.dispose();
    arObjectManager.dispose();
    super.dispose();
  }

  void onARViewCreated(ARSessionManager sessionManager, ARObjectManager objectManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    addImageNode();
  }

  Future<void> addImageNode() async {
    final material = ARMaterial(
      diffuseTexture: ARTexture(
        image: AssetImage('assets/images/your_image.png'),
      ),
    );

    final plane = ARPlane(
      width: 1.0,
      height: 1.0,
      materials: [material],
    );

    imageNode = ARNode(
      type: NodeType.plane,
      geometry: plane,
      position: vector.Vector3(0, 0, -1),
    );

    await arObjectManager.addNode(imageNode!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AR Image Viewer')),
      body: ARView(
        onARViewCreated: onARViewCreated,
      ),
    );
  }
}
