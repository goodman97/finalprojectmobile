import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageImpl {
  static const storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  static Future<void> clear() async {
    await storage.deleteAll();
  }

  static Future<void> setBiometric(bool value) async {
    await storage.write(key: "biometric", value: value.toString());
  }

  static Future<bool> getBiometric() async {
    String? value = await storage.read(key: "biometric");
    return value == "true";
  }

  static Future<void> saveRole(String role) async {
    await storage.write(key: "role", value: role);
  }

  static Future<String?> getRole() async {
    return await storage.read(key: "role");
  }
}