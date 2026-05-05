import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class RecommendationService {
  static String get _url => '${ApiConfig.baseUrl}/api/recommendations';

  static Future<Map<String, dynamic>> getRecommendations() async {
    final token = await StorageService.getToken();

    final res = await http.get(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type' : 'application/json',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception('Gagal load rekomendasi: ${res.body}');
  }
}