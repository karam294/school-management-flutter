import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  // ✅ Use everywhere as: backgroundColor: AppBackground.bg
  static const Color bg = Color(0xFF0F172A); // dark navy

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Elegant dark background with a soft touch (NOT black)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A), // deep navy
            Color(0xFF111827), // slate
            Color(0xFF0B1220), // darker navy
          ],
        ),
      ),
      child: child,
    );
  }
}
