import 'package:flutter/material.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';
import 'package:finalproject/features/auth/screens/eo/eo_navigation.dart';
import 'package:finalproject/features/auth/screens/admin/admin_navigation.dart';
import 'package:finalproject/features/auth/screens/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscure = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // LOGIN FUNCTION
  void login() async {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMsg("Semua field wajib diisi");
      return;
    }

    try {
      final result = await AuthService.login(email, password);

      if (result['token'] != null) {
        // simpan token
        await StorageService.saveToken(result['token']);

        // ambil role dari backend
        final role = result['user']['role'];

        // REDIRECT BERDASARKAN ROLE
        if (role == 'organizer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EONavigation(),
            ),
          );
        } 
        else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminNavigation(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Navigation(),
            ),
          );
        }
      } else {
        showMsg(result['message'] ?? "Login gagal");
      }
    } catch (e) {
      showMsg("Tidak bisa konek ke server");
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

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4572E),
                      elevation: 5,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: login,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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