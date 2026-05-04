import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class ValidationService {
  static String get base => "${ApiConfig.baseUrl}/api/events";

  static Future<Map<String, String>> get _headers async {
    final token = await StorageService.getToken();

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  static Future<Map<String, dynamic>> getValidationStats() async {
    final r = await http.get(
      Uri.parse("$base/tickets/validation-stats"),
      headers: await _headers,
    );

    print("VALIDATION STATS: ${r.statusCode}");
    print("BODY: ${r.body}");

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Gagal load validation stats");
  }
}