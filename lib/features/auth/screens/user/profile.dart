import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finalproject/controller/profile_controller.dart';
import 'package:finalproject/features/auth/screens/login.dart';
import 'package:finalproject/features/auth/screens/user/edit_profile.dart';
import 'package:finalproject/features/auth/screens/user/notification.dart';
import 'package:finalproject/config/api_config.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController ctrl = Get.put(ProfileController());

    return Obx(() {

      if (ctrl.isLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF5F1E8),
        body: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  gradient: LinearGradient(
                    colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                  ),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Foto profil
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImage(ctrl),
                      child: _getProfileImage(ctrl) == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),

                    const SizedBox(height: 10),

                    // Nama
                    Text(
                      ctrl.name.value,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ctrl.email.value,
                      style: const TextStyle(color: Colors.white70),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      ctrl.dateCreated.value,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          ctrl.totalTickets.value.toString(),
                          'Tickets Bought',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _statCard(
                          ctrl.totalAttended.value.toString(),
                          'Events Attended',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [

                    // CONTACT INFO
                    _sectionCard(
                      title: 'Contact Information',
                      child: Column(
                        children: [
                          _infoTile(Icons.email, 'Email', ctrl.email.value),
                          _infoTile(Icons.phone, 'Phone', ctrl.telephone.value),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ACCOUNT',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [

                          // Edit Profile 
                          _modernMenuItem(
                            icon: Icons.person,
                            title: 'Edit Profile',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfile(),
                                ),
                              );
                              if (result == true) ctrl.loadProfile();
                            },
                          ),

                          _divider(),

                          // Notifications 
                          _modernMenuItem(
                            icon: Icons.notifications,
                            title: 'Notifications',
                            badgeCount: ctrl.notificationCount.value > 0
                                ? ctrl.notificationCount.value
                                : null,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationPage(),
                                ),
                              );
                              // Reload badge setelah notifikasi dibaca
                              ctrl.loadNotificationCount();
                            },
                          ),

                          _divider(),

                          // Location Switch
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF2F3E2F),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Location',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Obx(() => Switch(
                                  value: ctrl.locationEnabled.value,
                                  activeColor: const Color(0xFFE4572E),
                                  onChanged: (val) async {
                                    // Logika ada di controller, bukan di sini
                                    final msg = await ctrl.toggleLocation(val);
                                    if (msg.isNotEmpty && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    }
                                  },
                                )),
                              ],
                            ),
                          ),

                          _divider(),

                          // Biometric Switch 
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.fingerprint,
                                  color: Color(0xFF2F3E2F),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Biometric Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Obx(() => Switch(
                                  value: ctrl.biometricEnabled.value,
                                  activeColor: const Color(0xFFE4572E),
                                  onChanged: (val) async {
                                    final msg = await ctrl.toggleBiometric(val);
                                    if (msg.isNotEmpty && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    }
                                  },
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// LOGOUT 
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ctrl.logout();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Log Out',
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
              ),
            ],
          ),
        ),
      );
    });
  }

  // Helper methods (static, tidak butuh state) 
  ImageProvider? _getProfileImage(ProfileController ctrl) {
    final img = ctrl.profileImage.value;
    if (img != null && img.isNotEmpty) {
      return NetworkImage('${ApiConfig.baseUrl}/$img');
    }
    return null;
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(label),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
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

  Widget _infoTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _modernMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2F3E2F)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: badgeCount != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE4572E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade300);
}