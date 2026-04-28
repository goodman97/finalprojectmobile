import 'package:flutter/material.dart';

class EOHomeScreen extends StatelessWidget {
  const EOHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("My Events",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text("Manage your events easily",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF2F3E2F)),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Expanded(child: StatCard("8", "Total Events", Icons.calendar_today)),
                  SizedBox(width: 10),
                  Expanded(child: StatCard("1,254", "Tickets Sold", Icons.confirmation_number)),
                  SizedBox(width: 10),
                  Expanded(child: StatCard("\$32,450", "Revenue", Icons.attach_money)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// UPCOMING TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Upcoming Events",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("View All",
                      style: TextStyle(color: Color(0xFFE4572E))),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// EVENT LIST
            const EventCard(
                title: "Summer Music Fest",
                date: "Jun 15, 2026",
                sold: "450/500",
                revenue: "\$9,000",
                percent: "90%"),
            const EventCard(
                title: "Jazz Night Live",
                date: "Apr 28, 2026",
                sold: "234/300",
                revenue: "\$4,680",
                percent: "78%"),
            const EventCard(
                title: "Rock Festival 2026",
                date: "May 5, 2026",
                sold: "320/500",
                revenue: "\$8,000",
                percent: "64%"),

            const SizedBox(height: 20),

            /// RECENT SALES
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Recent Sales",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SaleItem("Summer Music Fest", "12 tickets • 5 min ago", "\$240"),
                    SaleItem("Jazz Night Live", "5 tickets • 15 min ago", "\$100"),
                    SaleItem("Rock Festival 2026", "8 tickets • 32 min ago", "\$200"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),


    );
  }
}

//// ================= COMPONENTS =================

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard(this.value, this.label, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title, date, sold, revenue, percent;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.sold,
    required this.revenue,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(date),
                const SizedBox(height: 10),
                Text("Sold $sold"),
                Text("Revenue $revenue",
                    style: const TextStyle(color: Colors.orange)),
              ],
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.orange.shade100,
              child: Text(percent,
                  style: const TextStyle(color: Colors.orange)),
            )
          ],
        ),
      ),
    );
  }
}

class SaleItem extends StatelessWidget {
  final String title, subtitle, price;

  const SaleItem(this.title, this.subtitle, this.price, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(price, style: const TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }
}