import 'package:flutter/material.dart';

class VakitPalette {
  const VakitPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
}

class VakitPalettes {
  static const VakitPalette olive = VakitPalette(
    id: 'olive',
    name: 'Zeytin Yeşili',
    description: 'Klasik Vakit görünümü',
    primary: Color(0xFF3B5E3B),
    primaryLight: Color(0xFFA3C9A8),
    accent: Color(0xFFD4AF37),
    background: Color(0xFFF8F5F0),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2F3B2F),
    textSecondary: Color(0xFF7A8B78),
    border: Color(0xFFC7D4C0),
  );

  static const VakitPalette desert = VakitPalette(
    id: 'desert',
    name: 'Çöl Günbatımı',
    description: 'Sıcak kum ve amber tonları',
    primary: Color(0xFF8C4A2F),
    primaryLight: Color(0xFFF2C094),
    accent: Color(0xFFE7833C),
    background: Color(0xFFFFF4EB),
    surface: Color(0xFFFFF9F4),
    textPrimary: Color(0xFF5B3420),
    textSecondary: Color(0xFFB07859),
    border: Color(0xFFE9CBB4),
  );

  static const VakitPalette midnight = VakitPalette(
    id: 'midnight',
    name: 'Gece Mavisi',
    description: 'Serin gece ve ay ışığı',
    primary: Color(0xFF1E3A8A),
    primaryLight: Color(0xFF93C5FD),
    accent: Color(0xFF38BDF8),
    background: Color(0xFFF3F6FF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF6B7280),
    border: Color(0xFFCBD5F5),
  );

  static const List<VakitPalette> all = [olive, desert, midnight];

  static VakitPalette byId(String id) {
    return all.firstWhere((palette) => palette.id == id, orElse: () => olive);
  }
}
