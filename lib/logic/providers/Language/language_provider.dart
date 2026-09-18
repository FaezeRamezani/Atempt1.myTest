import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale localeIR = const Locale('fa', 'IR');
  Locale localeSA = const Locale('en', 'EN');

  Locale localeMode = const Locale('fa', 'IR');

  void toggleLocale() {
    localeMode = localeMode == localeIR
        ? const Locale('en', 'EN')
        : const Locale('fa', 'IR');
    notifyListeners();
  }
}
