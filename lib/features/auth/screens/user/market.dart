import 'package:flutter/material.dart';
import 'package:finalproject/services/market_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/event_detail.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  List events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final data = await MarketService.getEvents();
      setState(() {
        events = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR MARKET: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(dynamic date) {
    if (date == null) return "-";
    try {
      final d = DateTime.parse(date.toString());
      return "${d.day}/${d.month}/${d.year}";
    } catch (e) {
      return "-";
    }
  }

  String formatPrice(dynamic price) {
    if (price == null) return "\$0";
    return "\$${price.toString()}";
  }

  String formatImage(dynamic image) {
    if (image == null || image.toString().isEmpty) return "";
    return "${ApiConfig.baseUrl}/uploads/${image.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Marketplace",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Verified resale tickets",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: IconButton(
                              icon: const Icon(Icons.filter_list,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Search events...",
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          categoryChip("All", true),
                          categoryChip("Best Deals", false),
                          categoryChip("Premium", false),
                        ],
                      )
                    ],
                  ),
                ),

                // LIST
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            ...events.map((item) {
                              return marketCard(
                                event: item,
                                image: formatImage(item["image"]),
                                title: (item["name"] ?? "-").toString(),
                                type: "Premium Ticket",
                                date: formatDate(item["date"]),
                                price: formatPrice(item["price"]),
                                oldPrice: formatPrice(
                                  (int.tryParse(item["price"].toString()) ??
                                          0) +
                                      20000,
                                ),
                                save: "Save",
                              );
                            }).toList(),
                            const SizedBox(height: 80),
                          ],
                        ),
                ),
              ],
            ),

            // BUYER PROTECTION
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Color(0xFFE4572E)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Buyer Protection",
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "All tickets are verified and secured",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
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
  }

  Widget categoryChip(String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: Chip(
        label: Text(title),
        backgroundColor: active ? const Color(0xFFE4572E) : Colors.white,
        labelStyle: TextStyle(
          color: active ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget marketCard({
    required Map event,
    required String image,
    required String title,
    required String type,
    required String date,
    required String price,
    required String oldPrice,
    required String save,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: image.isEmpty
                ? Image.asset(
                    "assets/images/concert.jpg",
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Image.asset(
                        "assets/images/concert.jpg",
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
          ),

          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            right: 10,
            top: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE4572E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(save,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),

          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Verified"),
                ),
                const SizedBox(height: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(type,
                    style: const TextStyle(color: Colors.white70)),
                Text(date,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(price,
                            style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        Text(oldPrice,
                            style: const TextStyle(
                                color: Colors.white54,
                                decoration:
                                    TextDecoration.lineThrough)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetail(event: Map<String, dynamic>.from(event)),
                          ),
                        );
                      },
                      child: const Text("View",
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
