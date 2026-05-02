import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class EventService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/events";

  // GET EVENTS
  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    print("GET EVENTS STATUS: ${response.statusCode}");
    print("GET EVENTS BODY: ${response.body}");


    if (response.statusCode == 200) {
      // ❗ kalau backend error (HTML)
      if (response.body.startsWith("<")) {
        throw Exception("Server error (HTML response)");
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      } else {
        throw Exception("Format data bukan list");
      }
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  // CREATE EVENT
  static Future<Map<String, dynamic>> createEvent({
    required String name,
    required String location,
    required String description,
    required String startDate,
    required String endDate,
    required String price,
    required String quota,
    File? image,
    Uint8List? webImage,
  }) async {
    final token = await StorageService.getToken();

    print("TOKEN: $token");

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/create"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["name"] = name;
    request.fields["address"] = location;
    request.fields["description"] = description;
    request.fields["start_date"] = startDate;
    request.fields["end_date"] = endDate;
    request.fields["price"] = price;
    request.fields["quota"] = quota;

    // DEBUG FIELD
    print("FIELDS: ${request.fields}");

    if (kIsWeb && webImage != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          webImage,
          filename: "upload.jpg",
        ),
      );
    } else if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath("image", image.path),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    print("CREATE EVENT STATUS: ${response.statusCode}");
    print("CREATE EVENT BODY: $resBody");

    if (resBody.startsWith("<")) {
      throw Exception("Server error (HTML)");
    }

    final decoded = jsonDecode(resBody);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else {
      throw Exception("Response bukan JSON object");
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
