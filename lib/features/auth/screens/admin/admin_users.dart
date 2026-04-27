import 'package:flutter/material.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String searchQuery = "";

  final List<Map<String, dynamic>> users = [
    {
      "name": "Sarah Wilson",
      "email": "sarah.wilson@email.com",
      "role": "user",
      "status": "active",
      "joined": "Mar 2026",
      "tickets": 12,
    },
    {
      "name": "Live Nation",
      "email": "contact@livenation.com",
      "role": "organizer",
      "status": "active",
      "joined": "Jan 2026",
      "events": 8,
    },
    {
      "name": "John Doe",
      "email": "john.doe@email.com",
      "role": "user",
      "status": "active",
      "joined": "Apr 2026",
      "tickets": 5,
    },
    {
      "name": "TechCorp Events",
      "email": "events@techcorp.com",
      "role": "organizer",
      "status": "active",
      "joined": "Feb 2026",
      "events": 3,
    },
    {
      "name": "Admin User",
      "email": "admin@gelatix.com",
      "role": "admin",
      "status": "active",
      "joined": "Dec 2025",
    },
    {
      "name": "Mike Johnson",
      "email": "mike.j@email.com",
      "role": "user",
      "status": "suspended",
      "joined": "Mar 2026",
      "tickets": 24,
    },
  ];

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((u) {
      return u["name"]
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          u["email"]
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  IconData getRoleIcon(String role) {
    switch (role) {
      case "admin":
        return Icons.shield;
      case "organizer":
        return Icons.business_center;
      default:
        return Icons.person;
    }
  }

  Color getRoleColor(String role) {
    switch (role) {
      case "admin":
        return Colors.purple;
      case "organizer":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "User Management",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Manage platform users and roles",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

                  /// SEARCH
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search users...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// USERS LIST
            Column(
              children: filteredUsers.map((u) => _userCard(u)).toList(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// USER CARD
  Widget _userCard(Map<String, dynamic> u) {
    bool isActive = u["status"] == "active";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// AVATAR
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDE5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              getRoleIcon(u["role"]),
              color: const Color(0xFF2F3E2F),
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// NAME + MENU
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        u["name"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.more_vert, color: Colors.grey)
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  u["email"],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 8),

                /// ROLE + STATUS
                Row(
                  children: [
                    _chip(
                      u["role"],
                      getRoleColor(u["role"]).withOpacity(0.2),
                      getRoleColor(u["role"]),
                    ),
                    const SizedBox(width: 8),
                    _chip(
                      isActive ? "Active" : "Suspended",
                      isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      isActive ? Colors.green : Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// STATS
                Row(
                  children: [
                    Text("Joined: ${u["joined"]}",
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    if (u["role"] == "user")
                      Text("Tickets: ${u["tickets"]}",
                          style: const TextStyle(fontSize: 12)),
                    if (u["role"] == "organizer")
                      Text("Events: ${u["events"]}",
                          style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}