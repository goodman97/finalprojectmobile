import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/homescreen.dart';
import 'package:finalproject/features/auth/screens/profile.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _ScreenState();
}

class _ScreenState extends State<FirstScreen> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    Center(child: Text("Tickets")),
    Center(child: Text("Market")),
    Center(child: Text("Game")),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFFE4572E),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: "Game"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}