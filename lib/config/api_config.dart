import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else {
      return "http://192.168.18.18:5000";
    }
  }
}