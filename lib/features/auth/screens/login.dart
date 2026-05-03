import 'package:flutter/material.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/services/biometric_service.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';
import 'package:finalproject/features/auth/screens/eo/eo_navigation.dart';
import 'package:finalproject/features/auth/screens/admin/admin_navigation.dart';
import 'package:finalproject/features/auth/screens/register.dart';
import 'package:finalproject/utils/jwt_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // LOGIN NORMAL
  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMsg("Semua field wajib diisi");
      return;
    }

    try {
      print("LOGIN BUTTON CLICKED");
      print("EMAIL: $email");

      final result =
          await AuthService.login(email, password);

      print("LOGIN RESULT: $result");

      if (result['token'] != null) {
        await StorageService.saveToken(
            result['token']);

        await StorageService.saveRole(
            result['user']['role']);

        final role = result['user']['role'];

        navigateByRole(role);
      } else {
        showMsg(
          result['message'] ?? "Login gagal",
        );
      }
    } catch (e) {
      print("LOGIN ERROR REAL: $e");

      showMsg(
        "Tidak bisa konek ke server",
      );
    }
  }

  // LOGIN BIOMETRIC
  void loginWithBiometric() async {
    String? token = await StorageService.getToken();
    bool biometricEnabled =
        await StorageService.getBiometric();

    print("TOKEN BIOMETRIC: $token");
    print("BIOMETRIC STATUS: $biometricEnabled");

    if (!biometricEnabled) {
      showMsg("Biometric belum diaktifkan");
      return;
    }

    if (token == null || token.isEmpty) {
      showMsg("Silakan login manual terlebih dahulu");
      return;
    }

    bool isExpired = JwtHelper.isExpired(token);

    if (isExpired) {
      showMsg("Session expired, silakan login ulang");
      await StorageService.clear();
      return;
    }

    bool success =
        await BiometricService.authenticate();

    if (success) {
      String? role =
          await StorageService.getRole();

      print("ROLE BIOMETRIC: $role");

      if (role == null) {
        showMsg("Role tidak ditemukan");
        return;
      }

      navigateByRole(role);
    } else {
      showMsg("Fingerprint gagal");
    }
  }

  // NAVIGASI ROLE 
  void navigateByRole(String role) {
    if (role == 'organizer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EoNavigation()),
      );
    } else if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminNavigation()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Navigation()),
      );
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // LOGO
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4572E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/images/design_logo.png',
                    width: 70,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Welcome to Gelatix",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3E2F),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Your premium ticketing experience",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email"),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "your@email.com",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password"),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: isObscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BUTTON LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4572E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: login,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== OR =====
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== BIOMETRIC BUTTON =====
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: loginWithBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text("Use Biometric Login"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFFE4572E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}