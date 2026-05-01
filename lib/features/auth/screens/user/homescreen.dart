import 'package:flutter/material.dart';
import 'package:finalproject/services/event_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/event_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    try {
      final data = await EventService.getEvents();

      print("EVENT DATA: $data");

      setState(() {
        events = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR GET EVENTS: $e");
      setState(() => isLoading = false);
    }
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
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

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        categoryChip("All", true),
                        categoryChip("Music", false),
                        categoryChip("Sports", false),
                        categoryChip("Theater", false),
                        categoryChip("Festival", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// TITLE
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

            /// LIST EVENT
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? const Center(child: Text("Belum ada event"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];

                            return eventCard(
                              event: event,
                              title: event['name'] ?? '-',
                              date: formatDate(event['start_date']),
                              location: event['address'] ?? '-',
                              category: "Event",
                              price: "Rp ${event['price'] ?? 0}",
                              image: event['event_image'],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// FORMAT DATE
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

  /// CATEGORY CHIP
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

  /// EVENT CARD
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

            /// IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                  child: (image != null && image.isNotEmpty)
                    ? Image.network(
                        "${ApiConfig.baseUrl}/uploads/events/$image",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            "assets/images/concert.jpg",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        "assets/images/concert.jpg",
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                ),

                /// PRICE
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
                      child: Text(
                        price,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                /// CATEGORY
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

            /// INFO
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