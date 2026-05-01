import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class UserTicketsService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/tickets";

  static Future<Map<String, dynamic>> getMyTickets() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/mytickets"),
      headers: {
        "Content-Type":  "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("TICKET STATUS: ${response.statusCode}");
    print("TICKET BODY:   ${response.body}");

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed load tickets");
    }
  }
}
