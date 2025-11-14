import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namaz/theme/vakit_palette.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<VakitThemeState> {
  ThemeCubit(this._prefs)
    : super(
        VakitThemeState(
          palette: VakitPalettes.byId(
            _prefs.getString(_paletteKey) ?? VakitPalettes.olive.id,
          ),
          softness: _prefs.getDouble(_softnessKey) ?? 0,
        ),
      );

  static const _paletteKey = 'theme_palette_id';
  static const _softnessKey = 'theme_softness';

  final SharedPreferences _prefs;

  void selectPalette(String paletteId) {
    final palette = VakitPalettes.byId(paletteId);
    _prefs.setString(_paletteKey, palette.id);
    emit(state.copyWith(palette: palette));
  }

  void updateSoftness(double value) {
    final clamped = value.clamp(0.0, 0.5);
    _prefs.setDouble(_softnessKey, clamped);
    emit(state.copyWith(softness: clamped));
  }
}
