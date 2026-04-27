import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/admin/admin_homescreen.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
 State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int currentIndex = 0;

  final screens = [
    const AdminHomescreen(),
    const Center(child: Text("Events")),
    const Center(child: Text("Users")),
    const Center(child: Text("Transactions")),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFE4572E),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Transactions"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}