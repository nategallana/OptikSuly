import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/assessment_widgets.dart';

/// Global list populated in `main()` via `availableCameras()`.
List<CameraDescription> appCameras = [];

/// A reusable live camera preview widget.
///
/// Shows the device camera feed with rounded corners matching the app design.
/// Falls back to [CameraPlaceholder] when no camera is available or permission
/// is denied.
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({
    super.key,
    this.height = 260,
    this.lensDirection = CameraLensDirection.front,
    this.overlay,
  });

  final double height;
  final CameraLensDirection lensDirection;
  final Widget? overlay;

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-initialize when returning from background.
    if (state == AppLifecycleState.resumed) {
      _initCamera();
    } else if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    }
  }

  Future<void> _initCamera() async {
    if (appCameras.isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    // Find a camera matching the requested lens direction.
    final camera = appCameras.firstWhere(
      (cam) => cam.lensDirection == widget.lensDirection,
      orElse: () => appCameras.first,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _hasError = false;
      });
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fallback when camera is unavailable.
    if (_hasError || _controller == null || !_controller!.value.isInitialized) {
      if (_hasError) {
        return CameraPlaceholder(
          title: 'Camera Unavailable',
          subtitle: 'Check permissions or device camera',
          height: widget.height,
          overlay: widget.overlay,
        );
      }
      // Still loading.
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.camera,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: CameraPreview(_controller!),
              ),
            ),
            if (widget.overlay != null) widget.overlay!,
          ],
        ),
      ),
    );
  }
}
