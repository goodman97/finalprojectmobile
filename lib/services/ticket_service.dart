import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class TicketService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api";

  // Get ticket types for an event
  static Future<List<dynamic>> getTicketTypes(String eventId) async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/events/$eventId/ticket-types"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("TICKET TYPES STATUS: ${response.statusCode}");
    print("TICKET TYPES BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load ticket types");
    }
  }

  // Purchase ticket
  static Future<Map<String, dynamic>> purchase({
    required String ticketTypeId,
    required int quantity,
    String? voucherCode,
    int pointsUsed = 0,
  }) async {
    final token = await StorageService.getToken();

    final Map<String, dynamic> body = {
      "ticket_type_id": ticketTypeId,
      "quantity": quantity,
      "points_used": pointsUsed,
    };
    if (voucherCode != null) body["voucher_id"] = voucherCode;

    print("PURCHASE REQUEST BODY: $body");

    final response = await http.post(
      Uri.parse("$baseUrl/tickets/purchase"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("PURCHASE STATUS: ${response.statusCode}");
    print("PURCHASE BODY: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Purchase failed");
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    try {

      final token =
          await StorageService.getToken();

      final r = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/api/tickets/notifications/unread-count",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (r.statusCode == 200) {

        final data = jsonDecode(r.body);

        return data["total"] ?? 0;
      }

      return 0;

    } catch (e) {

      print("UNREAD NOTIF ERROR: $e");

      return 0;
    }
  }
}