import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:5000";
    } else {
      return "http://10.149.33.204:5000";
    }
  }
}