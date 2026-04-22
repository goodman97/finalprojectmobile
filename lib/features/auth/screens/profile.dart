import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER PROFILE
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "A",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Alex Johnson",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "alex.johnson@email.com",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Member since March 2025",
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),

            // STATS CARD
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

                  // CONTACT INFO
                  sectionCard(
                    title: "Contact Information",
                    child: Column(
                      children: [
                        infoTile(Icons.email, "Email", "alex.johnson@email.com"),
                        infoTile(Icons.phone, "Phone", "+1 (555) 123-4567"),
                        infoTile(Icons.location_on, "Location", "New York, NY"),

                        const SizedBox(height: 10),

                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Information"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ACCOUNT
                  menuSection("Account", [
                    menuItem(Icons.person, "Edit Profile"),
                    menuItem(Icons.notifications, "Notifications"),
                    menuItem(Icons.shield, "Privacy & Security"),
                    menuItem(Icons.credit_card, "Payment Methods"),
                  ]),

                  const SizedBox(height: 20),

                  // SUPPORT
                  menuSection("Support", [
                    menuItem(Icons.help, "Help Center"),
                    menuItem(Icons.mail, "Contact Us"),
                  ]),

                  const SizedBox(height: 20),

                  // LOGOUT
                  OutlinedButton.icon(
                    onPressed: () {},
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

                  const SizedBox(height: 10),

                  const Text(
                    "Gelatix v1.0.0",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔹 STAT CARD
  Widget statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFFE4572E),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }

  // 🔹 SECTION CARD
  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  // 🔹 INFO TILE
  Widget infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  // 🔹 MENU SECTION
  Widget menuSection(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: const TextStyle(color: Colors.black54)),
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  // 🔹 MENU ITEM
  Widget menuItem(IconData icon, String title) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black54),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}