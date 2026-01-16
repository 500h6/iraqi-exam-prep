import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themePreferenceKey = 'theme_preference';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(const ThemeInitial(ThemeMode.light)) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themePreferenceKey);
    if (savedTheme == 'dark') {
      emit(const ThemeChanged(ThemeMode.dark));
    } else {
      // Default to light as requested
      emit(const ThemeChanged(ThemeMode.light));
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs.setString(_themePreferenceKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(ThemeChanged(newMode));
  }
}
