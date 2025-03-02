import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeMode currentTheme = ThemeMode.light;
  ThemeData? themeData;

  static ThemeProvider? _instance;

  static ThemeProvider get instance { 
    _instance ??= ThemeProvider._init();
    return _instance!;
  }

  ThemeProvider._init(){
    WidgetsBinding.instance.addObserver(this);
    _initializeTheme();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  Future<void> _initializeTheme() async {
    var brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    currentTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    themeData = await _generateThemeData(currentTheme);
    notifyListeners();
  }

  @override
  void didChangePlatformBrightness() {
    var brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    var newTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    if (newTheme != currentTheme) {
      currentTheme = newTheme;
      changeTheme(newTheme);
    }
  }

  Future<void> changeTheme(ThemeMode theme) async {
    currentTheme = theme;

    if (theme == ThemeMode.system) {
      var brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      currentTheme = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }

    themeData = await _generateThemeData(currentTheme);
    notifyListeners();
  }

  Future<ThemeData?> _generateThemeData(ThemeMode themeMode) async {
    String themeStr = await rootBundle.loadString(_getThemeJsonPath(themeMode));
    Map themeJson = jsonDecode(themeStr);
    return ThemeDecoder.decodeThemeData(themeJson);
  }

  String _getThemeJsonPath(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'assets/themes/theme_light.json';
      case ThemeMode.dark:
        return 'assets/themes/theme_dark.json';
      default:
        return 'assets/themes/theme_light.json';
    }
  }
}