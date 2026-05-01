import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';

class EventService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/events";

  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    print("EVENTS STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load events");
    }
  }

  static Future<Map<String, dynamic>> getEventById(String id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));

    print("EVENT DETAIL STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load event detail");
    }
  }

  static Future<List<dynamic>> getTicketTypes(String eventId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/$eventId/ticket-types"));

    print("TICKET TYPES STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load ticket types");
    }
  }
}
