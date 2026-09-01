import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:optik_suly/screens/home_screen.dart';
import 'package:optik_suly/services/app_database.dart';
import 'package:optik_suly/theme/app_theme.dart';
import 'package:optik_suly/widgets/live_camera_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the local database.
  await AppDatabase.instance.database;

  // Discover available device cameras.
  try {
    appCameras = await availableCameras();
  } catch (_) {
    // Camera discovery may fail on devices without cameras.
    appCameras = [];
  }

  runApp(const OptikSulyApp());
}

class OptikSulyApp extends StatelessWidget {
  const OptikSulyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OptikSulyApp',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
