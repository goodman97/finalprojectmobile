import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/login.dart';
import 'package:finalproject/services/auth_service.dart';

class EOProfile extends StatefulWidget {
  const EOProfile({super.key});

  @override
  State<EOProfile> createState() => _EOProfileState();
}

class _EOProfileState extends State<EOProfile> {
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
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.work, size: 40, color: Color(0xFF2F3E2F)),
                  ),
                  SizedBox(height: 10),
                  Text(name,
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                  Text(email,
                      style: const TextStyle(color: Colors.white70)),
                  Text("---",
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
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
                    statItem("8", "Events"),
                    statItem("1254", "Tickets", isAccent: true),
                    statItem("\$32,450", "Revenue", isGreen: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONTACT INFO
            sectionCard([
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: const Text("contact@livenation.com"),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text("Phone"),
                subtitle: const Text("+1 (555) 987-6543"),
              ),
            ], title: "Contact Information"),

            const SizedBox(height: 20),

            // ACCOUNT
            sectionTitle("ACCOUNT"),
            sectionCard([
              menuItem(Icons.person, "Edit Profile"),
              menuItem(Icons.settings, "Account Settings"),
              menuItem(Icons.notifications, "Notifications", badge: "2"),
            ]),

            const SizedBox(height: 20),

            // BUSINESS
            sectionTitle("BUSINESS"),
            sectionCard([
              menuItem(Icons.bar_chart, "Reports & Analytics"),
              menuItem(Icons.account_balance_wallet, "Payout Settings"),
            ]),

            const SizedBox(height: 20),

            // SUPPORT
            sectionTitle("SUPPORT"),
            sectionCard([
              menuItem(Icons.help_outline, "Help Center"),
              menuItem(Icons.description, "Terms & Policies"),
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
              "Gelatix Organizer v1.0.0",
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
  final bool isAccent;
  final bool isGreen;

  const statItem(this.value, this.label,
      {this.isAccent = false, this.isGreen = false, super.key});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.black;

    if (isAccent) color = const Color(0xFFE4572E);
    if (isGreen) color = Colors.green;

    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
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

Widget sectionCard(List<Widget> children, {String? title}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: title != null ? const EdgeInsets.all(15) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ...children
        ],
      ),
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