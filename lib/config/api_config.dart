import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // untuk web (Chrome)
    if (kIsWeb) {
      return "http://localhost:5000";
    }

    // untuk Android emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000";
    }

    // untuk iOS / desktop
    return "http://192.168.100.238:5000";
  }
}