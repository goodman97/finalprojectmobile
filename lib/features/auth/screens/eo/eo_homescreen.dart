import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finalproject/features/auth/screens/eo/eo_my_events.dart';
import 'package:finalproject/features/auth/screens/eo/eo_event_detail.dart';
import 'package:finalproject/services/eo_event_service.dart';

final _rupiah = NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);

class EoHomescreen extends StatefulWidget {
  const EoHomescreen({super.key});

  @override
  State<EoHomescreen> createState() => _EoHomescreenState();
}

class _EoHomescreenState extends State<EoHomescreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await EoEventService.getDashboard();
      setState(() { data = d; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("DASHBOARD ERR: $e");
    }
  }

  String _fmtDate(dynamic d) {
    if (d == null) return "-";
    try {
      final dt = DateTime.parse(d.toString());
      return DateFormat("MMM d, yyyy").format(dt);
    } catch (_) { return "-"; }
  }

  String _timeAgo(dynamic d) {
    if (d == null) return "";
    try {
      final dt   = DateTime.parse(d.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
      if (diff.inHours   < 24) return "${diff.inHours} hr ago";
      return "${diff.inDays} days ago";
    } catch (_) { return ""; }
  }

  @override
  Widget build(BuildContext context) {
    final stats    = data?["stats"]          ?? {};
    final upcoming = data?["upcomingEvents"] as List? ?? [];
    final sales    = data?["recentSales"]    as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F3E2F))),
                              Text("Manage your events easily",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 22,
                            child: IconButton(
                              icon: const Icon(Icons.person_outline,
                                  color: Color(0xFF2F3E2F)),
                              onPressed: () {},
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          _statCard(
                            icon: Icons.calendar_today,
                            iconColor: const Color(0xFF2F3E2F),
                            value: stats["total_events"]?.toString() ?? "0",
                            label: "Total Events",
                          ),
                          const SizedBox(width: 10),
                          _statCard(
                            icon: Icons.confirmation_num_outlined,
                            iconColor: const Color(0xFFE4572E),
                            value: stats["total_sold"]?.toString() ?? "0",
                            label: "Tickets Sold",
                          ),
                          const SizedBox(width: 10),
                          _statCard(
                            icon: Icons.attach_money,
                            iconColor: const Color(0xFFE4572E),
                            value: _rupiah.format(
                                double.tryParse(
                                    stats["total_revenue"]?.toString() ?? "0") ?? 0),
                            label: "Revenue",
                            smallValue: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Upcoming Events",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F))),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EoMyEvents()),
                            ),
                            child: const Text("View All",
                                style: TextStyle(
                                    color: Color(0xFFE4572E),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (upcoming.isEmpty)
                        _emptyCard("Belum ada event upcoming")
                      else
                        ...upcoming.map((e) => _upcomingCard(e)).toList(),

                      const SizedBox(height: 24),

                      const Text("Recent Sales",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3E2F))),

                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: sales.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                    child: Text("Belum ada penjualan",
                                        style: TextStyle(color: Colors.grey))))
                            : Column(
                                children: sales.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final s = entry.value;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    s["event_name"] ?? "-",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Color(0xFF2F3E2F)),
                                                  ),
                                                  Text(
                                                    "${s["ticket_count"]} tickets • ${_timeAgo(s["last_sold"])}",
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              _rupiah.format(
                                                  double.tryParse(
                                                          s["amount"]?.toString() ??
                                                              "0") ??
                                                      0),
                                              style: const TextStyle(
                                                  color: Color(0xFFE4572E),
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      ),
                                      if (i < sales.length - 1)
                                        const Divider(height: 1, indent: 16),
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    bool smallValue = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: smallValue ? 12 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F3E2F)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _upcomingCard(Map<String, dynamic> e) {
    final sold       = int.tryParse(e["sold"]?.toString() ?? "0") ?? 0;
    final quota      = int.tryParse(e["quota"]?.toString() ?? "0") ?? 1;
    final fillPct    = int.tryParse(e["fill_percent"]?.toString() ?? "0") ?? 0;
    final revenue    = double.tryParse(e["revenue"]?.toString() ?? "0") ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EoEventDetail(eventId: e["id"].toString()),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    e["name"] ?? "-",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2F3E2F)),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 4),
            Text(_fmtDate(e["start_date"]),
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniStat("Sold", "$sold/$quota"),
                const SizedBox(width: 24),
                _miniStat("Revenue", _rupiah.format(revenue)),
                const Spacer(),
                // Fill percentage circle
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: fillPct / 100,
                        strokeWidth: 4,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          fillPct >= 80
                              ? const Color(0xFFE4572E)
                              : const Color(0xFF2F3E2F),
                        ),
                      ),
                      Center(
                        child: Text(
                          "$fillPct%",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: fillPct >= 80
                                  ? const Color(0xFFE4572E)
                                  : const Color(0xFF2F3E2F)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF2F3E2F))),
      ],
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
          child: Text(msg, style: const TextStyle(color: Colors.grey))),
    );
  }
}
