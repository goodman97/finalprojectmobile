import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/eo/eo_tickettype.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String tab = "overview";

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Event Details",
                            style: TextStyle(color: Colors.white)),
                        Text(e["name"],
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.share, color: Colors.white),
                  const SizedBox(width: 10),
                  const Icon(Icons.edit, color: Colors.white),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  /// 🔥 INFO CARD
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row(Icons.calendar_today, "Date & Time",
                            "${e["date"]} at 18:00"),
                        const SizedBox(height: 10),
                        _row(Icons.location_on, "Location", e["location"]),
                        const SizedBox(height: 10),
                        const Text(
                          "Join us for an unforgettable evening of live music featuring top artists from around the world.",
                          style: TextStyle(fontSize: 12),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 STATS
                  Row(
                    children: [
                      Expanded(
                        child: _card(
                          child: Column(
                            children: [
                              const Text("Tickets Sold"),
                              const SizedBox(height: 5),
                              Text("${e["sold"]}/500",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const Text("90% capacity",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12))
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _card(
                          child: Column(
                            children: const [
                              Text("Revenue"),
                              SizedBox(height: 5),
                              Text("\$9,000",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Text("+18% vs last week",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 12))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 SALES
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sales Statistics"),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _stat("24", "Today"),
                            _stat("132", "This Week"),
                            _stat("450", "This Month"),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 TABS
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _tab("overview"),
                        _tab("buyers"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🔥 CONTENT
                  tab == "overview"
                      ? _quickActions()
                      : _buyersList(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: child,
    );
  }

  /// 🔹 ROW
  Widget _row(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11)),
            Text(value),
          ],
        )
      ],
    );
  }

  /// 🔹 STAT
  Widget _stat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6DD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  /// 🔹 TAB
  Widget _tab(String t) {
    bool active = tab == t;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = t),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFE4572E) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              t == "overview" ? "Overview" : "Buyers (4)",
              style: TextStyle(
                color: active ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 QUICK ACTIONS
  Widget _quickActions() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions"),
          const SizedBox(height: 10),
          _btn("Manage Ticket Types",
           Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientInvitationScreen(event: widget.event),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _btn("Share Event", Colors.green),
          const SizedBox(height: 10),
          _btnOutline("Download Report"),
        ],
      ),
    );
  }

  Widget _buyersList() {
    return const Text("Buyers List (dummy)");
  }

  Widget _btn(String text, Color color, {VoidCallback? onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _btnOutline(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}