import 'package:flutter/material.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  /// DATA
  List<Map<String, dynamic>> events = [
    {
      "name": "Summer Music Fest",
      "date": "Jun 15, 2026",
      "location": "Central Park",
      "sold": 450,
      "revenue": "\$9,000",
      "status": "active",
    },
    {
      "name": "Jazz Night Live",
      "date": "Apr 28, 2026",
      "location": "Blue Note Jakarta",
      "sold": 234,
      "revenue": "\$4,680",
      "status": "active",
    },
    {
      "name": "Rock Festival 2026",
      "date": "May 5, 2026",
      "location": "GBK Stadium",
      "sold": 320,
      "revenue": "\$8,000",
      "status": "inactive",
    },
    {
      "name": "Tech Conference",
      "date": "Mar 10, 2026",
      "location": "Convention Center",
      "sold": 150,
      "revenue": "\$6,000",
      "status": "active",
    },
  ];

  String searchQuery = "";

  /// FILTER
  List<Map<String, dynamic>> get filteredEvents {
    return events.where((e) {
      return e["name"]
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

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
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Events",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Manage your events easily",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

                  /// SEARCH
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search events...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST EVENTS
            filteredEvents.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No events found"),
                  )
                : Column(
                    children: filteredEvents
                        .map((e) => _eventCard(e))
                        .toList(),
                  ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      /// FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFFE4572E),
        label: const Text("Create Event"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /// EVENT CARD
  Widget _eventCard(Map<String, dynamic> e) {
    bool isActive = e["status"] == "active";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TITLE + STATUS
          Row(
            children: [
              Expanded(
                child: Text(
                  e["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(e["date"], style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(e["location"], style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 12),

          /// STATS
          Row(
            children: [
              Expanded(
                child: _box(
                  title: "Tickets Sold",
                  value: "${e["sold"]}",
                  color: const Color(0xFFEDE6DD),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _box(
                  title: "Revenue",
                  value: e["revenue"],
                  color: const Color(0xFFE6F4EA),
                  textColor: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// BUTTONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Edit"),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4572E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("View Details"),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  /// BOX COMPONENT
  Widget _box({
    required String title,
    required String value,
    required Color color,
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 5),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }
}