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
      EoHomescreen(),
      EoMyEvents(),
      OrganizerTickets(),
      EOProfile(),
    ];

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: screens[currentIndex],

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFFE4572E),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 10,

          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),

          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),activeIcon: AnimatedNavIcon(icon: Icons.home),label: "Home",),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined),activeIcon: AnimatedNavIcon(icon: Icons.calendar_today),label: "Events",),
            BottomNavigationBarItem(icon: Icon(Icons.confirmation_num_outlined),activeIcon: AnimatedNavIcon(icon: Icons.confirmation_num),label: "Tickets",),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),activeIcon: AnimatedNavIcon(icon: Icons.person),label: "Profile",),
          ],
        ),
      );
    }
  }

  class AnimatedNavIcon extends StatelessWidget {
  final IconData icon;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -6),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFE4572E)
              .withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE4572E),
        ),
      ),
    );
  }
}