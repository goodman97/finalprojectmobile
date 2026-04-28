import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/eo/eo_invite_client.dart';

class ClientInvitationScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const ClientInvitationScreen({
    super.key,
    required this.event,
  });

  @override
  State<ClientInvitationScreen> createState() =>
      _ClientInvitationScreenState();
}

class _ClientInvitationScreenState
    extends State<ClientInvitationScreen> {
  final List<Map<String, dynamic>> tickets = [
    {
      "id": "TIX-CLT-001",
      "status": "assigned",
      "name": "Sarah Wilson",
      "email": "sarah.w@email.com",
      "date": "Apr 20, 2026"
    },
    {
      "id": "TIX-CLT-002",
      "status": "assigned",
      "name": "Mike Johnson",
      "email": "mike.j@email.com",
      "date": "Apr 21, 2026"
    },
    {
      "id": "TIX-CLT-003",
      "status": "available",
    },
    {
      "id": "TIX-CLT-004",
      "status": "available",
    },
    {
      "id": "TIX-CLT-005",
      "status": "assigned",
      "name": "Emma Davis",
      "email": "emma.d@email.com",
      "date": "Apr 22, 2026"
    },
  ];

  int get assigned =>
      tickets.where((t) => t["status"] == "assigned").length;

  int get available =>
      tickets.where((t) => t["status"] == "available").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      /// 🔥 FLOATING +
     floatingActionButton: FloatingActionButton(
      backgroundColor: const Color(0xFFE4572E),
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AssignTicketScreen(event: widget.event),
          ),
        );

        if (result != null) {
          setState(() {
            tickets.add(result);
          });
        }
      },
      child: const Icon(Icons.add),
    ),

      body: Column(
        children: [

          /// 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
              ),
            ),
            child: Column(
              children: [

                /// TOP BAR
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Client Invitation",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            "Manage tickets for this type",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 🔥 STATS
                Row(
                  children: [
                    _statBox("$assigned", "Assigned"),
                    const SizedBox(width: 10),
                    _statBox("$available", "Available"),
                  ],
                )
              ],
            ),
          ),

          /// 🔥 CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// TITLE
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Generated Tickets",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, i) {
                        final t = tickets[i];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              /// HEADER
                              Row(
                                children: [
                                  Text(
                                    t["id"],
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  _chip(t["status"]),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// ASSIGNED INFO
                              if (t["status"] == "assigned") ...[
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16,
                                        color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(t["name"]),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 22),
                                  child: Text(
                                    t["email"],
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 22),
                                  child: Text(
                                    "Assigned on ${t["date"]}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 CHIP
  Widget _chip(String status) {
    if (status == "assigned") {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Assigned",
          style: TextStyle(color: Colors.green, fontSize: 11),
        ),
      );
    } else {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Available",
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      );
    }
  }

  /// 🔹 STAT BOX
  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}