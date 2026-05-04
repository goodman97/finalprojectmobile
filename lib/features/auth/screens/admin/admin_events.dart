import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  String filter = "all";
  String searchQuery = "";
  List events = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  void fetchEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _getAdminEvents();
      setState(() {
        events = data;
        isLoading = false;
      });
    } catch (e) {
      print("ERROR GET EVENTS: $e");
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _getAdminEvents() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/api/events/eo/all"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    print("GET ADMIN EVENTS STATUS: ${response.statusCode}");
    print("GET ADMIN EVENTS BODY: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.startsWith("<")) {
        throw Exception("Server error (HTML response)");
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }

      throw Exception("Format data bukan list");
    }

    throw Exception("Failed to fetch admin events: ${response.body}");
  }

  String _formatDate(dynamic date) {
    if (date == null) return "-";
    try {
      final d = DateTime.parse(date.toString());
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return "${months[d.month - 1]} ${d.day}, ${d.year}";
    } catch (_) {
      return date.toString();
    }
  }

  String _getEventName(dynamic event) {
    return (event["name"] ?? event["title"] ?? "Event").toString();
  }

  String _getOrganizer(dynamic event) {
    return (event["organizer_name"] ?? event["organizer"] ?? event["organizer_id"] ?? "-").toString();
  }

  String _getLocation(dynamic event) {
    return (event["address"] ?? event["location"] ?? "-").toString();
  }

  String _getStatus(dynamic event) {
    final status = event["status"]?.toString().toLowerCase();
    if (status != null && status.isNotEmpty) return status;

    final isActive = event["is_active"] ?? event["isActive"];
    if (isActive == true) return "active";
    return "inactive";
  }

  bool _isActive(dynamic event) {
    final activeValue = event["is_active"] ?? event["isActive"];
    if (activeValue is bool) return activeValue;
    return _getStatus(event) == "active";
  }

  List get filteredEvents {
    return events.where((event) {
      final name = _getEventName(event).toLowerCase();
      final query = searchQuery.toLowerCase();
      final matchSearch = name.contains(query) || _getLocation(event).toLowerCase().contains(query);
      final status = _getStatus(event);
      final matchFilter = filter == "all" ? true : status == filter;
      return matchSearch && matchFilter;
    }).toList();
  }

  Future<void> toggleEvent(int index) async {
    final current = events[index];
    final newStatus = _isActive(current) ? "inactive" : "active";

    try {
      final updatedEvent = await _updateEventStatus(
        current["id"].toString(),
        newStatus,
      );

      setState(() {
        events[index] = updatedEvent;
      });
    } catch (e) {
      print("ERROR UPDATE EVENT STATUS: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Gagal memperbarui status event. Coba lagi.",
            ),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _updateEventStatus(
    String eventId,
    String status,
  ) async {
    final token = await StorageService.getToken();

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/api/events/eo/$eventId/edit"),
      headers: {
        if (token != null) "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"status": status}),
    );

    print("UPDATE EVENT STATUS STATUS: ${response.statusCode}");
    print("UPDATE EVENT STATUS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded["event"] != null) {
        return Map<String, dynamic>.from(decoded["event"]);
      }
      throw Exception("Response bukan format event");
    }

    throw Exception("Failed to update event status: ${response.body}");
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
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    "Failed to load events:\n${errorMessage!}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (filteredEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    "No events found.",
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
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
  Widget _eventCard(dynamic e, int index) {
    final isActive = _isActive(e);
    final name = _getEventName(e);
    final organizer = _getOrganizer(e);
    final date = _formatDate(e["start_date"] ?? e["date"]);
    final location = _getLocation(e);

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
                  name,
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
              Text(organizer, style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          /// DATE
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(date, style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 5),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(location, style: const TextStyle(fontSize: 12)),
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