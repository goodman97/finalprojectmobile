import 'dart:convert' show json;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import "package:finalproject/services/storage_service.dart";

class AuthService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/auth";

  // PROFILE
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await StorageService.getToken();

    print("TOKEN SAAT GET PROFILE: $token");

    if (token == null || token.isEmpty) {
      throw Exception("Token tidak ditemukan atau kosong");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("PROFILE STATUS: ${response.statusCode}");
    print("PROFILE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final raw = json.decode(response.body);

      final Map<String, dynamic> data = {};

      if (raw is Map) {
        raw.forEach((key, value) {
          data[key.toString()] = value;
        });
      } else {
        throw Exception("Format response bukan Map");
      }

      print("PARSED DATA: $data");
      return data;
    } else {
      throw Exception("Failed: ${response.body}");
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "password": password,
      }),
    );

    final raw = json.decode(response.body);
    final Map<String, dynamic> data = {};
    if (raw is Map) {
      raw.forEach((k, v) => data[k.toString()] = v);
    }

    if (response.statusCode == 200 && data['token'] != null) {
      await StorageService.saveToken(data['token'].toString());
    }
    return data;
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );
    final raw = json.decode(response.body);
    final Map<String, dynamic> data = {};
    if (raw is Map) raw.forEach((k, v) => data[k.toString()] = v);
    return data;
  }

  // UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile(
      String name, String email, String phone) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "name": name,
        "email": email,
        "telephone": phone,
      }),
    );
    final raw = json.decode(response.body);
    final Map<String, dynamic> data = {};
    if (raw is Map) raw.forEach((k, v) => data[k.toString()] = v);
    return data;
  }

  // UPLOAD PHOTO
  static Future uploadPhoto(dynamic file) async {
    final token = await StorageService.getToken();

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/upload-photo"),
    );
    request.headers["Authorization"] = "Bearer $token";

    if (file is File) {
      request.files.add(
        await http.MultipartFile.fromPath("photo", file.path),
      );
    } else {
      request.files.add(
        http.MultipartFile.fromBytes(
          "photo",
          file,
          filename: "upload.jpg",
        ),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();
    final raw = json.decode(resBody);
    final Map<String, dynamic> data = {};
    if (raw is Map) raw.forEach((k, v) => data[k.toString()] = v);
    return data;
  }

  // CHANGE PASSWORD
  static Future<Map<String, dynamic>> changePassword(
      String oldPass, String newPass) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/change-password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({
        "oldPassword": oldPass,
        "newPassword": newPass,
      }),
    );
    final raw = json.decode(response.body);
    final Map<String, dynamic> data = {};
    if (raw is Map) raw.forEach((k, v) => data[k.toString()] = v);
    return data;
  }
}