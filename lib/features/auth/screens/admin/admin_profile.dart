import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/login.dart';
import 'package:finalproject/services/auth_service.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  String name = "";
  String email = "";
  String role = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await AuthService.getProfile();

    setState(() {
      name = data["name"];
      email = data["email"];
      role = data["role"];
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFF2F3E2F)),
                  ),
                  SizedBox(height: 10),
                  Text(name,
                      style: const TextStyle(color: Colors.white, fontSize: 20)),
                  Text(email,
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    statItem("24", "Events"),
                    statItem("1.8K", "Tickets"),
                    statItem("3.4K", "Users"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ACCOUNT
            sectionTitle("ACCOUNT"),
            sectionCard([
              menuItem(Icons.person, "Personal Information"),
              menuItem(Icons.settings, "Account Settings"),
              menuItem(Icons.notifications, "Notifications", badge: "3"),
            ]),

            const SizedBox(height: 20),

            // SECURITY
            sectionTitle("SECURITY"),
            sectionCard([
              menuItem(Icons.security, "Security & Privacy"),
              menuItem(Icons.description, "Activity Log"),
            ]),

            const SizedBox(height: 20),

            // SUPPORT
            sectionTitle("SUPPORT"),
            sectionCard([
              menuItem(Icons.help_outline, "Help Center"),
              menuItem(Icons.article, "Terms & Policies"),
            ]),

            const SizedBox(height: 20),

            // LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Gelatix Admin v1.0.0",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// COMPONENT

class statItem extends StatelessWidget {
  final String value, label;
  const statItem(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE4572E))),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

Widget sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget sectionCard(List<Widget> children) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(children: children),
    ),
  );
}

Widget menuItem(IconData icon, String title, {String? badge}) {
  return Column(
    children: [
      ListTile(
        leading: Icon(icon, color: const Color(0xFF2F3E2F)),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4572E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}