import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _key = 'language';
  String _languageCode = 'sw';

  String get languageCode => _languageCode;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString(_key) ?? 'sw';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    _languageCode = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, langCode);
    notifyListeners();
  }
}
