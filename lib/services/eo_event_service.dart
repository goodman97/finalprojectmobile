import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/utils/csv_download.dart';

class EoEventService {
  static String get base => "${ApiConfig.baseUrl}/api/events/eo";

  static Future<Map<String, String>> get _headers async {
    final token = await StorageService.getToken();
    return {
      "Authorization": "Bearer $token",
    };
  }

  // Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final r = await http.get(
      Uri.parse("$base/dashboard"),
      headers: await _headers,
    );

    print("EO DASHBOARD: ${r.statusCode}");

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Gagal load dashboard");
  }

  // My Events
  static Future<List<dynamic>> getMyEvents({String q = ""}) async {
    final uri = Uri.parse("$base/my-events")
        .replace(queryParameters: q.isNotEmpty ? {"q": q} : {});

    final r = await http.get(
      uri,
      headers: await _headers,
    );

    print("MY EVENTS: ${r.statusCode}");

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Gagal load events");
  }

  // Event Detail
  static Future<Map<String, dynamic>> getEventDetail(String id) async {
    final r = await http.get(
      Uri.parse("$base/$id"),
      headers: await _headers,
    );

    print("EO DETAIL: ${r.statusCode}");

    if (r.statusCode == 200) {
      return jsonDecode(r.body);
    }

    throw Exception("Gagal load detail event");
  }

  // CREATE EVENT
  static Future<Map<String, dynamic>> createEvent({
    required String name,
    required String address,
    required String startDate,
    required String startTime,
    String? endDate,
    required String price,
    required String quota,
    required String description,
    double? latitude,
    double? longitude,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse("$base/create");

    final req = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["name"] = name
      ..fields["address"] = address
      ..fields["start_date"] = startDate
      ..fields["start_time"] = startTime
      ..fields["price"] = price
      ..fields["quota"] = quota
      ..fields["description"] = description;

    if (endDate != null && endDate.isNotEmpty) {
      req.fields["end_date"] = endDate;
    }

    if (latitude != null) {
      req.fields["latitude"] = latitude.toString();
    }

    if (longitude != null) {
      req.fields["longitude"] = longitude.toString();
    }

    // MOBILE upload
    if (imageFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          "event_image",
          imageFile.path,
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    // WEB upload
    else if (webImage != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          "event_image",
          webImage,
          filename: "event.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    final streamed = await req.send();
    final r = await http.Response.fromStream(streamed);

    print("CREATE EVENT: ${r.statusCode} ${r.body}");

    final data = jsonDecode(r.body);

    if (r.statusCode == 200 || r.statusCode == 201) {
      return data;
    }

    throw Exception(data["message"] ?? "Gagal membuat event");
  }

  // EDIT EVENT
  static Future<Map<String, dynamic>> editEvent({
    required String id,
    String? name,
    String? address,
    String? startDate,
    String? startTime,
    String? endDate,
    String? price,
    String? quota,
    String? description,
    double? latitude,
    double? longitude,
    String? status,
    File? imageFile,
    Uint8List? webImage,
  }) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse("$base/$id/edit");

    final req = http.MultipartRequest("PUT", uri)
      ..headers["Authorization"] = "Bearer $token";

    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        req.fields[key] = value;
      }
    }

    addField("name", name);
    addField("address", address);
    addField("start_date", startDate);
    addField("start_time", startTime);
    addField("end_date", endDate);
    addField("price", price);
    addField("quota", quota);
    addField("description", description);
    addField("status", status);

    if (latitude != null) {
      req.fields["latitude"] = latitude.toString();
    }

    if (longitude != null) {
      req.fields["longitude"] = longitude.toString();
    }

    // MOBILE upload
    if (imageFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          "event_image",
          imageFile.path,
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    // WEB upload
    else if (webImage != null) {
      req.files.add(
        http.MultipartFile.fromBytes(
          "event_image",
          webImage,
          filename: "event.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }

    final streamed = await req.send();
    final r = await http.Response.fromStream(streamed);

    print("EDIT EVENT: ${r.statusCode} ${r.body}");

    final data = jsonDecode(r.body);

    if (r.statusCode == 200 || r.statusCode == 201) {
      return data;
    }

    throw Exception(data["message"] ?? "Gagal update event");
  }

  static Future<void> downloadCSVReport() async {
    final token = await StorageService.getToken();

    final response = await http.get(
      Uri.parse("$base/download-report"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    print("CSV STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      await downloadCSV(
        response.bodyBytes,
        "analytics_report.csv",
      );
    } else {
      throw Exception("Gagal download report");
    }
  }

  // GET ticket types
static Future<List<dynamic>> getTicketTypes(
  String eventId,
) async {
  final response = await http.get(
    Uri.parse(
      "${ApiConfig.baseUrl}/api/events/$eventId/ticket-types",
    ),
  );

  print(
    "GET TICKET TYPES: ${response.statusCode}",
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    "Failed load ticket types",
  );
}

// CREATE ticket type
static Future<void> createTicketType({
  required String eventId,
  required String name,
  required String price,
  required String quota,
  }) async {
    final token =
        await StorageService.getToken();

    final response = await http.post(
      Uri.parse(
        "${ApiConfig.baseUrl}/api/events/eo/$eventId/ticket-types",
      ),
      headers: {
        "Authorization":
            "Bearer $token",
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "name": name,
        "price": price,
        "quota": quota,
      }),
    );

    print(
      "CREATE TICKET TYPE: ${response.statusCode}",
    );

    if (response.statusCode != 201) {
      throw Exception(
        "Failed create ticket type",
      );
    }
  }

  static Future<void> updateTicketType({
    required String ticketTypeId,
    required String name,
    required String price,
    required String quota,
  }) async {
    final token =
        await StorageService.getToken();

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}/api/events/eo/ticket-types/$ticketTypeId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "price": price,
        "quota": quota,
      }),
    );

    print(
      "UPDATE TICKET TYPE: ${response.statusCode}",
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Failed update ticket type",
      );
    }
  }
}