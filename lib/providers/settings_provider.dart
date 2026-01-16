import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _userName = '';

  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get userName => _userName;

  SettingsProvider(this._prefs) {
    if (_prefs != null) {
      _loadSettings();
    }
    _robustInit();
  }

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _robustInit() async {
    // Try up to 5 times with increasing delay
    for (int i = 0; i < 5; i++) {
      try {
        _prefs = await SharedPreferences.getInstance();
        _loadSettings();
        notifyListeners();
        debugPrint('Settings loaded successfully on attempt ${i + 1}');
        return;
      } catch (e) {
        debugPrint('Settings init attempt ${i + 1} failed: $e');
        await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
      }
    }
  }

  void _loadSettings() {
    if (_prefs == null) return;
    _isDarkMode = _prefs!.getBool('isDarkMode') ?? false;
    _notificationsEnabled = _prefs!.getBool('notificationsEnabled') ?? true;
    _soundEnabled = _prefs!.getBool('soundEnabled') ?? true;
    _userName = _prefs!.getString('userName') ?? '';
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveToPrefs('isDarkMode', _isDarkMode);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _saveToPrefs('notificationsEnabled', value);
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    await _saveToPrefs('soundEnabled', value);
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    await _saveToPrefs('userName', name);
  }

  Future<void> _saveToPrefs(String key, dynamic value) async {
    try {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is String) {
        await _prefs!.setString(key, value);
      }
      // Critical: Ensure data is written to disk
      await _prefs!.reload(); 
    } catch (e) {
      debugPrint('Failed to save $key: $e');
    }
  }
}
