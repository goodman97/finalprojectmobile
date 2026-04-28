import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  static bool isExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  static Map<String, dynamic> decode(String token) {
    return JwtDecoder.decode(token);
  }
}