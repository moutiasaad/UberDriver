import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? languageCode = prefs.getString(_languageKey);

      if (languageCode != null) {
        _locale = Locale(languageCode);
      } else {
        // Default to Arabic
        _locale = const Locale('ar');
      }
    } catch (e) {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }

    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'ar') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }

  Future<void> setArabic() async {
    await setLocale(const Locale('ar'));
  }

  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  Future<void> clearLocale() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_languageKey);
      _locale = const Locale('ar');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing language: $e');
    }
  }
}
