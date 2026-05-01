import 'package:flutter/material.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/ticket_purchase.dart';

class EventDetail extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetail({super.key, required this.event});

  String formatDate(dynamic date) {
    if (date == null) return "-";
    try {
      final d = DateTime.parse(date.toString());
      const months = [
        "Jan","Feb","Mar","Apr","May","Jun",
        "Jul","Aug","Sep","Oct","Nov","Dec"
      ];
      return "${months[d.month - 1]} ${d.day}, ${d.year}";
    } catch (e) {
      return "-";
    }
  }

  String formatImage(dynamic image) {
    if (image == null || image.toString().isEmpty) return "";
    final img = image.toString();
    if (img.startsWith("http")) return img;
    return "${ApiConfig.baseUrl}/uploads/$img";
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = formatImage(event["event_image"] ?? event["image"]);
    final name = (event["name"] ?? "Event").toString();
    final price = event["price"] ?? 0;
    final address = (event["address"] ?? "-").toString();
    final description = (event["description"] ?? "No description available.").toString();
    final organizer = (event["organizer_name"] ?? event["organizer_id"] ?? "Organizer").toString();
    final quota = event["quota"] ?? 0;
    final date = formatDate(event["start_date"] ?? event["date"]);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // HEADER IMAGE
                Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: imageUrl.isEmpty
                          ? Image.asset(
                              "assets/images/concert.jpg",
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
                                "assets/images/concert.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    // Gradient overlay
                    Container(
                      height: 320,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xFFF5F1E8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 40,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 6)
                            ],
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Color(0xFF2F3E2F)),
                        ),
                      ),
                    ),
                    // Action buttons
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        children: [
                          _actionButton(Icons.share),
                          const SizedBox(width: 8),
                          _actionButton(Icons.favorite_border),
                        ],
                      ),
                    ),
                  ],
                ),

                // CONTENT CARD
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F3E2F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    organizer,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\$$price",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE4572E),
                                  ),
                                ),
                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        color: Color(0xFFE4572E), size: 16),
                                    SizedBox(width: 4),
                                    Text("4.8",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Info rows
                        _infoRow(Icons.calendar_today, "Date", date),
                        const SizedBox(height: 12),
                        _infoRow(Icons.location_on, "Location", address),
                        const SizedBox(height: 12),
                        _infoRow(Icons.people, "Attendees",
                            "$quota+ going"),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // About
                        const Text(
                          "About Event",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3E2F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                              color: Colors.black54, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // GET TICKETS BUTTON (sticky bottom)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketPurchase(event: event),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4572E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Get Tickets",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Icon(icon, color: const Color(0xFF2F3E2F), size: 20),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2F3E2F), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        )
      ],
    );
  }
}
