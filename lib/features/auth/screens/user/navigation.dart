import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/user/homescreen.dart';
import 'package:finalproject/features/auth/screens/user/profile.dart';
import 'package:finalproject/features/auth/screens/user/mytickets.dart';
import 'package:finalproject/features/auth/screens/user/market.dart';
import 'package:finalproject/features/auth/screens/user/minigame.dart';
import 'package:finalproject/features/auth/screens/user/map.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  static void setIndex(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_ScreenState>();
    state?.changeTab(index);
  }

  @override
  State<Navigation> createState() => _ScreenState();
}

class _ScreenState extends State<Navigation> {
  
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pages = const [
    HomeScreen(),
    UserMapScreen(),
    MyTickets(),
    Market(),
    MiniGame(),
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

      onTap: changeTab,

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),activeIcon: AnimatedNavIcon(icon: Icons.home,),label: "Home",),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined),activeIcon: AnimatedNavIcon(icon: Icons.location_on),label: "Map",),
        BottomNavigationBarItem(icon: Icon(Icons.confirmation_num_outlined),activeIcon: AnimatedNavIcon(icon: Icons.confirmation_num),label: "Tickets",),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined),activeIcon: AnimatedNavIcon(icon: Icons.store),label: "Market",),
        BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined),activeIcon: AnimatedNavIcon(icon: Icons.sports_esports),label: "Game",),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline),activeIcon: AnimatedNavIcon(icon: Icons.person),label: "Profile",),
      ],
    )
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