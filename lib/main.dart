import 'package:flutter/material.dart';
import 'package:optik_suly/screens/home_screen.dart';
import 'package:optik_suly/theme/app_theme.dart';

void main() => runApp(const OptikSulyApp());

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
