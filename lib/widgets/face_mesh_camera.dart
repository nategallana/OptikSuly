import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'face_mesh_painter.dart';

class FaceMeshCamera extends StatefulWidget {
  const FaceMeshCamera({
    super.key,
    this.height = 270,
  });

  final double height;

  @override
  State<FaceMeshCamera> createState() => _FaceMeshCameraState();
}

class _FaceMeshCameraState extends State<FaceMeshCamera> {
  CameraController? _cameraController;

  FaceDetectorProcessor? _faceDetector;
  FaceMeshProcessor? _faceMesh;

  FaceMeshInferencePipeline? _pipeline;
  FaceMeshInferenceStreamProcessor? _streamProcessor;

  StreamController<FaceMeshNv21Image>? _frameController;
  StreamSubscription<FaceMeshInferenceResult>? _subscription;

  FaceMeshResult? _meshResult;

  bool _initializing = true;
  String? _error;

  // ============================================================
  // EYE LANDMARKS
  // ============================================================

  static const List<int> _leftEye = [
    33,
    160,
    158,
    133,
    153,
    144,
  ];

  static const List<int> _rightEye = [
    362,
    385,
    387,
    263,
    373,
    380,
  ];

  // ============================================================
  // BLINK DETECTION
  // ============================================================

  int _blinkCount = 0;

  // EAR below this value means the eye is considered closed.
  static const double _closedThreshold = 0.20;

  // EAR above this value means the eye has reopened.
  //
  // This is intentionally close to the closed threshold so
  // quick blinks are easier to detect.
  static const double _openThreshold = 0.21;

  // Ignore extremely short EAR fluctuations.
  static const Duration _minimumClosedDuration =
      Duration(milliseconds: 30);

  // If eyes stay closed longer than this, treat it as
  // squinting / prolonged eye closure rather than a blink.
  static const Duration _maximumClosedDuration =
      Duration(milliseconds: 600);

  // Prevent duplicate blink detections.
  static const Duration _blinkCooldown =
      Duration(milliseconds: 150);

  bool _eyesAreClosed = false;

  // The detector needs to see the eyes open once before
  // it starts counting blinks.
  bool _hasSeenEyesOpen = false;

  DateTime? _eyesClosedAt;
  DateTime? _lastBlinkTime;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // ----------------------------------------------------------
      // 1. Get available cameras
      // ----------------------------------------------------------

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('No camera found.');
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection ==
            CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      // ----------------------------------------------------------
      // 2. Initialize camera
      // ----------------------------------------------------------

      final cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();

      _cameraController = cameraController;

      // ----------------------------------------------------------
      // 3. Initialize MediaPipe Face Detector
      // ----------------------------------------------------------

      final detector =
          await FaceDetectorProcessor.create(
        model: FaceDetectionModel.shortRange,
        maxResults: 1,
      );

      _faceDetector = detector;

      // ----------------------------------------------------------
      // 4. Initialize Face Mesh
      // ----------------------------------------------------------

      final mesh =
          await FaceMeshProcessor.create(
        model: FaceMeshModel.v2,
      );

      _faceMesh = mesh;

      // ----------------------------------------------------------
      // 5. Create MediaPipe pipeline
      // ----------------------------------------------------------

      final pipeline =
          FaceMeshInferencePipeline(
        detector: detector,
        mesh: mesh,
        landmarkSmoothing:
            const LandmarkSmoothingOptions(),
      );

      _pipeline = pipeline;

      final streamProcessor =
          FaceMeshInferenceStreamProcessor(
        pipeline,
      );

      _streamProcessor = streamProcessor;

      // ----------------------------------------------------------
      // 6. Create camera frame stream
      // ----------------------------------------------------------

      _frameController =
          StreamController<FaceMeshNv21Image>();

      _subscription = streamProcessor
          .processNv21(
            _frameController!.stream,
            rotationDegrees: 0,
          )
          .listen(
            _handleResult,
            onError: _handleError,
          );

      // ----------------------------------------------------------
      // 7. Start receiving camera frames
      // ----------------------------------------------------------

