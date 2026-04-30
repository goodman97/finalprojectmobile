import 'dart:html' as html;

class StorageImpl {
  static Future<void> saveToken(String token) async {
    html.window.localStorage['token'] = token;
  }

  static Future<String?> getToken() async {
    final token = html.window.localStorage['token'];
    print("TOKEN FROM LOCALSTORAGE: $token");
    return token;
  }

  static Future<void> clear() async {
    html.window.localStorage.remove('token');
    html.window.localStorage.remove('biometric');
    html.window.localStorage.remove('role');
  }

  static Future<void> setBiometric(bool value) async {
    html.window.localStorage['biometric'] = value.toString();
  }

  static Future<bool> getBiometric() async {
    return html.window.localStorage['biometric'] == "true";
  }

  static Future<void> saveRole(String role) async {
    html.window.localStorage['role'] = role;
  }

  static Future<String?> getRole() async {
    return html.window.localStorage['role'];
  }
}