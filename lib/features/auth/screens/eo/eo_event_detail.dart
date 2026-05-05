import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finalproject/services/eo_event_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/eo/eo_create_event.dart';
import 'package:finalproject/features/auth/screens/eo/eo_manage_ticket_types.dart';
import 'package:finalproject/utils/date_utils.dart';

final _rupiah = NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);

class EoEventDetail extends StatefulWidget {
  final String eventId;

  const EoEventDetail({super.key, required this.eventId});

  @override
  State<EoEventDetail> createState() => _EoEventDetailState();
}

class _EoEventDetailState extends State<EoEventDetail> {
  Map<String, dynamic>? event;
  List transactions = [];
  bool isLoading = true;
  int selectedTab = 0;
  String selectedTimezone = "WIB";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await EoEventService.getEventDetail(widget.eventId);
      setState(() {
        event        = d["event"];
        transactions = d["transactions"] ?? [];
        isLoading    = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("EO DETAIL ERR: $e");
    }
  }

  String _fmtDateShort(dynamic d) => AppDateUtils.formatDate(d);
  String _fmtDate(dynamic d) {return AppDateUtils.formatDate(d);}

  String _formatWithTimezone(dynamic date) {
    if (date == null) return "-";

    final parsed = DateTime.tryParse(date.toString());
    if (parsed == null) return "-";

    DateTime adjusted = parsed.toLocal();

    switch (selectedTimezone) {
      case "WITA":
        adjusted = parsed.add(const Duration(hours: 1));
        break;

      case "WIT":
        adjusted = parsed.add(const Duration(hours: 2));
        break;

      case "London":
        adjusted = parsed.subtract(const Duration(hours: 6));
        break;

      case "WIB":
      default:
        adjusted = parsed;
    }

    return DateFormat(
      "dd MMM yyyy • HH:mm",
    ).format(adjusted);
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF2F3E2F)),
        body: const Center(child: Text("Event tidak ditemukan")),
      );
    }

    final e        = event!;
    final sold     = int.tryParse(e["sold"]?.toString() ?? "0") ?? 0;
    final quota    = int.tryParse(e["quota"]?.toString() ?? "0") ?? 1;
    final revenue  = double.tryParse(e["revenue"]?.toString() ?? "0") ?? 0;
    final imgUrl   = _imgUrl(e["event_image"]);
    final isActive = e["status"] == "active";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero Image
                Stack(
                  children: [
                    SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: imgUrl.isEmpty
                          ? Container(
                              color: const Color(0xFF4E5F4E),
                              child: const Icon(Icons.image,
                                  size: 60, color: Colors.white54),
                            )
                          : Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFF4E5F4E),
                                child: const Icon(Icons.image,
                                    size: 60, color: Colors.white54),
                              ),
                            ),
                    ),
                    Container(
                      height: 300,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xFFF5F1E8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Back button
                    Positioned(
                      top: 44,
                      left: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Color(0xFF2F3E2F)),
                        ),
                      ),
                    ),
                    // Status badge
                    Positioned(
                      top: 44,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isActive ? "Active" : "Inactive",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main info card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e["name"] ?? "-",
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e["organizer_name"] ?? "-",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F1E8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedTimezone,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: "WIB",
                                      child: Text("WIB (UTC+7)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "WITA",
                                      child: Text("WITA (UTC+8)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "WIT",
                                      child: Text("WIT (UTC+9)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "London",
                                      child: Text("London (UTC+1)"),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val == null) return;
                                    setState(() {
                                      selectedTimezone = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                                Icons.event_available,
                                "Start",
                                _formatWithTimezone(e["start_date"]),
                              ),
                            const SizedBox(height: 8),
                            _infoRow(
                                Icons.event_busy,
                                "End",
                                _formatWithTimezone(e["end_date"]),
                              ),
                            const SizedBox(height: 8),
                            _infoRow(Icons.location_on, "Location",
                                e["address"] ?? "-"),
                            const SizedBox(height: 8),
                            _infoRow(Icons.payments_outlined, "Price",
                                _rupiah.format(
                                    double.tryParse(e["price"]?.toString() ?? "0") ?? 0)),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),
                            const Text("About the Event",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF2F3E2F))),
                            const SizedBox(height: 8),
                            Text(
                              e["description"] ?? "No descriptions yet.",
                              style: const TextStyle(
                                  color: Colors.black54, height: 1.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats cards
                      Row(
                        children: [
                          _statsCard("Sold", "$sold / $quota",
                              Icons.confirmation_num_outlined,
                              const Color(0xFFE4572E)),
                          const SizedBox(width: 10),
                          _statsCard("Revenue", _rupiah.format(revenue),
                              Icons.payments_outlined, const Color(0xFF2F3E2F),
                              smallText: true),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Sales Statistic
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sales Statistics",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3E2F),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: _miniStat(
                                    "Today",
                                    "${transactions.length}",
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: _miniStat(
                                    "This Week",
                                    "${transactions.length}",
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: _miniStat(
                                    "This Month",
                                    "$sold",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _tabButton(
                                "Overview",
                                0,
                              ),
                            ),
                            Expanded(
                              child: _tabButton(
                                "Buyers (${transactions.length})",
                                1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      selectedTab == 0
                        ? _overviewSection()
                        : _buyersSection(),
                      const SizedBox(height: 10),

                    ],
                  ),
                ),
              ],
            ),
          ),

          // Edit button sticky bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EoCreateEvent(
                          editEvent: Map<String, dynamic>.from(event!)),
                    ),
                  );
                  if (updated == true) _load();
                },
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                label: const Text("Edit Event",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F3E2F),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2F3E2F)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2F3E2F))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsCard(
      String label, String value, IconData icon, Color color,
      {bool smallText = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: smallText ? 13 : 20,
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

  Widget _miniStat(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F3E2F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManageTicketTypesPage(
                      eventId: widget.eventId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4572E),
              ),
              child: const Text(
                "Manage Ticket Types",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await EoEventService.downloadCSVReport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F3E2F),
              ),
              child: const Text(
                "Download Report",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buyersSection() {
    if (transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("No buyers yet"),
        ),
      );
    }

    return Column(
      children: transactions.map((tx) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx["buyer_name"] ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tx["buyer_email"] ?? "-",
                    ),
                  ],
                ),
              ),
              Text(
                _rupiah.format(
                  double.tryParse(
                        tx["amount"]?.toString() ?? "0",
                      ) ??
                      0,
                ),
                style: const TextStyle(
                  color: Color(0xFFE4572E),
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _tabButton(
    String title,
    int index,
  ) {
    final active = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFE4572E)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : const Color(0xFF2F3E2F),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}