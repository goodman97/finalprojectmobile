import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;
      bool isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) return false;

      return await auth.authenticate(
        localizedReason: 'Scan fingerprint untuk login',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }
}