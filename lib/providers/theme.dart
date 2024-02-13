import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "appTheme";
  SharedPreferences? _prefs;

  String _theme = 'default';
  String get appTheme => _theme;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _theme = _prefs!.getString(key) ?? 'default';
    notifyListeners();
  }

  setTheme(String theme) {
    _theme = theme;
    _prefs!.setString(key, theme);
    notifyListeners();
  }
}
