import 'package:flutter/material.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/ticket_purchase.dart';
import 'package:finalproject/services/recomendation_service.dart';

class EventDetail extends StatefulWidget {
  final Map<String, dynamic> event;

  const EventDetail({super.key, required this.event});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  Map<String, dynamic> get event => widget.event;

  @override
  void initState() {
    super.initState();
    final eventId = event['id']?.toString() ?? '';
    if (eventId.isNotEmpty) {
      RecommendationService.trackView(eventId);
    }
  }

  void _showFloatingNotificationBanner({
    required String eventName,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    late AnimationController animCtrl;

    animCtrl = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 400),
    );

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeOutBack));

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: animCtrl, curve: Curves.easeIn));

    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: AnimatedBuilder(
          animation: animCtrl,
          builder: (_, __) => FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F3E2F),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4572E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.confirmation_number,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '🎉 Pembelian Berhasil!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              eventName.isNotEmpty
                                  ? 'Tiket "$eventName" sudah tersimpan'
                                  : 'Tiket kamu sudah tersimpan di akunmu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol tutup
                      GestureDetector(
                        onTap: () {
                          animCtrl.reverse().then((_) {
                            entry.remove();
                            animCtrl.dispose();
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.6),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    animCtrl.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        animCtrl.reverse().then((_) {
          if (entry.mounted) entry.remove();
          animCtrl.dispose();
        });
      }
    });
  }

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
    if (image == null || image.toString().isEmpty) {
      return "";
    }

    final img = image.toString();
    final base = ApiConfig.baseUrl;

    if (img.startsWith("http")) {
      return img;
    }

    if (img.startsWith("/uploads/")) {
      return "$base$img";
    }

    if (img.startsWith("uploads/")) {
      return "$base/$img";
    }

    return "$base/uploads/events/$img";
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = formatImage(event["event_image"] ?? event["image"]);
    final name = (event["name"] ?? "Event").toString();
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
                  ],
                ),

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
                                  "Rp ${event['price'] ?? 0}",
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE4572E),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        _infoRow(Icons.calendar_today, "Date", date),
                        const SizedBox(height: 12),
                        _infoRow(Icons.location_on, "Location", address),
                        const SizedBox(height: 12),
                        _infoRow(Icons.people, "Attendees",
                            "$quota+ going"),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

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

          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final purchased = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketPurchase(event: event),
                    ),
                  );
                  if (purchased == true && mounted) {
                    final eventName = (event['name'] ?? '').toString();
                    _showFloatingNotificationBanner(eventName: eventName);
                  }
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2F3E2F),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                softWrap: true,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
