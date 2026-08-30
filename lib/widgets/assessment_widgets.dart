import 'package:flutter/material.dart';
import 'package:optik_suly/theme/app_theme.dart';

class AssessmentScaffold extends StatelessWidget {
  const AssessmentScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.onBack,
    this.scrollable = true,
  });

  final String title;
  final Widget child;
  final Widget? bottom;
  final VoidCallback? onBack;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: child,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBack ?? () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(title),
      ),
      body: scrollable ? SingleChildScrollView(child: body) : body,
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: bottom,
              ),
            ),
    );
  }
}

class RoundIcon extends StatelessWidget {
  const RoundIcon(this.icon, {super.key, this.size = 72});
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.aqua,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.tealDark, size: size * .45),
    );
  }
}

class StepLine extends StatelessWidget {
  const StepLine({super.key, required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class TestIntroduction extends StatelessWidget {
  const TestIntroduction({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.steps,
    this.note,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> steps;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          children: [
            RoundIcon(icon),
            const SizedBox(height: 22),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < steps.length; i++)
              StepLine(number: i + 1, text: steps[i]),
            if (note != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.tealDark),
                    const SizedBox(width: 12),
                    Expanded(child: Text(note!)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CameraPlaceholder extends StatelessWidget {
  const CameraPlaceholder({
    super.key,
    this.title = 'Camera Preview',
    this.subtitle = 'Live camera feed will appear here',
    this.height = 260,
    this.overlay,
  });

  final String title;
  final String subtitle;
  final double height;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.camera,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 54,
                  color: Color(0xFF8490A9),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFA9B3C8),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF69748E)),
                ),
              ],
            ),
          ),
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
