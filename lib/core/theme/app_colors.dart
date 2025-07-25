import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1E1E1E); // Fondo general
  static const Color surface = Color.fromARGB(255, 26, 26, 26); // Cards, modals
  static const Color primary = Color.fromARGB(
    255,
    93,
    93,
    219,
  ); // Verde ChatGPT (acento opcional)
  static const Color onPrimary = Colors.white;
  static const Color textPrimary = Color(0xFFEFEFEF); // Texto principal
  static const Color textSecondary = Color(0xFFB0B0B0); // Texto secundario
  static const Color border = Color(0xFF3A3A3A); // Líneas sutiles

  // Escala de grises útil
  static const Color grey900 = Color(0xFF121212);
  static const Color grey800 = Color(0xFF1E1E1E);
  static const Color grey700 = Color(0xFF2C2C2C);
  static const Color grey600 = Color(0xFF3A3A3A);
  static const Color grey400 = Color(0xFFB0B0B0);
  static const Color grey200 = Color(0xFFEFEFEF);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF2196F3);

  // Action colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color highlight = Color(0xFFFFEB3B);
  static const Color disabled = Color(0xFF616161);
}
