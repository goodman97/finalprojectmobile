import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/utils/date_utils.dart';

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _AdminHomescreenState();
}

class _AdminHomescreenState extends State<AdminHomescreen> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> stats = {};
  List recentTransactions = [];
  List recentActivity = [];

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final token = await StorageService.getToken();
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/dashboard"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          stats             = data["stats"] ?? {};
          recentTransactions = data["recentTransactions"] ?? [];
          recentActivity    = data["recentActivity"] ?? [];
          isLoading         = false;
        });
      } else {
        final body = jsonDecode(res.body);
        setState(() { errorMessage = body["message"] ?? "Gagal"; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); isLoading = false; });
    }
  }

  String _formatCurrency(dynamic val) {
    if (val == null) return "Rp 0";
    final num = double.tryParse(val.toString()) ?? 0;
    if (num >= 1000000) return "Rp ${(num / 1000000).toStringAsFixed(1)}M";
    if (num >= 1000) return "Rp ${(num / 1000).toStringAsFixed(0)}K";
    return "Rp ${num.toStringAsFixed(0)}";
  }

  String _formatNumber(dynamic val) {
    if (val == null) return "0";
    final n = int.tryParse(val.toString()) ?? 0;
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }

  String _timeAgo(dynamic dateStr) => AppDateUtils.timeAgo(dateStr);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: fetchDashboard, child: const Text("Coba Lagi")),
                ]))
              : RefreshIndicator(
                  onRefresh: fetchDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [

                      // ── Header ───────────────────────────
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
                          children: [
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text("Admin Dashboard", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text("System overview and monitoring", style: TextStyle(color: Colors.white70)),
                            ]),
                            IconButton(
                              onPressed: fetchDashboard,
                              icon: const Icon(Icons.refresh, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Stats Grid ───────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: _statCard(
                              icon: Icons.people_outline,
                              label: "Total Users",
                              value: _formatNumber(stats["total_users"]),
                              color: const Color(0xFF2F3E2F),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _statCard(
                              icon: Icons.event_outlined,
                              label: "Total Events",
                              value: _formatNumber(stats["total_events"]),
                              color: const Color(0xFF2F3E2F),
                            )),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(child: _statCard(
                              icon: Icons.confirmation_number_outlined,
                              label: "Tickets Sold",
                              value: _formatNumber(stats["tickets_sold"]),
                              color: const Color(0xFFE4572E),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _statCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: "Revenue",
                              value: _formatCurrency(stats["total_revenue"]),
                              color: const Color(0xFFE4572E),
                            )),
                          ]),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // ── Recent Activity ──────────────────
                      _sectionCard(
                        title: "Recent Activity",
                        icon: Icons.bolt_outlined,
                        iconColor: const Color(0xFFE4572E),
                        child: recentActivity.isEmpty
                            ? const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Belum ada aktivitas", style: TextStyle(color: Colors.grey)),
                              ))
                            : Column(
                                children: recentActivity.take(5).map<Widget>((item) {
                                  return _activityRow(
                                    name: item["user_name"] ?? "-",
                                    action: "${item['action'] ?? '-'} • ${item['event_name'] ?? '-'}",
                                    time: _timeAgo(item["time"]),
                                  );
                                }).toList(),
                              ),
                      ),

                      const SizedBox(height: 15),

                      // ── Recent Transactions ──────────────
                      _sectionCard(
                        title: "Recent Transactions",
                        icon: Icons.trending_up,
                        iconColor: Colors.green,
                        child: recentTransactions.isEmpty
                            ? const Center(child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text("Belum ada transaksi", style: TextStyle(color: Colors.grey)),
                              ))
                            : Column(
                                children: recentTransactions.take(5).map<Widget>((txn) {
                                  final success = txn["status"] == "success";
                                  return _transactionRow(
                                    name: txn["user_name"] ?? "-",
                                    id: (txn["id"] ?? "").toString().substring(0, 8).toUpperCase(),
                                    amount: _formatCurrency(txn["amount"]),
                                    success: success,
                                    event: txn["event_name"] ?? "-",
                                  );
                                }).toList(),
                              ),
                      ),

                      const SizedBox(height: 15),

                      // ── System Status ────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("System Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Icon(Icons.trending_up, color: Colors.green.shade600, size: 20),
                            ]),
                            const SizedBox(height: 14),
                            Row(children: [
                              _statusBox("99.8%", "Uptime", Colors.green),
                              const SizedBox(width: 10),
                              _statusBox("Online", "Server", Colors.blue),
                              const SizedBox(width: 10),
                              _statusBox("OK", "Database", Colors.purple),
                            ]),
                          ]),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Live", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3E2F))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Icon(icon, color: iconColor, size: 20),
          ]),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }

  Widget _activityRow({required String name, required String action, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF2F3E2F).withValues(alpha: 0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: const TextStyle(color: Color(0xFF2F3E2F), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(action, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ])),
        Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  Widget _transactionRow({
    required String name,
    required String id,
    required String amount,
    required bool success,
    required String event,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text("$id • $event", style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: success ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              success ? "success" : "pending",
              style: TextStyle(fontSize: 10, color: success ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _statusBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 11)),
        ]),
      ),
    );
  }
}