import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> listings    = [];
  List<Map<String, dynamic>> myListings  = [];
  List<Map<String, dynamic>> filtered    = [];

  bool isLoading       = true;
  bool isLoadingMine   = false;
  String searchQuery   = "";
  String sortBy        = "newest";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && myListings.isEmpty) {
        loadMyListings();
      }
    });
    loadListings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> get _headers async {
    final token = await StorageService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<void> loadListings() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/market"),
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        final list = data.map((e) => Map<String, dynamic>.from(e)).toList();
        setState(() {
          listings = list;
          filtered = list;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadMyListings() async {
    setState(() => isLoadingMine = true);
    try {
      final headers = await _headers;
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/market/my-listings"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          myListings = data.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoadingMine = false;
        });
      } else {
        setState(() => isLoadingMine = false);
      }
    } catch (e) {
      setState(() => isLoadingMine = false);
    }
  }

  void applySearch(String q) {
    setState(() {
      searchQuery = q;
      filtered = listings.where((e) {
        final name  = (e["event_name"] ?? "").toString().toLowerCase();
        final addr  = (e["address"]    ?? "").toString().toLowerCase();
        return name.contains(q.toLowerCase()) || addr.contains(q.toLowerCase());
      }).toList();
      _applySort();
    });
  }

  void _applySort() {
    switch (sortBy) {
      case "price_asc":
        filtered.sort((a, b) => (double.tryParse(a["resale_price"].toString()) ?? 0)
            .compareTo(double.tryParse(b["resale_price"].toString()) ?? 0));
        break;
      case "price_desc":
        filtered.sort((a, b) => (double.tryParse(b["resale_price"].toString()) ?? 0)
            .compareTo(double.tryParse(a["resale_price"].toString()) ?? 0));
        break;
      case "date_asc":
        filtered.sort((a, b) => (a["start_date"] ?? "").compareTo(b["start_date"] ?? ""));
        break;
      default: // newest
        filtered.sort((a, b) => (b["created_at"] ?? "").compareTo(a["created_at"] ?? ""));
    }
  }

  Future<void> buyTicket(Map<String, dynamic> listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Pembelian"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(listing["event_name"] ?? "-",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Tipe: ${listing['ticket_type'] ?? '-'}"),
            Text("Penjual: ${listing['seller_name'] ?? '-'}"),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Harga Resale:"),
              Text(
                "Rp ${_formatNum(listing['resale_price'])}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE4572E),
                    fontSize: 16),
              ),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Harga asli:", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Text(
                "Rp ${_formatNum(listing['original_price'])}",
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE4572E)),
            child: const Text("Beli Sekarang", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final headers = await _headers;
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/market/${listing['listing_id']}/buy"),
        headers: headers,
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() => listings.remove(listing));
        applySearch(searchQuery);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("🎉 Tiket berhasil dibeli!"),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body["message"] ?? "Gagal membeli tiket"),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> cancelListing(Map<String, dynamic> listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Batalkan Listing"),
        content: Text("Batalkan penjualan tiket \"${listing['event_name']}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final headers = await _headers;
      final res = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/api/market/${listing['listing_id']}/cancel"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        setState(() => myListings.remove(listing));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Listing berhasil dibatalkan"),
                backgroundColor: Colors.orange),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void showSellDialog() {
    // Navigate ke screen jual tiket
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SellTicketScreen()),
    ).then((_) {
      loadListings();
      loadMyListings();
    });
  }

  void showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text("Urutkan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _sortTile("Terbaru", Icons.access_time, "newest"),
          _sortTile("Harga Terendah", Icons.arrow_downward, "price_asc"),
          _sortTile("Harga Tertinggi", Icons.arrow_upward, "price_desc"),
          _sortTile("Tanggal Terdekat", Icons.calendar_today, "date_asc"),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _sortTile(String label, IconData icon, String key) {
    final isSelected = sortBy == key;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFFE4572E) : Colors.grey),
      title: Text(label,
          style: TextStyle(
              color: isSelected ? const Color(0xFFE4572E) : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFE4572E)) : null,
      onTap: () {
        Navigator.pop(context);
        setState(() => sortBy = key);
        _applySort();
      },
    );
  }

  String _formatNum(dynamic val) {
    if (val == null) return "0";
    final n = double.tryParse(val.toString()) ?? 0;
    return n.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "-";
    final d = DateTime.tryParse(date.toString());
    if (d == null) return "-";
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  String _buildImageUrl(dynamic image) {
    if (image == null || image.toString().isEmpty) return "";
    final img = image.toString();
    final base = ApiConfig.baseUrl;
    if (img.startsWith("http")) return img;
    if (img.startsWith("/uploads/")) return "$base$img";
    if (img.startsWith("uploads/")) return "$base/$img";
    return "$base/uploads/events/$img";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(children: [
          // ── Header ──────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              gradient: LinearGradient(
                colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
              ),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Marketplace",
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("Resale tiket terverifikasi",
                      style: TextStyle(color: Colors.white70)),
                ]),
                Row(children: [
                  // Sort button
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.sort, color: Colors.white),
                      onPressed: showSortSheet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Sell button
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE4572E),
                    child: IconButton(
                      icon: const Icon(Icons.sell_outlined, color: Colors.white),
                      onPressed: showSellDialog,
                      tooltip: "Jual Tiket",
                    ),
                  ),
                ]),
              ]),

              const SizedBox(height: 14),

              // Search
              TextField(
                onChanged: applySearch,
                decoration: InputDecoration(
                  hintText: "Cari event atau lokasi...",
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),

              const SizedBox(height: 12),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: const Color(0xFFE4572E),
                indicatorWeight: 3,
                tabs: [
                  Tab(text: "Semua (${filtered.length})"),
                  Tab(text: "Listing Saya"),
                ],
              ),
            ]),
          ),

          // ── Content ──────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Semua listing resale
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? _emptyState("Belum ada tiket resale", Icons.store_mall_directory_outlined)
                        : RefreshIndicator(
                            onRefresh: loadListings,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: filtered.length,
                              itemBuilder: (_, i) => _listingCard(filtered[i]),
                            ),
                          ),

                // Tab 2: Listing milik user
                isLoadingMine
                    ? const Center(child: CircularProgressIndicator())
                    : myListings.isEmpty
                        ? _emptyState("Kamu belum menjual tiket apapun", Icons.sell_outlined)
                        : RefreshIndicator(
                            onRefresh: loadMyListings,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: myListings.length,
                              itemBuilder: (_, i) => _myListingCard(myListings[i]),
                            ),
                          ),
              ],
            ),
          ),
        ]),
      ),

      // Buyer protection bar
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        color: Colors.white,
        child: Row(children: const [
          Icon(Icons.verified_user_outlined, color: Color(0xFFE4572E), size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(
            "Semua tiket terverifikasi & aman",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          )),
        ]),
      ),
    );
  }

  Widget _listingCard(Map<String, dynamic> listing) {
    final imageUrl      = _buildImageUrl(listing["image"]);
    final resalePrice   = double.tryParse(listing["resale_price"].toString()) ?? 0;
    final originalPrice = double.tryParse(listing["original_price"].toString()) ?? 0;
    final markup        = resalePrice - originalPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Stack(children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: imageUrl.isEmpty
              ? Container(height: 220, color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey))
              : Image.network(imageUrl, height: 220, width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220, color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  )),
        ),

        // Gradient overlay
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Colors.transparent, Colors.black87],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Markup badge
        Positioned(
          right: 12, top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE4572E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("+Rp ${_formatNum(markup)}",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),

        // Info
        Positioned(
          bottom: 12, left: 12, right: 12,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Verified + ticket type
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Text("Verified", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(listing["ticket_type"] ?? "General",
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
              ),
            ]),

            const SizedBox(height: 6),
            Text(listing["event_name"] ?? "-",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Row(children: [
              const Icon(Icons.location_on_outlined, size: 12, color: Colors.white70),
              const SizedBox(width: 2),
              Expanded(child: Text(listing["address"] ?? "-",
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
            ]),
            Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white70),
              const SizedBox(width: 2),
              Text(_formatDate(listing["start_date"]),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 8),
              const Icon(Icons.person_outline, size: 12, color: Colors.white70),
              const SizedBox(width: 2),
              Text(listing["seller_name"] ?? "-",
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ]),

            const SizedBox(height: 8),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Rp ${_formatNum(resalePrice)}",
                    style: const TextStyle(
                        color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Harga asli: Rp ${_formatNum(originalPrice)}",
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Colors.white54)),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4572E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () => buyTicket(listing),
                child: const Text("Beli", style: TextStyle(color: Colors.white)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _myListingCard(Map<String, dynamic> listing) {
    final isAvailable   = listing["listing_status"] == "available";
    final resalePrice   = double.tryParse(listing["resale_price"].toString()) ?? 0;
    final originalPrice = double.tryParse(listing["original_price"].toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        border: isAvailable
            ? Border.all(color: const Color(0xFFE4572E).withValues(alpha: 0.3))
            : null,
      ),
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImageUrl(listing["image"]).isNotEmpty
              ? Image.network(_buildImageUrl(listing["image"]),
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(width: 70, height: 70, color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey)))
              : Container(width: 70, height: 70, color: Colors.grey.shade200,
                  child: const Icon(Icons.event, color: Colors.grey)),
        ),

        const SizedBox(width: 12),

        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(listing["event_name"] ?? "-",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isAvailable
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isAvailable ? "Dijual" : listing["listing_status"] ?? "-",
                style: TextStyle(
                    fontSize: 10,
                    color: isAvailable ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ]),

          const SizedBox(height: 4),
          Text(listing["ticket_type"] ?? "-",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          Text(_formatDate(listing["start_date"]),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),

          const SizedBox(height: 6),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Rp ${_formatNum(resalePrice)}",
                  style: const TextStyle(
                      color: Color(0xFFE4572E),
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Beli: Rp ${_formatNum(originalPrice)}",
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade400,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.grey.shade400)),
            ]),

            if (isAvailable)
              GestureDetector(
                onTap: () => cancelListing(listing),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("Batalkan",
                      style: TextStyle(color: Colors.red, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ),
          ]),
        ])),
      ]),
    );
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 64, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text(msg, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
      const SizedBox(height: 8),
      TextButton.icon(
        onPressed: () { loadListings(); loadMyListings(); },
        icon: const Icon(Icons.refresh),
        label: const Text("Refresh"),
      ),
    ]));
  }
}

