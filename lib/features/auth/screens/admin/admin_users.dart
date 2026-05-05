import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String searchQuery = "";
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<Map<String, String>> get _headers async {
    final token = await StorageService.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<void> fetchUsers() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final headers = await _headers;
      final q = searchQuery.isNotEmpty ? "?q=$searchQuery" : "";
      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/users$q"),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          users = data.map((u) => Map<String, dynamic>.from(u)).toList();
          isLoading = false;
        });
      } else {
        final body = jsonDecode(res.body);
        setState(() { errorMessage = body["message"] ?? "Gagal"; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMessage = e.toString(); isLoading = false; });
    }
  }

  Future<void> toggleSuspend(Map<String, dynamic> user) async {
    final isSuspended = user["is_suspended"] == true;
    final action = isSuspended ? "aktifkan" : "suspend";
    final name = user["name"] ?? "user ini";

    // Konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isSuspended ? "Aktifkan Akun" : "Suspend Akun"),
        content: Text(
          isSuspended
              ? "Aktifkan kembali akun \"$name\"? User akan bisa login lagi."
              : "Suspend akun \"$name\"? User tidak akan bisa login.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuspended ? Colors.green : Colors.red,
            ),
            child: Text(
              isSuspended ? "Aktifkan" : "Suspend",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final headers = await _headers;
      final res = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/users/${user['id']}/suspend"),
        headers: headers,
        body: jsonEncode({"suspend": !isSuspended}),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() => user["is_suspended"] = !isSuspended);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body["message"] ?? "Berhasil"),
            backgroundColor: isSuspended ? Colors.green : Colors.orange,
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(body["message"] ?? "Gagal $action akun"),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  void _showUserOptions(Map<String, dynamic> user) {
    final isSuspended = user["is_suspended"] == true;
    final role = user["role"]?.toString() ?? "user";
    final isAdmin = role == "admin";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // User info
            Row(children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _roleColor(role).withValues(alpha: 0.12),
                child: Text(
                  (user["name"] ?? "?").toString().isNotEmpty
                      ? user["name"].toString()[0].toUpperCase()
                      : "?",
                  style: TextStyle(
                    color: _roleColor(role),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user["name"] ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(user["email"] ?? "-", style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ])),
            ]),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),

            // Suspend / Unsuspend option
            if (!isAdmin)
              ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: isSuspended
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    isSuspended ? Icons.check_circle_outline : Icons.block_outlined,
                    color: isSuspended ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  isSuspended ? "Aktifkan Akun" : "Suspend Akun",
                  style: TextStyle(
                    color: isSuspended ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  isSuspended
                      ? "User bisa login kembali"
                      : "User tidak bisa login",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  toggleSuspend(user);
                },
              ),

            if (isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 8),
                  Text("Akun admin tidak bisa disuspend",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ]),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return "-";
    final d = DateTime.tryParse(date.toString());
    if (d == null) return "-";
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${months[d.month - 1]} ${d.year}";
  }

  Color _roleColor(String? role) {
    switch (role) {
      case "admin":     return Colors.purple;
      case "organizer": return Colors.blue;
      default:          return Colors.grey;
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users.where((u) =>
      (u["name"] ?? "").toString().toLowerCase().contains(q) ||
      (u["email"] ?? "").toString().toLowerCase().contains(q)
    ).toList();
  }

  int get totalUsers      => users.length;
  int get totalOrganizers => users.where((u) => u["role"] == "organizer").length;
  int get suspendedCount  => users.where((u) => u["is_suspended"] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Column(children: [

        // ── Header ──────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("User Management",
                    style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Manage platform users and roles",
                    style: TextStyle(color: Colors.white70)),
              ]),
              IconButton(onPressed: fetchUsers, icon: const Icon(Icons.refresh, color: Colors.white70)),
            ]),

            const SizedBox(height: 15),

            // Search
            TextField(
              onChanged: (v) { setState(() => searchQuery = v); fetchUsers(); },
              decoration: InputDecoration(
                hintText: "Search users...",
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white70),
                        onPressed: () { setState(() => searchQuery = ""); fetchUsers(); },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),

            if (!isLoading) ...[
              const SizedBox(height: 14),
              Row(children: [
                _summaryChip("$totalUsers Users", Icons.people_outline),
                const SizedBox(width: 8),
                _summaryChip("$totalOrganizers Organizer", Icons.business_center_outlined),
                const SizedBox(width: 8),
                if (suspendedCount > 0)
                  _summaryChip("$suspendedCount Suspended", Icons.block_outlined,
                      color: Colors.orange),
              ]),
            ],
          ]),
        ),

        // ── Content ──────────────────────────────────
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: fetchUsers, child: const Text("Coba Lagi")),
                    ]))
                  : filteredUsers.isEmpty
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.person_off_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text("Tidak ada user ditemukan",
                              style: TextStyle(color: Colors.grey.shade500)),
                        ]))
                      : RefreshIndicator(
                          onRefresh: fetchUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                            itemCount: filteredUsers.length,
                            itemBuilder: (_, i) => _userCard(filteredUsers[i]),
                          ),
                        ),
        ),
      ]),
    );
  }

  Widget _summaryChip(String label, IconData icon, {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ]),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final role        = u["role"]?.toString() ?? "user";
    final isSuspended = u["is_suspended"] == true;
    final roleColor   = _roleColor(role);
    final tickets     = int.tryParse(u["tickets_owned"]?.toString() ?? "0") ?? 0;
    final events      = int.tryParse(u["events_created"]?.toString() ?? "0") ?? 0;
    final initial     = (u["name"] ?? "?").toString().isNotEmpty
        ? u["name"].toString()[0].toUpperCase()
        : "?";
    final isAdmin     = role == "admin";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        // Subtle red tint untuk akun suspended
        border: isSuspended
            ? Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSuspended
                    ? Colors.red.withValues(alpha: 0.08)
                    : roleColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initial, style: TextStyle(
                  color: isSuspended ? Colors.red : roleColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
              ),
            ),
            // Suspended badge
            if (isSuspended)
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(u["name"] ?? "-",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSuspended ? Colors.grey : const Color(0xFF2F3E2F),
                ))),
            // More options
            GestureDetector(
              onTap: () => _showUserOptions(u),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
              ),
            ),
          ]),

          const SizedBox(height: 2),
          Text(u["email"] ?? "-",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              overflow: TextOverflow.ellipsis),

          const SizedBox(height: 8),

          // Chips
          Row(children: [
            _chip(role, roleColor.withValues(alpha: 0.12), roleColor),
            const SizedBox(width: 6),
            _chip(
              isSuspended ? "Suspended" : "Active",
              isSuspended
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.green.withValues(alpha: 0.1),
              isSuspended ? Colors.red : Colors.green,
              icon: isSuspended ? Icons.block_outlined : Icons.check_circle_outline,
            ),
          ]),

          const SizedBox(height: 8),

          // Stats + quick suspend button
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.calendar_today_outlined, size: 11, color: Colors.grey.shade400),
              const SizedBox(width: 3),
              Text(_formatDate(u["created_at"]),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              const SizedBox(width: 10),
              if (role == "user") ...[
                Icon(Icons.confirmation_number_outlined, size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text("$tickets tiket",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
              if (role == "organizer") ...[
                Icon(Icons.event_outlined, size: 11, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text("$events event",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ]),

            // Quick suspend toggle (tidak tampil untuk admin)
            if (!isAdmin)
              GestureDetector(
                onTap: () => toggleSuspend(u),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSuspended
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      isSuspended ? Icons.lock_open_outlined : Icons.block_outlined,
                      size: 12,
                      color: isSuspended ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isSuspended ? "Aktifkan" : "Suspend",
                      style: TextStyle(
                        fontSize: 11,
                        color: isSuspended ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                ),
              ),
          ]),
        ])),
      ]),
    );
  }

  Widget _chip(String text, Color bg, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
        ],
        Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}