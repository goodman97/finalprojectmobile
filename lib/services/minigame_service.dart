import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class MiniGameService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/minigame";

  // GET DATA (points, spins, vouchers, tickets)
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
      final data = jsonDecode(response.body);
      if (data["vouchers"] == null) data["vouchers"] = [];
      if (data["tickets"] == null) data["tickets"] = 0;
      return data;
    } else {
      throw Exception("Failed load game data");
    }
  }

  // SPIN (Spin Wheel — Accelerometer)
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

  // SUBMIT MAZE WIN (Tilt Maze — Gyroscope)
  static Future<Map<String, dynamic>> submitMazeWin({
    required int points,
  }) async {
    final token = await StorageService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/maze-win"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"points": points}),
    );

    print("MAZE WIN STATUS: ${response.statusCode}");
    print("MAZE WIN BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Submit maze win failed");
    }
  }
}