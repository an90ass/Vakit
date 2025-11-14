import 'package:flutter/material.dart';
import 'package:vakit/theme/vakit_palette.dart';

class AppColors {
  static VakitPalette _palette = VakitPalettes.olive;
  static double _softness = 0;

  static void update(VakitPalette palette, double softness) {
    _palette = palette;
    _softness = softness.clamp(0, 0.5);
  }

  static Color get primary => _palette.primary;
  static Color get primaryLight =>
      Color.lerp(_palette.primaryLight, Colors.white, _softness * 0.4) ??
      _palette.primaryLight;
  static Color get accent => _palette.accent;

  static Color get background =>
      Color.lerp(_palette.background, Colors.white, _softness) ??
      _palette.background;

  static Color get surface =>
      Color.lerp(_palette.surface, Colors.white, _softness * 0.6) ??
      _palette.surface;

  static Color get textPrimary =>
      Color.lerp(_palette.textPrimary, Colors.black, _softness * 0.2) ??
      _palette.textPrimary;

  static Color get textSecondary =>
      Color.lerp(_palette.textSecondary, Colors.black54, _softness * 0.3) ??
      _palette.textSecondary;

  static Color get border =>
      Color.lerp(_palette.border, Colors.black12, _softness) ?? _palette.border;
}
