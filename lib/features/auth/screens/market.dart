import 'package:flutter/material.dart';

class Market extends StatelessWidget {
  const Market({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SafeArea(
        child: Stack(
          children: [

            // MAIN CONTENT
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
                      colors: [
                        Color(0xFF2F3E2F),
                        Color(0xFF4E5F4E),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [

                      // TITLE
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
                              icon: const Icon(Icons.filter_list, color: Colors.white),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 15),

                      // SEARCH
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

                      // CATEGORY
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [

                      marketCard(
                        image: "assets/images/concert.jpg",
                        title: "Summer Music Festival",
                        type: "VIP Pass",
                        date: "Jun 15, 2026",
                        price: "\$180",
                        oldPrice: "\$199",
                        save: "Save \$19",
                      ),

                      marketCard(
                        image: "assets/images/balloon.jpg",
                        title: "Hot Air Balloon Show",
                        type: "Premium Ticket",
                        date: "Jul 01, 2026",
                        price: "\$250",
                        oldPrice: "\$275",
                        save: "Save \$25",
                      ),

                      marketCard(
                        image: "assets/images/theater.jpg",
                        title: "Broadway Spectacular",
                        type: "Premium Ticket",
                        date: "Jun 25, 2026",
                        price: "\$270",
                        oldPrice: "\$305",
                        save: "Save \$35",
                      ),

                      const SizedBox(height: 80), // ruang buat badge
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
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

  // CATEGORY CHIP
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

  // MARKET CARD
  Widget marketCard({
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
            child: Image.asset(
              image,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE4572E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(save, style: const TextStyle(color: Colors.white)),
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

                Text(type, style: const TextStyle(color: Colors.white70)),

                Text(date, style: const TextStyle(color: Colors.white70)),

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
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("View"),
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