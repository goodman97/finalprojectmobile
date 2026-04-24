import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Register> {
  int step = 1;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void nextStep() {
    if (step == 1) {
      if (nameController.text.isEmpty || emailController.text.isEmpty) {
        showMsg("Isi semua field");
        return;
      }
      setState(() => step = 2);
    } else {
      register();
    }
  }

  void register() {
    String pass = passwordController.text;
    String confirm = confirmPasswordController.text;

    if (pass != confirm) {
      showMsg("Password tidak sama");
      return;
    }

    if (pass.length < 8) {
      showMsg("Password minimal 8 karakter");
      return;
    }

    // simulasi sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Account berhasil dibuat")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // 🔙 BACK
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (step == 1) {
                      Navigator.pop(context);
                    } else {
                      setState(() => step = 1);
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 🔥 LOGO
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3E2F),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.flutter_dash, color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F3E2F)),
              ),

              const SizedBox(height: 5),

              const Text("Join Gelatix today"),

              const SizedBox(height: 20),

              // 🔥 PROGRESS
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 5,
                      color: step >= 1
                          ? const Color(0xFFE4572E)
                          : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 5,
                      color: step >= 2
                          ? const Color(0xFFE4572E)
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔥 STEP CONTENT
              Expanded(
                child: step == 1 ? stepOne() : stepTwo(),
              ),

              // 🔥 BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4572E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(step == 1 ? "Continue" : "Create Account"),
                ),
              ),

              const SizedBox(height: 20),

              // SIGN IN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Color(0xFFE4572E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 STEP 1
  Widget stepOne() {
    return Column(
      children: [
        textField("Full Name", nameController, Icons.person),
        const SizedBox(height: 15),
        textField("Email Address", emailController, Icons.email),
      ],
    );
  }

  // 🔹 STEP 2
  Widget stepTwo() {
    return Column(
      children: [
        textField("Password", passwordController, Icons.lock, true),
        const SizedBox(height: 15),
        textField("Confirm Password", confirmPasswordController, Icons.lock, true),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Password must contain:"),
              SizedBox(height: 5),
              Text("• At least 8 characters"),
              Text("• One uppercase letter"),
              Text("• One number"),
            ],
          ),
        )
      ],
    );
  }

  Widget textField(String label, TextEditingController controller,
      IconData icon,
      [bool obscure = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}