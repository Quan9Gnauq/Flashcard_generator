import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF6B9BFA);
  static const Color backgroundLight = Color(0xFFF3F3F3);
  static const Color cardGrey = Color(0xFFE2E2E2);
  static const Color borderGrey = Color(0xFFBDBDBD);
  static const Color textBlack = Colors.black87;
  static const Color cancelRed = Color(0xFFE53935);
}

PreferredSizeWidget buildCustomAppBar(String title, {bool showBackButton = false}) {
  return AppBar(
    automaticallyImplyLeading: showBackButton,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.list, size: 36),
        onPressed: () {},
      )
    ],
  );
}

