  import 'package:flutter/material.dart';
  import 'package:finalproject/features/auth/screens/eo/eo_homescreen.dart';
  import 'package:finalproject/features/auth/screens/eo/eo_profile.dart';
  import 'package:finalproject/features/auth/screens/eo/eo_scan.dart';
  import 'package:finalproject/features/auth/screens/eo/eo_my_events.dart';

  class EoNavigation extends StatefulWidget {
    const EoNavigation({super.key});

    @override
    State<EoNavigation> createState() => _EoNavigationState();
  }

  class _EoNavigationState extends State<EoNavigation> {
    int currentIndex = 0;

    final screens = [
      const EoHomescreen(),
      EoMyEvents(),
      OrganizerTickets(),
      const EOProfile(),
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
            BottomNavigationBarItem(icon: Icon(Icons.event), label: "My Events"),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_number), label: "Tickets"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      );
    }
  }