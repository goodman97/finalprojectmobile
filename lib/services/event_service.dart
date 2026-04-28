import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';

class EventService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/events";

  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load events");
    }
  }
}