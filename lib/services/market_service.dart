import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';

class MarketService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/market";

  static Future<List<dynamic>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    print("MARKET STATUS: ${response.statusCode}");
    print("MARKET BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed load market");
    }
  }
}