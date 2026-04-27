import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/login.dart';
import 'package:finalproject/services/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String name = "";
  String email = "";
  String date_created = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await AuthService.getProfile();

      setState(() {
        name = data["name"];
        email = data["email"];
        
        DateTime parsedDate = DateTime.parse(data["created_at"]);
        date_created = parsedDate.toIso8601String().substring(0, 10);
        
        isLoading = false;
      });
    } catch (e) {
      print("ERROR PROFILE: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    // LOADING
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2F3E2F),
                    Color(0xFF4E5F4E),
                  ],
                ),
              ),
              child: Column(
                children: [

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FOTO PROFIL
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // EMAIL
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    date_created,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),

            // STATS
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: statCard("24", "Tickets Bought")),
                    const SizedBox(width: 16),
                    Expanded(child: statCard("18", "Events Attended")),
                  ],
                ),
              ),
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  sectionCard(
                    title: "Contact Information",
                    child: Column(
                      children: [
                        infoTile(Icons.email, "Email", email),
                        infoTile(Icons.phone, "Phone", "-"),
                        infoTile(Icons.location_on, "Location", "-"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  menuSection("Account", [
                    menuItem(Icons.person, "Edit Profile"),
                    menuItem(Icons.notifications, "Notifications"),
                  ]),

                  const SizedBox(height: 20),

                  menuSection("Support", [
                    menuItem(Icons.help, "Help Center"),
                  ]),

                  const SizedBox(height: 20),

                  // LOGOUT
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // COMPONENT
  Widget statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFFE4572E),
                  fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          child,
        ],
      ),
    );
  }

  Widget infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget menuSection(String title, List<Widget> items) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(title),
        ),
        ...items
      ],
    );
  }

  Widget menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}