import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/login.dart';
import 'package:finalproject/services/auth_service.dart';
import 'package:finalproject/features/auth/screens/user/edit_profile.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/notification.dart';
import 'package:finalproject/services/biometric_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "";
  String email = "";
  String dateCreated = "-";
  String telephone = "-";
  String? profileImage;
  int totalTickets = 0;
  int totalAttended = 0;
  int notificationCount = 2;
  
  bool isLoading = true;
  bool biometricEnabled = false;
  bool locationEnabled = false;
  

  @override
  void initState() {
    super.initState();
    loadProfile();
    loadLocationPreference();
  }

  Future<void> loadProfile() async {
    try {
      final data = await AuthService.getProfile();

      print("PROFILE DATA (PROFILE PAGE): $data");

      setState(() {
        name = data["name"]?.toString() ?? "-";
        email = data["email"]?.toString() ?? "-";
        telephone = data["telephone"]?.toString() ?? "-";

        if (data["profile_image"] != null &&
            data["profile_image"].toString().isNotEmpty) {
          profileImage =
              data["profile_image"].toString().replaceAll("\\", "/");
        } else {
          profileImage = null;
        }

        dateCreated = data["created_at"]?.toString() ?? "-";

        totalTickets =
            int.tryParse(data["total_tickets"].toString()) ?? 0;

        totalAttended =
            int.tryParse(data["total_attended"].toString()) ?? 0;

        isLoading = false;
      });
    } catch (e) {
      print("ERROR PROFILE PAGE: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadLocationPreference() async {
    final prefs = await SharedPreferences.getInstance();

    bool savedStatus =
        prefs.getBool("location_enabled") ?? false;

    if (!mounted) return;

    setState(() {
      locationEnabled = savedStatus;
    });
  }

  ImageProvider? getProfileImage() {
    if (profileImage != null && profileImage!.isNotEmpty) {
      final url = "${ApiConfig.baseUrl}/$profileImage";
      print("PROFILE IMAGE URL: $url");
      return NetworkImage(url);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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

            /// HEADER
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

                  // FOTO PROFILE 
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: getProfileImage(),
                    child: getProfileImage() == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),

                  const SizedBox(height: 10),

                  /// NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// EMAIL
                  Text(
                    email,
                    style: const TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 4),

                  /// DATE
                  Text(
                    dateCreated,
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),

            /// STATS
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: statCard(
                        totalTickets.toString(),
                        "Tickets Bought",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statCard(
                        totalAttended.toString(),
                        "Events Attended",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  /// CONTACT
                  sectionCard(
                    title: "Contact Information",
                    child: Column(
                      children: [
                        infoTile(Icons.email, "Email", email),
                        infoTile(Icons.phone, "Phone", telephone),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ACCOUNT
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ACCOUNT",
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

                        /// EDIT PROFILE
                        modernMenuItem(
                          icon: Icons.person,
                          title: "Edit Profile",
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfile(),
                              ),
                            );

                            if (result == true) {
                              loadProfile();
                            }
                          },
                        ),

                        dividerLine(),

                        /// NOTIFICATION
                        modernMenuItem(
                          icon: Icons.notifications,
                          title: "Notifications",
                          badgeCount: notificationCount > 0
                            ? notificationCount
                            : null,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationPage(),
                              ),
                            );

                            setState(() {
                              notificationCount = 0;
                            });
                          },
                        ),

                        dividerLine(),

                        /// LOCATION SWITCH
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                                  "Location",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                              ),

                              Switch(
                                value: locationEnabled,
                                activeColor:
                                    const Color(0xFFE4572E),
                                onChanged: (value) async {
                                  if (value) {
                                    try {
                                      bool serviceEnabled =
                                          await Geolocator
                                              .isLocationServiceEnabled();

                                      if (!serviceEnabled) {
                                        await Geolocator
                                            .openLocationSettings();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please enable GPS first",
                                            ),
                                          ),
                                        );

                                        return;
                                      }

                                      LocationPermission permission =
                                          await Geolocator.checkPermission();

                                      if (permission ==
                                          LocationPermission.denied) {
                                        permission =
                                            await Geolocator.requestPermission();
                                      }

                                      if (permission ==
                                              LocationPermission.denied ||
                                          permission ==
                                              LocationPermission.deniedForever) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Location permission denied",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final prefs =
                                        await SharedPreferences.getInstance();

                                        await prefs.setBool(
                                          "location_enabled",
                                          true,
                                        );

                                      setState(() {
                                        locationEnabled = true;
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Nearby events enabled",
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      print(e);
                                    }
                                  } else {
                                    final prefs =
                                      await SharedPreferences.getInstance();

                                      await prefs.setBool(
                                        "location_enabled",
                                        false,
                                      );

                                    setState(() {
                                      locationEnabled = false;
                                    });

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Nearby events disabled",
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        dividerLine(),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                                  "Biometric Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              Switch(
                                value: biometricEnabled,
                                activeColor: const Color(0xFFE4572E),
                                onChanged: (value) async {
                                  if (value) {
                                    bool success =
                                        await BiometricService.authenticate();

                                    if (success) {
                                      setState(() {
                                        biometricEnabled = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      biometricEnabled = false;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SUPPORT
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SUPPORT",
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
                    child: modernMenuItem(
                      icon: Icons.help,
                      title: "Help Center",
                      onTap: () {
                        /*ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Help Center coming soon",
                            ),
                          ),
                        );*/
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// LOGOUT
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
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

  /// COMPONENTS
  Widget statCard(String value, String label) {
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

  Widget menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget modernMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF2F3E2F),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badgeCount != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(0xFFE4572E),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
            ),
      onTap: onTap,
    );
  }

  Widget dividerLine() {
    return Divider(
      height: 1,
      color: Colors.grey.shade300,
    );
  }
}