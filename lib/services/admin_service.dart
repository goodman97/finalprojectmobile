import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class AdminService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/admin";

  /// Fetch transactions with optional filters
  static Future<List<Map<String, dynamic>>> getTransactions({
    String? status,
    String? search,
  }) async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan atau kosong");
    }

    String url = "$baseUrl/transactions";
    final queryParams = <String, String>{};

    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (queryParams.isNotEmpty) {
      url += '?' + queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    }

    print("Fetching from: $url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final raw = json.decode(response.body);

      if (raw is Map && raw['success'] == true) {
        final List<dynamic> dataList = raw['data'] ?? [];
        return dataList.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Response format tidak sesuai");
      }
    } else {
      throw Exception("Failed: ${response.statusCode} - ${response.body}");
    }
  }

  /// Get transaction stats
  static Future<Map<String, int>> getTransactionStats() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan atau kosong");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final raw = json.decode(response.body);
      
      if (raw is Map && raw['stats'] != null) {
        return Map<String, int>.from(raw['stats']);
      }
    }

    return {};
  }
}
