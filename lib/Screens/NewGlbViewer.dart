import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Newglbviewer extends StatefulWidget {
  const Newglbviewer({super.key});

  @override
  State<Newglbviewer> createState() => _NewglbviewerState();
}

class _NewglbviewerState extends State<Newglbviewer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Model Viewer')),
        body: SafeArea(child:
        ModelViewer(
          backgroundColor: Color.fromARGB(0xFF, 0xEE, 0xEE, 0xEE),
          src: 'assets/stylised_broken_chair.glb',
          alt: 'A 3D model of an astronaut',
          ar: true,
          autoRotate: true,
          arPlacement: ArPlacement.floor,
          iosSrc: 'assets/stylised_broken_chair.glb',  // Explicit iosSrc
          cameraControls: true,
          disableZoom: true,
         )
        )
      ),
    );
  }
}
