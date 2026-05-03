import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  static bool isExpired(String token) {
    try {
      Map<String, dynamic> decoded =
          JwtDecoder.decode(token);

      print("DECODED JWT: $decoded");

      // kalau backend tidak kirim field exp
      if (!decoded.containsKey("exp")) {
        print("JWT has no exp field -> treated as valid");
        return false;
      }

      return JwtDecoder.isExpired(token);
    } catch (e) {
      print("JWT ERROR: $e");
      return true;
    }
  }

  static Map<String, dynamic> decode(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("DECODE ERROR: $e");
      return {};
    }
  }
}