      await cameraController.startImageStream(
        _handleCameraImage,
      );

      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    } catch (e) {
      debugPrint(
        'Face Mesh initialization error: $e',
      );

      if (mounted) {
        setState(() {
          _initializing = false;
          _error = e.toString();
        });
      }
    }
  }

  // ============================================================
  // CAMERA IMAGE PROCESSING
  // ============================================================

  void _handleCameraImage(CameraImage image) {
    if (_frameController == null ||
        _frameController!.isClosed) {
      return;
    }

    // Android CameraX normally provides YUV420.
    if (image.format.group !=
        ImageFormatGroup.yuv420) {
      debugPrint(
        'Unsupported camera format: '
        '${image.format.group}',
      );
      return;
    }

    if (image.planes.length < 3) {
      return;
    }

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int width = image.width;
    final int height = image.height;

    final int vuRowStride = width;

    final vuPlane = Uint8List(
      vuRowStride * (height ~/ 2),
    );

    final int chromaWidth = width ~/ 2;
    final int chromaHeight = height ~/ 2;

    for (int row = 0;
        row < chromaHeight;
        row++) {
      for (int col = 0;
          col < chromaWidth;
          col++) {
        final int uIndex =
            row * uPlane.bytesPerRow +
            col *
                (uPlane.bytesPerPixel ?? 1);

        final int vIndex =
            row * vPlane.bytesPerRow +
            col *
                (vPlane.bytesPerPixel ?? 1);

        final int outputIndex =
            row * vuRowStride + col * 2;

        if (uIndex >= uPlane.bytes.length ||
            vIndex >= vPlane.bytes.length ||
            outputIndex + 1 >=
                vuPlane.length) {
          continue;
        }

        // NV21 = V then U.
        vuPlane[outputIndex] =
            vPlane.bytes[vIndex];

        vuPlane[outputIndex + 1] =
            uPlane.bytes[uIndex];
      }
    }

    final nv21Image =
        FaceMeshNv21Image(
      yPlane: yPlane.bytes,
      vuPlane: vuPlane,
      width: width,
      height: height,
      yBytesPerRow: yPlane.bytesPerRow,
      vuBytesPerRow: vuRowStride,
    );

    _frameController!.add(nv21Image);
  }

  // ============================================================
  // DISTANCE BETWEEN LANDMARKS
  // ============================================================

  double _distance(
    FaceMeshLandmark a,
    FaceMeshLandmark b,
  ) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;

    return math.sqrt(
      dx * dx + dy * dy,
    );
  }

  // ============================================================
  // EYE ASPECT RATIO
  // ============================================================

  double _calculateEyeAspectRatio(
    FaceMeshResult result,
    List<int> eye,
  ) {
    if (eye.length < 6 ||
        eye.any(
          (index) =>
              index >= result.landmarks.length,
        )) {
      return 0;
    }

    final p1 =
        result.landmarks[eye[0]];
    final p2 =
        result.landmarks[eye[1]];
    final p3 =
        result.landmarks[eye[2]];
    final p4 =
        result.landmarks[eye[3]];
    final p5 =
        result.landmarks[eye[4]];
    final p6 =
        result.landmarks[eye[5]];

    final vertical1 =
        _distance(p2, p6);

    final vertical2 =
        _distance(p3, p5);

    final horizontal =
        _distance(p1, p4);

    if (horizontal == 0) {
      return 0;
    }

    return (vertical1 + vertical2) /
        (2 * horizontal);
  }

  // ============================================================
  // BLINK DETECTION
  // ============================================================

  void _processBlink(
    double leftEar,
    double rightEar,
    double averageEar,
  ) {
    // ----------------------------------------------------------
    // Establish initial open-eye state.
    // ----------------------------------------------------------

    if (!_hasSeenEyesOpen) {
      if (leftEar >= _openThreshold &&
          rightEar >= _openThreshold) {
        _hasSeenEyesOpen = true;

        debugPrint(
          'Initial open-eye state established.',
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // Determine whether BOTH eyes are closed.
    // ----------------------------------------------------------

    final bool leftClosed =
        leftEar < _closedThreshold;

    final bool rightClosed =
        rightEar < _closedThreshold;

    final bool bothEyesClosed =
        leftClosed && rightClosed;

    // ----------------------------------------------------------
    // EYES JUST CLOSED
    // ----------------------------------------------------------

    if (bothEyesClosed &&
        !_eyesAreClosed) {
      _eyesAreClosed = true;
      _eyesClosedAt = DateTime.now();

      debugPrint(
        'Eyes closing | '
        'Left: ${leftEar.toStringAsFixed(3)} | '
        'Right: ${rightEar.toStringAsFixed(3)}',
      );

      return;
    }

    // ----------------------------------------------------------
    // EYES ARE STILL CLOSED
    // ----------------------------------------------------------

    if (bothEyesClosed &&
        _eyesAreClosed) {
      return;
    }

    // ----------------------------------------------------------
    // EYES HAVE OPENED AGAIN
    // ----------------------------------------------------------

    if (_eyesAreClosed &&
        !bothEyesClosed) {
      final now = DateTime.now();

      final closedDuration =
          _eyesClosedAt == null
              ? Duration.zero
              : now.difference(
                  _eyesClosedAt!,
                );

      _eyesAreClosed = false;

      // --------------------------------------------------------
      // Too short = probably noise.
      // --------------------------------------------------------

      if (closedDuration <
          _minimumClosedDuration) {
        debugPrint(
          'Ignored: closure too short '
          '${closedDuration.inMilliseconds}ms',
        );

        return;
      }

      // --------------------------------------------------------
      // Too long = probably squinting.
      // --------------------------------------------------------

      if (closedDuration >
          _maximumClosedDuration) {
        debugPrint(
          'Ignored: closure too long '
          '${closedDuration.inMilliseconds}ms',
        );

        return;
      }

      // --------------------------------------------------------
      // BOTH eyes need to reopen sufficiently.
      //
      // This helps reject winks.
      // --------------------------------------------------------

      final bool leftOpened =
          leftEar >= _openThreshold;

      final bool rightOpened =
          rightEar >= _openThreshold;

      if (!leftOpened ||
          !rightOpened) {
        debugPrint(
          'Ignored: eyes did not reopen '
          'sufficiently.',
        );

        return;
      }

      // --------------------------------------------------------
      // Prevent duplicate detections.
      // --------------------------------------------------------

      if (_lastBlinkTime != null &&
          now.difference(
                _lastBlinkTime!,
              ) <
              _blinkCooldown) {
        return;
      }

      // --------------------------------------------------------
      // VALID BLINK
      // --------------------------------------------------------

      _blinkCount++;

      _lastBlinkTime = now;

      debugPrint(
        'BLINK DETECTED! '
        'Duration: '
        '${closedDuration.inMilliseconds}ms | '
        'Total: $_blinkCount',
      );
    }
  }

  // ============================================================
  // MEDIAPIPE RESULT
  // ============================================================

  void _handleResult(
    FaceMeshInferenceResult result,
  ) {
    final mesh = result.meshResult;

    if (!mounted || mesh == null) {
      return;
    }

    // Calculate EAR for both eyes.
    final leftEar =
        _calculateEyeAspectRatio(
      mesh,
      _leftEye,
    );

    final rightEar =
        _calculateEyeAspectRatio(
      mesh,
      _rightEye,
    );

    final averageEar =
        (leftEar + rightEar) / 2;

    // Run blink detector.
    _processBlink(
      leftEar,
      rightEar,
      averageEar,
    );

    // Print values to VS Code terminal.
    debugPrint(
      'Left EAR: '
      '${leftEar.toStringAsFixed(3)} | '
      'Right EAR: '
      '${rightEar.toStringAsFixed(3)} | '
      'Average EAR: '
      '${averageEar.toStringAsFixed(3)} | '
      'Blinks: $_blinkCount',
    );

    setState(() {
      _meshResult = mesh;
    });
  }

  // ============================================================
  // MEDIAPIPE ERROR
  // ============================================================

  void _handleError(Object error) {
    debugPrint(
      'MediaPipe error: $error',
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _subscription?.cancel();

    _frameController?.close();

    _cameraController?.dispose();

    _faceDetector?.close();

    _faceMesh?.close();

    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(16),
            child: Text(
              'Face Mesh Error:\n$_error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final controller =
        _cameraController;

    if (controller == null ||
        !controller.value.isInitialized) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'Camera unavailable',
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------------
          // Camera preview
          // ------------------------------------------------------

          ClipRRect(
            borderRadius:
                BorderRadius.circular(16),
            child: CameraPreview(
              controller,
            ),
          ),

          // ------------------------------------------------------
          // Face mesh overlay
          // ------------------------------------------------------

          IgnorePointer(
            child: CustomPaint(
              painter: FaceMeshPainter(
                _meshResult,
              ),
            ),
          ),

          // ------------------------------------------------------
          // Blink counter
          // ------------------------------------------------------

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color: Colors.black54,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                'Blinks: $_blinkCount',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}