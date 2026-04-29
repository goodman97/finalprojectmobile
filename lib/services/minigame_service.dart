import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class MiniGameService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/minigame";

  // 🔹 GET DATA
  static Future<Map<String, dynamic>> getGameData() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("GAME STATUS: ${response.statusCode}");
    print("GAME BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed load game data");
    }
  }

  // 🔹 SPIN
  static Future<Map<String, dynamic>> spin() async {
    final token = await StorageService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/spin"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("SPIN STATUS: ${response.statusCode}");
    print("SPIN BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Spin failed");
    }
  }
}