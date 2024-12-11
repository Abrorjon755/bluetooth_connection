import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';
import '../dependency/dependency.dart';

class InitializeApp {
  static Future<AppDependency> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    // Bluetooth settings
    FlutterBluePlus.setOptions(restoreState: true);
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    // Local settings
    final shp = await SharedPreferences.getInstance();

    bool theme = shp.getBool(Constants.theme) ?? true;
    String locale = shp.getString(Constants.locale) ?? "en";

    return AppDependency(
      shp: shp,
      locale: locale,
      theme: theme,
    );
  }
}
