import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

class FaceMeshPainter extends CustomPainter {
  final FaceMeshResult? result;

  FaceMeshPainter(this.result);

  // MediaPipe Face Mesh eye landmarks.
  //
  // These are the main points we will use to measure
  // how open or closed each eye is.
  static const List<int> leftEye = [
    33,
    160,
    158,
    133,
    153,
    144,
  ];

  static const List<int> rightEye = [
    362,
    385,
    387,
    263,
    373,
    380,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final result = this.result;

    if (result == null || result.landmarks.isEmpty) {
      return;
    }

    // All normal face landmarks.
    final facePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Eye landmarks.
    final eyePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw the normal face landmarks.
    for (final landmark in result.landmarks) {
      final x = landmark.y * size.width;
      final y = landmark.x * size.height;

      canvas.drawCircle(
        Offset(x, y),
        1.5,
        facePaint,
      );
    }

    // Draw the selected left-eye landmarks.
    for (final index in leftEye) {
      if (index >= result.landmarks.length) {
        continue;
      }

      final landmark = result.landmarks[index];

      final x = landmark.y * size.width;
      final y = landmark.x * size.height;

      canvas.drawCircle(
        Offset(x, y),
        4,
        eyePaint,
      );
    }

    // Draw the selected right-eye landmarks.
    for (final index in rightEye) {
      if (index >= result.landmarks.length) {
        continue;
      }

      final landmark = result.landmarks[index];

      final x = landmark.y * size.width;
      final y = landmark.x * size.height;

      canvas.drawCircle(
        Offset(x, y),
        4,
        eyePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FaceMeshPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}