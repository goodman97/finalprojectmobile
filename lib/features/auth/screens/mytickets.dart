import 'package:flutter/material.dart';

class MyTickets extends StatelessWidget {
  const MyTickets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "My Tickets",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3E2F),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text("2 active tickets"),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE4572E),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {},
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // UPCOMING
              const Text(
                "Upcoming",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              ticketCard(
                title: "Summer Music Festival",
                type: "General Admission",
                date: "Jun 15, 2026",
                location: "Central Park",
                image: "assets/images/concert.jpg",
              ),

              ticketCard(
                title: "Jazz Night Live",
                type: "VIP Pass",
                date: "Jun 20, 2026",
                location: "Blue Note Club",
                image: "assets/images/jazz.jpg",
              ),

              const SizedBox(height: 20),

              // PAST EVENTS
              const Text(
                "Past Events",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              pastTicketCard(
                title: "Broadway Spectacular",
                type: "Premium Package",
                date: "Apr 10, 2026",
                image: "assets/images/theater.jpg",
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ACTIVE TICKET CARD
  Widget ticketCard({
    required String title,
    required String type,
    required String date,
    required String location,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [

          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 10),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(type, style: const TextStyle(color: Colors.black54)),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(date),
                  ],
                ),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(location),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              const Icon(Icons.more_vert),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code, color: Color(0xFFE4572E)),
              ),
            ],
          )
        ],
      ),
    );
  }

  // PAST TICKET
  Widget pastTicketCard({
    required String title,
    required String type,
    required String date,
    required String image,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              color: Colors.grey,
              colorBlendMode: BlendMode.saturation,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(type, style: const TextStyle(color: Colors.black54)),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(date),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Used"),
          )
        ],
      ),
    );
  }
}