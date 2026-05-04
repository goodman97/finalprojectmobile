import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finalproject/services/eo_event_service.dart';
import 'package:finalproject/features/auth/screens/eo/eo_event_detail.dart';
import 'package:finalproject/features/auth/screens/eo/eo_create_event.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/eo/eo_profile.dart';

final _rupiah = NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);

class EoMyEvents extends StatefulWidget {
  const EoMyEvents({super.key});

  @override
  State<EoMyEvents> createState() => _EoMyEventsState();
}

class _EoMyEventsState extends State<EoMyEvents> {
  List events = [];
  bool isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load([String q = ""]) async {
    setState(() => isLoading = true);
    try {
      final data = await EoEventService.getMyEvents(q: q);
      setState(() { events = data; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _fmtDate(dynamic d) {
    if (d == null) return "-";
    try { return DateFormat("MMM d, yyyy").format(DateTime.parse(d.toString())); }
    catch (_) { return "-"; }
  }

  String _imgUrl(dynamic img) {
    if (img == null || img.toString().isEmpty) {
      return "";
    }

    final image = img.toString();
    final base = ApiConfig.baseUrl;

    if (image.startsWith("http")) {
      return image;
    }

    if (image.startsWith("/uploads/")) {
      return "$base$image";
    }

    if (image.startsWith("uploads/")) {
      return "$base/$image";
    }

    return "$base/uploads/events/$image";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3E2F),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("My Events",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text("Manage your events easily",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          icon: const Icon(Icons.person_outline,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EOProfile(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _load(v),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Search events...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_busy,
                                  size: 56, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text("Belum ada event",
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 16),
                              _createButton(context),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: events.length,
                          itemBuilder: (_, i) => _eventCard(events[i]),
                        ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const EoCreateEvent()),
          );
          if (created == true) _load(_searchCtrl.text);
        },
        backgroundColor: const Color(0xFFE4572E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Event",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _createButton(BuildContext ctx) {
    return ElevatedButton.icon(
      onPressed: () async {
        final created = await Navigator.push<bool>(
          ctx,
          MaterialPageRoute(builder: (_) => const EoCreateEvent()),
        );
        if (created == true) _load();
      },
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text("Create Event",
          style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE4572E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _eventCard(Map<String, dynamic> e) {
    final sold = int.tryParse(e["sold"]?.toString() ?? "0") ?? 0;
    final revenue = double.tryParse(e["revenue"]?.toString() ?? "0") ?? 0;
    final isActive = e["status"] == "active";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: _imgUrl(e["event_image"]).isEmpty
                      ? Container(
                          color: const Color(0xFF4E5F4E),
                          child: const Icon(Icons.image,
                              color: Colors.white54, size: 48),
                        )
                      : Image.network(
                          _imgUrl(e["event_image"]),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF4E5F4E),
                            child: const Icon(Icons.image,
                                color: Colors.white54, size: 48),
                          ),
                        ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isActive ? "Active" : "Inactive",
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e["name"] ?? "-",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F3E2F))),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(_fmtDate(e["start_date"]),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      e["address"] ?? "-",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.confirmation_num_outlined,
                                  size: 12, color: Color(0xFFE4572E)),
                              const SizedBox(width: 4),
                              const Text("Tickets Sold",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ]),
                            Text(
                              "$sold",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF2F3E2F)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F1E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.payments_outlined,
                                  size: 12, color: Color(0xFFE4572E)),
                              const SizedBox(width: 4),
                              const Text("Revenue",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11)),
                            ]),
                            Text(
                              _rupiah.format(revenue),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF2F3E2F)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EoCreateEvent(
                                editEvent: Map<String, dynamic>.from(e),
                              ),
                            ),
                          );
                          if (updated == true) _load(_searchCtrl.text);
                        },
                        icon: const Icon(Icons.edit_outlined,
                            color: Color(0xFF2F3E2F), size: 16),
                        label: const Text("Edit",
                            style: TextStyle(color: Color(0xFF2F3E2F))),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: Color(0xFF2F3E2F)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EoEventDetail(eventId: e["id"].toString()),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4572E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("View Details",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
