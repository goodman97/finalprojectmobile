import 'package:flutter/material.dart';
import 'package:finalproject/services/event_service.dart';
import 'package:finalproject/services/recomendation_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/event_detail.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';
import 'package:finalproject/features/auth/screens/user/notification.dart';
import 'package:finalproject/features/auth/screens/chat/chat_bot_page.dart';
import 'package:finalproject/services/ticket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List events    = [];
  List allEvents = [];
  List recommendedEvents = [];

  final TextEditingController searchCtrl = TextEditingController();
  bool isLoading          = true;
  bool isLoadingRecommend = true;
  int  notificationCount  = 0;

  @override
  void initState() {
    super.initState();
    fetchEvents();
    fetchRecommendations();
    loadNotificationCount();
  }

  // Fetch semua event
  void fetchEvents() async {
    try {
      final data = await EventService.getEvents();
      setState(() {
        allEvents = data;
        events    = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR GET EVENTS: $e");
      setState(() => isLoading = false);
    }
  }

  // Fetch rekomendasi AI
  void fetchRecommendations() async {
    try {
      final data = await RecommendationService.getRecommendations();
      // data = { "source": "content_based", "events": [...] }
      setState(() {
        recommendedEvents  = data["events"] ?? [];
        isLoadingRecommend = false;
      });
    } catch (e) {
      print("ERROR GET RECOMMENDATIONS: $e");
      setState(() => isLoadingRecommend = false);
    }
  }

  void loadNotificationCount() async {
    final total =
        await TicketService.getUnreadNotificationCount();

    if (!mounted) return;

    setState(() {
      notificationCount = total;
    });
  }

  void searchEvents(String keyword) {
    if (keyword.isEmpty) {
      setState(() => events = allEvents);
      return;
    }
    final filtered = allEvents.where((event) {
      final name    = (event["name"]    ?? "").toString().toLowerCase();
      final address = (event["address"] ?? "").toString().toLowerCase();
      return name.contains(keyword.toLowerCase()) ||
          address.contains(keyword.toLowerCase());
    }).toList();
    setState(() => events = filtered);
  }

  String formatImage(dynamic image) {
    if (image == null || image.toString().isEmpty) return "";
    final img  = image.toString();
    final base = ApiConfig.baseUrl;
    if (img.startsWith("http"))       return img;
    if (img.startsWith("/uploads/"))  return "$base$img";
    if (img.startsWith("uploads/"))   return "$base/$img";
    return "$base/uploads/events/$img";
  }

  String formatDate(String? date) {
    if (date == null) return "-";
    try {
      final parsed = DateTime.parse(date);
      return "${parsed.day} ${_month(parsed.month)} ${parsed.year}";
    } catch (e) {
      return "-";
    }
  }

  String _month(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May",
      "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER 
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Discover",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3E2F),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Find your next experience",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      // CHATBOT ICON
                      IconButton(
                        icon: const Icon(Icons.smart_toy_outlined,
                            color: Color(0xFF2F3E2F)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatBotPage()),
                          );
                        },
                      ),
                      // NOTIFICATION ICON
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Color(0xFF2F3E2F)),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const NotificationPage()),
                              );
                              loadNotificationCount();
                            },
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchCtrl,
                    onChanged: searchEvents,
                    decoration: InputDecoration(
                      hintText: "Search events...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE BODY 
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [

                  /// NEARBY EVENTS BANNER 
                  GestureDetector(
                    onTap: () => Navigation.setIndex(context, 1),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE4572E), Color(0xFFF47C48)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nearby Events",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              SizedBox(height: 4),
                              Text("Explore events on the map",
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// AI RECOMMENDATIONS 
                  if (!isLoadingRecommend && recommendedEvents.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome,
                              color: Color(0xFFE4572E), size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Recommended for You",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3E2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: recommendedEvents.length,
                        itemBuilder: (ctx, i) {
                          final ev = recommendedEvents[i];
                          return _recommendCard(ev);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Shimmer saat loading rekomendasi
                  if (isLoadingRecommend) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Row(
                        children: const [
                          Icon(Icons.auto_awesome,
                              color: Color(0xFFE4572E), size: 18),
                          SizedBox(width: 6),
                          Text(
                            "Recommended for You",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3E2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: 3,
                        itemBuilder: (_, __) => Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  /// UPCOMING EVENTS TITLE 
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Upcoming Events",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3E2F),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  /// EVENT LIST 
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : events.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text("Belum ada event"),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return eventCard(
                                  event: event,
                                  title: event['name'] ?? '-',
                                  date: formatDate(event['start_date']),
                                  location: event['address'] ?? '-',
                                  category: (event['genre'] ?? 'Event')
                                      .toString()
                                      .split(',')
                                      .first
                                      .trim(),
                                  price: "Rp ${event['price'] ?? 0}",
                                  image: formatImage(event['event_image']),
                                );
                              },
                            ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Horizontal recommendation card 
  Widget _recommendCard(Map ev) {
    final image = formatImage(ev['event_image']);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EventDetail(event: Map<String, dynamic>.from(ev)),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/concert.jpg",
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      "assets/images/concert.jpg",
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev['name'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF2F3E2F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 10, color: Colors.grey),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          formatDate(ev['start_date']),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if ((ev['genre'] ?? '').toString().isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: (ev['genre'] as String)
                          .split(',')
                          .map((g) => g.trim())
                          .where((g) => g.isNotEmpty)
                          .take(2)
                          .map((g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F3E2F)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    color: Color(0xFF2F3E2F),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4572E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Rp ${ev['price'] ?? 0}",
                      style: const TextStyle(
                        color: Color(0xFFE4572E),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryChip(String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(title),
        backgroundColor:
            active ? const Color(0xFFE4572E) : Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget eventCard({
    required Map event,
    required String title,
    required String date,
    required String location,
    required String category,
    required String? image,
    String? price,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetail(
              event: Map<String, dynamic>.from(event),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25)),
                  child: (image != null && image.isNotEmpty)
                      ? Image.network(
                          image,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            "assets/images/concert.jpg",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          "assets/images/concert.jpg",
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                if (price != null)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4572E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(price,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(category),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3E2F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if ((event['genre'] ?? '').toString().isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: (event['genre'] as String)
                          .split(',')
                          .map((g) => g.trim())
                          .where((g) => g.isNotEmpty)
                          .map((g) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F3E2F)
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  g,
                                  style: const TextStyle(
                                    color: Color(0xFF2F3E2F),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14),
                      const SizedBox(width: 5),
                      Text(date),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}