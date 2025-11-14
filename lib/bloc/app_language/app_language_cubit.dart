import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageCubit extends Cubit<Locale> {
  AppLanguageCubit(this._prefs) : super(_initialLocale(_prefs));

  final SharedPreferences _prefs;
  static const _storageKey = 'appLanguage';

  static Locale _initialLocale(SharedPreferences prefs) {
    final saved = prefs.getString(_storageKey);
    if (saved == null || saved.isEmpty) {
      return const Locale('tr');
    }
    return Locale(saved);
  }

  void updateLocale(Locale locale) {
    emit(locale);
    _prefs.setString(_storageKey, locale.languageCode);
  }
}
