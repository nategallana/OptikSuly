import 'package:flutter/material.dart';
import 'face_mesh_camera.dart';

class BlinkCameraView extends StatelessWidget {
  const BlinkCameraView({
    super.key,
    this.height = 270,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return FaceMeshCamera(
      height: height,
    );
  }
}