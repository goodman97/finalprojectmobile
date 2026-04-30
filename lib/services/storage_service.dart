import 'storage_service_impl.dart';

class StorageService {
  // TOKEN
  static Future<void> saveToken(String token) =>
      StorageImpl.saveToken(token);

  static Future<String?> getToken() =>
      StorageImpl.getToken();

  static Future<void> clear() =>
      StorageImpl.clear();

  // BIOMETRIC
  static Future<void> setBiometric(bool value) =>
      StorageImpl.setBiometric(value);

  static Future<bool> getBiometric() =>
      StorageImpl.getBiometric();

  // ROLE
  static Future<void> saveRole(String role) =>
      StorageImpl.saveRole(role);

  static Future<String?> getRole() =>
      StorageImpl.getRole();
}