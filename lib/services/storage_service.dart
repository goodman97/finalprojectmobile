import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html show window;

class StorageService {
  static const storage = FlutterSecureStorage();

  // TOKEN 
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage["token"] = token;
    } else {
      await storage.write(key: "token", value: token);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      final token = html.window.localStorage["token"];
      print("TOKEN FROM LOCALSTORAGE: $token");
      return token;
    }
    return await storage.read(key: "token");
  }

  static Future<void> clear() async {
    if (kIsWeb) {
      html.window.localStorage.remove("token");
      html.window.localStorage.remove("biometric");
      html.window.localStorage.remove("role");
    } else {
      await storage.deleteAll();
    }
  }

  // BIOMETRIC
  static Future<void> setBiometric(bool value) async {
    if (kIsWeb) {
      html.window.localStorage["biometric"] = value.toString();
    } else {
      await storage.write(key: "biometric", value: value.toString());
    }
  }

  static Future<bool> getBiometric() async {
    if (kIsWeb) {
      return html.window.localStorage["biometric"] == "true";
    }
    String? value = await storage.read(key: "biometric");
    return value == "true";
  }

  // ROLE
  static Future<void> saveRole(String role) async {
    if (kIsWeb) {
      html.window.localStorage["role"] = role;
    } else {
      await storage.write(key: "role", value: role);
    }
  }

  static Future<String?> getRole() async {
    if (kIsWeb) {
      return html.window.localStorage["role"];
    }
    return await storage.read(key: "role");
  }
}