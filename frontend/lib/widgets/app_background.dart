import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  static const Color bg = Color(0xFF1E2430); // elegant (not black)

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: SafeArea(child: child),
    );
  }
}
