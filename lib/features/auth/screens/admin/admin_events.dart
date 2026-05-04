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
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<Map<String, String>> get _headers async {
    final token = await StorageService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<void> fetchEvents() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/events/admin/all"),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          events = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        final body = jsonDecode(response.body);
        setState(() { errorMessage = body["message"] ?? "Gagal memuat events"; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); isLoading = false; });
    }
  }

  Future<void> toggleStatus(Map<String, dynamic> event) async {
    final newStatus = event["status"] == "active" ? "inactive" : "active";
    try {
      final headers = await _headers;
      final res = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/api/events/admin/${event['id']}/status"),
        headers: headers,
        body: jsonEncode({"status": newStatus}),
      );
      if (res.statusCode == 200) {
        setState(() => event["status"] = newStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("\"${event['name']}\" ${newStatus == 'active' ? 'diaktifkan' : 'dinonaktifkan'}"),
            backgroundColor: newStatus == "active" ? Colors.green : Colors.orange,
          ));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  Future<void> deleteEvent(Map<String, dynamic> event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Event"),
        content: Text("Yakin hapus \"${event['name']}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final headers = await _headers;
      final res = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/api/events/admin/${event['id']}"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        setState(() => events.remove(event));
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event dihapus"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  List<Map<String, dynamic>> get filteredEvents => events.where((e) {
    final name = (e["name"] ?? "").toString().toLowerCase();
    final addr = (e["address"] ?? "").toString().toLowerCase();
    final q = searchQuery.toLowerCase();
    final matchSearch = name.contains(q) || addr.contains(q);
    final matchFilter = filter == "all" ? true : e["status"] == filter;
    return matchSearch && matchFilter;
  }).toList();

  String _formatDate(dynamic date) {
    if (date == null) return "-";
    try {
      final d = DateTime.parse(date.toString());
      const m = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      return "${m[d.month - 1]} ${d.day}, ${d.year}";
    } catch (_) { return date.toString(); }
  }

  int get _activeCount => events.where((e) => e["status"] == "active").length;
  int get _inactiveCount => events.where((e) => e["status"] == "inactive").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Event Management", style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("Review and approve events", style: TextStyle(color: Colors.white70)),
                    ]),
                    IconButton(onPressed: fetchEvents, icon: const Icon(Icons.refresh, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  onChanged: (v) => setState(() => searchQuery = v),
                  decoration: InputDecoration(
                    hintText: "Search events...",
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(Icons.clear, color: Colors.white70), onPressed: () => setState(() => searchQuery = ""))
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Filter tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _tab("all", "All", events.length),
                _tab("active", "Active", _activeCount),
                _tab("inactive", "Inactive", _inactiveCount),
              ]),
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: fetchEvents, child: const Text("Coba Lagi")),
                      ]))
                    : filteredEvents.isEmpty
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text("Tidak ada event", style: TextStyle(color: Colors.grey.shade500)),
                          ]))
                        : RefreshIndicator(
                            onRefresh: fetchEvents,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: filteredEvents.length,
                              itemBuilder: (_, i) => _eventCard(filteredEvents[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String key, String label, int count) {
    final isSelected = filter == key;
    return GestureDetector(
      onTap: () => setState(() => filter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE4572E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(children: [
          Text(label, style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          )),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("$count", style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            )),
          ),
        ]),
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> e) {
    final isActive = e["status"] == "active";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Name + badge
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(e["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF2F3E2F)))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(isActive ? "Active" : "Inactive",
              style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),

        const SizedBox(height: 10),
        _infoRow(Icons.person_outline, e["organizer_name"] ?? "-"),
        const SizedBox(height: 4),
        _infoRow(Icons.calendar_today_outlined, _formatDate(e["start_date"])),
        const SizedBox(height: 4),
        _infoRow(Icons.location_on_outlined, e["address"] ?? "-", overflow: true),
        const SizedBox(height: 4),
        _infoRow(Icons.confirmation_number_outlined, "${e['sold'] ?? 0} tiket terjual"),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const SizedBox(height: 10),

        // Actions
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Text(
              isActive ? "Nonaktifkan" : "Aktifkan",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.orange : Colors.green),
            ),
            const SizedBox(width: 10),
            // Custom animated toggle (sesuai React version)
            GestureDetector(
              onTap: () => toggleStatus(e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44, height: 24,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 18, height: 18,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ]),
          // Delete
          GestureDetector(
            onTap: () => deleteEvent(e),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool overflow = false}) {
    return Row(children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 5),
      overflow
          ? Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.ellipsis))
          : Text(text, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }
}