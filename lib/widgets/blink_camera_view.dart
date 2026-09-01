import 'package:camera/camera.dart';
import 'package:flutter/material.dart';


class BlinkCameraView extends StatefulWidget {
  const BlinkCameraView({
    super.key,
    this.height = 270,
  });

  final double height;

  @override
  State<BlinkCameraView> createState() => _BlinkCameraViewState();
}

class _BlinkCameraViewState extends State<BlinkCameraView> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        return;
      }

      // Prefer the front camera.
      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _controller = controller;
      _initializeControllerFuture = controller.initialize();

      if (mounted) {
        setState(() {});
      }

      await _initializeControllerFuture;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CameraPreview(_controller!),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to initialize camera'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}