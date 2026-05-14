import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  Future<void>? _loadingSettings;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SettingsProvider() {
    _loadingSettings = _loadSettings();
  }

  Future<void> loadSettings() async {
    final currentLoad = _loadingSettings;
    if (currentLoad != null) {
      await currentLoad;
      return;
    }

    _loadingSettings = _loadSettings();
    await _loadingSettings;
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeModeKey);

      _themeMode = savedMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } finally {
      _loadingSettings = null;
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool value) async {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value ? 'dark' : 'light');
  }
}
