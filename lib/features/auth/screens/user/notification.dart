import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() =>
      _NotificationState();
}

class _NotificationState
    extends State<NotificationPage> {

  List notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    markAllAsRead();
  }

  Future<void> loadNotifications() async {
    try {
      final token =
          await StorageService.getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/api/auth/notifications",
        ),
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications =
              jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final token = await StorageService.getToken();

      await http.put(
        Uri.parse(
          "${ApiConfig.baseUrl}/api/auth/read-notifications",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : notifications.isEmpty
              ? const Center(
                  child:
                      Text("No notifications"),
                )
              : ListView.builder(
                  itemCount:
                      notifications.length,
                  itemBuilder:
                      (context, index) {
                    final notif =
                        notifications[index];

                    // Notifikasi yang sudah dibaca tampil abu-abu
                    final bool isRead =
                        notif["is_read"] == true ||
                        notif["is_read"] == 1 ||
                        notif["is_read"].toString() == "true";

                    final Color bgColor = isRead
                        ? const Color(0xFFE8E8E8)
                        : const Color(0xFFF5F1E8);

                    final Color iconBgColor = isRead
                        ? Colors.grey
                        : const Color(0xFFE4572E);

                    final Color titleColor = isRead
                        ? Colors.grey.shade600
                        : const Color(0xFF2F3E2F);

                    final Color borderColor = isRead
                        ? Colors.grey.withOpacity(0.25)
                        : const Color(0xFFE4572E).withOpacity(0.25);

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigation.setIndex(context, 4,);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 14,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            // left icon section
                            Container(
                              width: 85,
                              height: 90,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  bottomLeft: Radius.circular(22),
                                ),
                              ),
                              child: const Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  SizedBox(height: 6),
                                ],
                              ),
                            ),

                            // right content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notif["title"] ?? "-",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.bold,
                                              color: titleColor,
                                            ),
                                          ),
                                        ),
                                        // dot merah jika belum dibaca
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      notif["message"] ?? "-",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isRead
                                            ? Colors.grey.shade400
                                            : Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isRead
                                            ? Colors.grey.withOpacity(0.12)
                                            : const Color(0xFFE4572E).withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "Lanjut",
                                        style: TextStyle(
                                          color: isRead
                                              ? Colors.grey
                                              : const Color(0xFFE4572E),
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}