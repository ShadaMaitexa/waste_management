import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  final _storage = const FlutterSecureStorage();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    String? lang = await _storage.read(key: 'app_lang');
    if (lang != null && lang == 'ml') {
      _locale = const Locale('ml');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale loc) async {
    if (!['en', 'ml'].contains(loc.languageCode)) return;
    _locale = loc;
    await _storage.write(key: 'app_lang', value: loc.languageCode);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    _locale = const Locale('en');
    await _storage.delete(key: 'app_lang');
    notifyListeners();
  }
}
