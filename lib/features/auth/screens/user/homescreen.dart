import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SafeArea(
        child: Column(
          children: [

            // !SROLL / TETAP
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // HEADER
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
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  // SEARCH BAR
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

                  // CATEGORY
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

            // SCROLL
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [

                  // FEATURED EVENT
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2F3E2F),
                          Color(0xFF4E5F4E),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.auto_awesome,
                                color: Color(0xFFE4572E), size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Featured Event",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Summer Music Festival",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "3 days of amazing performances",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE4572E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Get Tickets",
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // EVENTS
                  eventCard(
                    title: "Summer Music Festival",
                    date: "Jun 15, 2026",
                    location: "Central Park",
                    category: "Music",
                    price: "\$50",
                    image: "assets/images/concert.jpg",
                  ),

                  eventCard(
                    title: "Broadway Spectacular",
                    date: "Jun 25, 2026",
                    location: "Lincoln Center",
                    category: "Theater",
                    price: "\$45",
                    image: "assets/images/theater.jpg",
                  ),

                  eventCard(
                    title: "Championship Finals",
                    date: "Jul 10, 2026",
                    location: "Metro Stadium",
                    category: "Sports",
                    price: "\$95",
                    image: "assets/images/stadium.jpg",
                  ),

                  eventCard(
                    title: "Modern Art Showcase",
                    date: "Jun 30, 2026",
                    location: "Downtown Gallery",
                    category: "Art",
                    price: "\$35",
                    image: "assets/images/gallery.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 CATEGORY CHIP
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

  // 🎟️ EVENT CARD
  Widget eventCard({
    required String title,
    required String date,
    required String location,
    required String category,
    required String image,
    String? price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // 🔥 AUTO JARAK
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              if (price != null)
                Positioned(
                  right: 10,
                  top: 10,
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

              Positioned(
                left: 10,
                bottom: 10,
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(date),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(location),
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