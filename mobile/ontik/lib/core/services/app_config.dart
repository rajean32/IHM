import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/app_colors.dart';

String appLanguage = 'fr';
String appThemeMode = 'system';

final ValueNotifier<int> appConfigNotifier = ValueNotifier(0);

Future<void> loadAppConfig() async {
  final prefs = await SharedPreferences.getInstance();
  appLanguage = prefs.getString('pref_language') ?? 'fr';
  appThemeMode = prefs.getString('pref_theme') ?? 'system';
}

Future<void> setAppLanguage(String lang) async {
  appLanguage = lang;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pref_language', lang);
  await initializeDateFormatting(lang == 'en' ? 'en_US' : 'fr_FR', null);
  appConfigNotifier.value++;
}

Future<void> setAppTheme(String theme) async {
  appThemeMode = theme;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pref_theme', theme);
  appConfigNotifier.value++;
}

ThemeData resolveTheme() {
  String theme;
  if (appThemeMode == 'system') {
    theme = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
        ? 'dark'
        : 'light';
  } else {
    theme = appThemeMode;
  }
  return theme == 'dark' ? AppTheme.dark : AppTheme.light;
}

bool get isDarkMode {
  if (appThemeMode == 'system') {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }
  return appThemeMode == 'dark';
}

// ─── Event Context Global ───
int? activeEventId;
String activeEventName = '';

final ValueNotifier<int> eventContextNotifier = ValueNotifier(0);

void setActiveEvent(int? eventId, String eventName) {
  activeEventId = eventId;
  activeEventName = eventName;
  eventContextNotifier.value++;
}
