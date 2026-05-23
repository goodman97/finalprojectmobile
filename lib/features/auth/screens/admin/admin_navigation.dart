import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/admin/admin_homescreen.dart';
import 'package:finalproject/features/auth/screens/admin/admin_events.dart';
import 'package:finalproject/features/auth/screens/admin/admin_users.dart';
import 'package:finalproject/features/auth/screens/admin/admin_transaction.dart';
import 'package:finalproject/features/auth/screens/admin/admin_profile.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() =>
      _AdminNavigationState();
}

class _AdminNavigationState
    extends State<AdminNavigation> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const AdminHomescreen(),
    AdminEventsScreen(),
    const AdminUsersScreen(),
    const AdminTransactionsScreen(),
    const AdminProfile(),
  ];

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor:
            const Color(0xFFE4572E),
        unselectedItemColor:
            Colors.grey,
        type:
            BottomNavigationBarType.fixed,
        backgroundColor:
            Colors.white,
        elevation: 10,

        selectedLabelStyle:
            const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w500,
        ),

        unselectedLabelStyle:
            const TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w500,
        ),

        onTap: changeTab,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined,),activeIcon:AnimatedNavIcon(icon:Icons.dashboard,),label: "Dashboard",),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined,),activeIcon:AnimatedNavIcon(icon: Icons.event,),label: "Events",),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline,),activeIcon:AnimatedNavIcon(icon: Icons.people,),label: "Users",),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money_outlined,),activeIcon:AnimatedNavIcon(icon:Icons.attach_money,),label: "Transactions",),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline,),activeIcon:AnimatedNavIcon(icon: Icons.person,),label: "Profile",),
        ],
      ),
    );
  }
}

class AnimatedNavIcon
    extends StatelessWidget {
  final IconData icon;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -6),
      child: Container(
        padding:
            const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              const Color(0xFFE4572E)
                  .withOpacity(
                      0.12),
          shape:
              BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(
              0xFFE4572E),
        ),
      ),
    );
  }
}