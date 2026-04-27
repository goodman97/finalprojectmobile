import 'package:flutter/material.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String filter = "all";
  String searchQuery = "";

  final List<Map<String, dynamic>> events = [
    {
      "id": 1,
      "name": "Summer Music Fest",
      "organizer": "Live Nation",
      "date": "Jun 15, 2026",
      "location": "Central Park",
      "status": "active",
      "isActive": true,
    },
    {
      "id": 2,
      "name": "Jazz Night Live",
      "organizer": "Blue Note Events",
      "date": "Apr 28, 2026",
      "location": "Blue Note Jakarta",
      "status": "active",
      "isActive": true,
    },
    {
      "id": 3,
      "name": "Tech Conference 2026",
      "organizer": "TechCorp Inc.",
      "date": "May 5, 2026",
      "location": "Convention Center",
      "status": "active",
      "isActive": true,
    },
    {
      "id": 4,
      "name": "Rock Festival 2026",
      "organizer": "Rock Promotions",
      "date": "May 20, 2026",
      "location": "GBK Stadium",
      "status": "inactive",
      "isActive": false,
    },
  ];

  List<Map<String, dynamic>> get filteredEvents {
    return events.where((e) {
      final matchSearch = e["name"]
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      final matchFilter =
          filter == "all" ? true : e["status"] == filter;

      return matchSearch && matchFilter;
    }).toList();
  }

  void toggleEvent(int index) {
    setState(() {
      events[index]["isActive"] = !events[index]["isActive"];
      events[index]["status"] =
          events[index]["isActive"] ? "active" : "inactive";
    });
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
                    "Event Management",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Review and approve events",
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

            const SizedBox(height: 15),

            /// FILTER TABS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _tab("all", "All"),
                  _tab("active", "Active"),
                  _tab("inactive", "Inactive"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LIST EVENTS
            Column(
              children: filteredEvents.map((e) {
                int index = events.indexOf(e);
                return _eventCard(e, index);
              }).toList(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// TAB
  Widget _tab(String key, String label) {
    bool isSelected = filter == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          filter = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE4572E)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// EVENT CARD
  Widget _eventCard(Map<String, dynamic> e, int index) {
    bool isActive = e["isActive"];

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

          /// HEADER INFO
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
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

          /// ORGANIZER
          Row(
            children: [
              const Icon(Icons.person, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(e["organizer"], style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(e["date"], style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(e["location"],
                  style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 12),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    isActive ? "Disable Event" : "Enable Event",
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: isActive,
                    onChanged: (val) => toggleEvent(index),
                    activeColor: Colors.green,
                  ),
                ],
              ),

              /// DELETE
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete, color: Colors.grey),
              )
            ],
          )
        ],
      ),
    );
  }
}