// ── Screen Jual Tiket ─────────────────────────────────────────────────────────
class SellTicketScreen extends StatefulWidget {
  const SellTicketScreen({super.key});

  @override
  State<SellTicketScreen> createState() => _SellTicketScreenState();
}

class _SellTicketScreenState extends State<SellTicketScreen> {
  List<Map<String, dynamic>> myTickets = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedTicket;
  final TextEditingController priceCtrl = TextEditingController();
  bool isSubmitting = false;
  String? priceError;

  @override
  void initState() {
    super.initState();
    loadMyTickets();
    priceCtrl.addListener(_validatePrice);
  }

  @override
  void dispose() {
    priceCtrl.dispose();
    super.dispose();
  }

  void _validatePrice() {
    if (selectedTicket == null) return;
    final entered      = double.tryParse(priceCtrl.text) ?? 0;
    final originalPrice = double.tryParse(
            selectedTicket!["original_price"]?.toString() ?? "0") ??
        0;
    setState(() {
      priceError = entered > 0 && entered <= originalPrice
          ? "Harga harus lebih dari Rp ${_fmt(originalPrice)} (harga beli)"
          : null;
    });
  }

  String _fmt(double n) => n.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Future<void> loadMyTickets() async {
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/tickets/mytickets"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // Ambil hanya tiket yang berstatus 'active' dari upcoming
        final upcoming = (data["upcoming"] as List? ?? [])
            .where((t) => t["status"] == "active")
            .map((t) => Map<String, dynamic>.from(t))
            .toList();
        setState(() { myTickets = upcoming; isLoading = false; });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitListing() async {
    if (selectedTicket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih tiket yang ingin dijual")));
      return;
    }
    final price = double.tryParse(priceCtrl.text) ?? 0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Masukkan harga jual")));
      return;
    }
    if (priceError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(priceError!)));
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final token = await StorageService.getToken();
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/market/list"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "ticket_id": selectedTicket!["ticket_id"],
          "price": price,
        }),
      );

      final body = jsonDecode(res.body);
      setState(() => isSubmitting = false);

      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Tiket berhasil didaftarkan!"),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body["message"] ?? "Gagal"),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = selectedTicket != null
        ? double.tryParse(selectedTicket!["original_price"]?.toString() ?? "0") ?? 0
        : 0.0;
    final enteredPrice  = double.tryParse(priceCtrl.text) ?? 0;
    final profit        = enteredPrice - originalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Jual Tiket"),
        backgroundColor: const Color(0xFF2F3E2F),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Info box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4572E).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4572E).withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: Color(0xFFE4572E), size: 20),
                    const SizedBox(width: 10),
                    const Expanded(child: Text(
                      "Harga jual harus lebih tinggi dari harga beli tiket.",
                      style: TextStyle(fontSize: 13, color: Color(0xFFE4572E)),
                    )),
                  ]),
                ),

                const SizedBox(height: 20),

                // Pilih tiket
                const Text("Pilih Tiket", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),

                myTickets.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text("Tidak ada tiket aktif yang bisa dijual",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : Column(
                        children: myTickets.map((ticket) {
                          final isSelected = selectedTicket?["ticket_id"] == ticket["ticket_id"];
                          final origPrice = double.tryParse(
                                  ticket["original_price"]?.toString() ?? "0") ??
                              0;
                          return GestureDetector(
                            onTap: () {
                              setState(() { selectedTicket = ticket; priceError = null; });
                              priceCtrl.clear();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFE4572E) : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: Row(children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFE4572E).withValues(alpha: 0.1)
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.confirmation_number_outlined,
                                      color: isSelected ? const Color(0xFFE4572E) : Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(ticket["event_name"] ?? "-",
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(ticket["ticket_type"] ?? "General",
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                  Text("Harga beli: Rp ${_fmt(origPrice)}",
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFE4572E))),
                                ])),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Color(0xFFE4572E)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),

                if (selectedTicket != null) ...[
                  const SizedBox(height: 20),
                  const Text("Harga Jual (Rp)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),

                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Masukkan harga jual...",
                      prefixText: "Rp ",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: priceError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: priceError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      errorText: priceError,
                    ),
                  ),

                  // Kalkulasi profit
                  if (enteredPrice > originalPrice) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Estimasi profit kamu:",
                            style: TextStyle(fontSize: 13, color: Colors.green)),
                        Text("+ Rp ${_fmt(profit)}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ],
                ],

                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submitListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4572E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Daftarkan untuk Dijual",
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ]),
            ),
    );
  }
}