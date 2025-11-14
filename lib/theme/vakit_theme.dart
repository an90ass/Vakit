import 'package:flutter/material.dart';
import 'package:namaz/theme/vakit_palette.dart';

ThemeData buildVakitTheme(VakitPalette palette, double softness) {
  final background =
      Color.lerp(palette.background, Colors.white, softness) ??
      palette.background;
  final surface =
      Color.lerp(palette.surface, Colors.white, softness * 0.6) ??
      palette.surface;
  final primaryLight =
      Color.lerp(palette.primaryLight, Colors.white, softness * 0.4) ??
      palette.primaryLight;

  final colorScheme = ColorScheme.light(
    primary: palette.primary,
    secondary: palette.accent,
    background: background,
    surface: surface,
  );

  final textTheme = Typography.blackMountainView.apply(
    bodyColor: palette.textPrimary,
    displayColor: palette.textPrimary,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    cardColor: surface,
    canvasColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: textTheme,
    iconTheme: IconThemeData(color: palette.accent),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: palette.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primary,
        side: BorderSide(color: primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.primary,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryLight.withOpacity(0.25),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.primary, width: 1.6),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: palette.primary,
      inactiveTrackColor: palette.primary.withOpacity(0.2),
      thumbColor: palette.accent,
      overlayColor: palette.accent.withOpacity(0.2),
    ),
    dividerColor: palette.border,
  );
}
