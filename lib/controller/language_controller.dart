import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LanguageController with ChangeNotifier {
  Locale _appLocale = const Locale('en');

  Locale get appLocale => _appLocale;

  LanguageController() {
    _loadLanguageFromPreferences(); // Direct loading like theme/font
  }

  Future<void> _loadLanguageFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');

      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _appLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
      // Fallback to English
      _appLocale = Locale('en');
    }
  }

  Future<void> _saveLanguageToPreferences(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  void changeLanguage(Locale type) async {
    _appLocale = type;
    await _saveLanguageToPreferences(type.languageCode);
    notifyListeners();
  }

  // Helper method to get current language display name
  String get currentLanguageDisplay {
    switch (_appLocale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  // Helper method to get language code
  String get currentLanguageCode => _appLocale.languageCode;

  // Method to check if a specific language is currently selected
  bool isLanguageSelected(String languageCode) {
    return _appLocale.languageCode == languageCode;
  }

  // Reset to default language (English)
  void resetToDefault() {
    changeLanguage(Locale('en'));
  }
}