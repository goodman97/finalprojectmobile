import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/services/validation_service.dart';
import 'package:finalproject/features/auth/screens/eo/eo_qr_scan.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:finalproject/utils/date_utils.dart';

class OrganizerTickets extends StatefulWidget {
  const OrganizerTickets({super.key});

  @override
  State<OrganizerTickets> createState() => _OrganizerTicketsState();
}

class _OrganizerTicketsState extends State<OrganizerTickets> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final d = await ValidationService.getValidationStats();
      setState(() {
        data = d;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  String _timeAgo(dynamic d) => AppDateUtils.timeAgo(d);

  @override
  Widget build(BuildContext context) {
    final stats = data?["stats"] ?? {};
    final validations = data?["recentValidations"] as List? ?? [];

    final today = stats["today"]?.toString() ?? "0";
    final thisWeek = stats["this_week"]?.toString() ?? "0";
    final total = stats["total"]?.toString() ?? "0";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3E2F),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ticket Scanner",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    "Scan & validate tickets at your events",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── QR Scanner Card ──
            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 42,
                      color: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3E2F),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Position the ticket QR code to validate entry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QRScannerScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Open Scanner",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.grey, size: 48),
                              const SizedBox(height: 8),
                              Text(
                                "Gagal memuat data",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _load,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE4572E),
                                ),
                                child: const Text("Retry",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.fromLTRB(16, 20, 16, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Validation Stats ──
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Validation Stats",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2F3E2F)),
                                    ),
                                    Icon(Icons.trending_up,
                                        color: Colors.green.shade600,
                                        size: 20),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _statCard(
                                      value: today,
                                      label: "Today",
                                      valueColor: const Color(0xFF2F3E2F),
                                    ),
                                    const SizedBox(width: 10),
                                    _statCard(
                                      value: thisWeek,
                                      label: "This Week",
                                      valueColor: const Color(0xFFE4572E),
                                    ),
                                    const SizedBox(width: 10),
                                    _statCard(
                                      value: total,
                                      label: "Total",
                                      valueColor: Colors.green.shade600,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // ── Recent Validations ──
                                const Text(
                                  "Recent Validations",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F3E2F)),
                                ),
                                const SizedBox(height: 12),

                                if (validations.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6)
                                      ],
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Belum ada validasi",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 6)
                                      ],
                                    ),
                                    child: Column(
                                      children: validations
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key;
                                        final v = entry.value
                                            as Map<String, dynamic>;
                                        final isValid =
                                            v["status"] == "used";
                                        final code =
                                            v["qr_code"]?.toString() ?? "-";
                                        final eventName =
                                            v["event_name"]?.toString() ??
                                                "-";
                                        final holderName =
                                            v["holder_name"]?.toString() ??
                                                "-";

                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14),
                                              child: Row(
                                                children: [
                                                  // Status icon
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: isValid
                                                          ? Colors.green
                                                              .withOpacity(
                                                                  0.1)
                                                          : Colors.red
                                                              .withOpacity(
                                                                  0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      isValid
                                                          ? Icons
                                                              .check_circle
                                                          : Icons.cancel,
                                                      color: isValid
                                                          ? Colors.green
                                                          : Colors.red,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              code,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14,
                                                                  color: Color(
                                                                      0xFF2F3E2F)),
                                                            ),
                                                            Text(
                                                              _timeAgo(v[
                                                                  "updated_at"]),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      11),
                                                            ),
                                                          ],
                                                        ),
                                                        Text(
                                                          eventName,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                        Text(
                                                          holderName,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isValid
                                                                ? Colors.green
                                                                    .withOpacity(
                                                                        0.1)
                                                                : Colors.red
                                                                    .withOpacity(
                                                                        0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Text(
                                                            isValid
                                                                ? "Validated"
                                                                : "Invalid",
                                                            style: TextStyle(
                                                              color: isValid
                                                                  ? Colors
                                                                      .green
                                                                  : Colors
                                                                      .red,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (i <
                                                validations.length - 1)
                                              const Divider(
                                                  height: 1, indent: 64),
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
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            Text(
              value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: valueColor),
            ),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// QR Scanner Page
class _QRScannerPage extends StatefulWidget {
  const _QRScannerPage();

  @override
  State<_QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<_QRScannerPage> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    _scanned = true;
    _ctrl.stop();

    // Validate via backend
    try {
      final token = await StorageService.getToken();
      final r = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/tickets/validate"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"qr_code": code}),
      );

      final data = jsonDecode(r.body);
      final isValid = r.statusCode == 200;

      if (!mounted) return;
      _showResult(context, isValid, data["message"] ?? "", code);
    } catch (e) {
      if (!mounted) return;
      _showResult(context, false, "Gagal memvalidasi tiket", code);
    }
  }

  void _showResult(
      BuildContext ctx, bool isValid, String message, String code) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.cancel,
              color: isValid ? Colors.green : Colors.red,
              size: 64,
            ),
            const SizedBox(height: 12),
            Text(
              isValid ? "Ticket Valid!" : "Ticket Invalid",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isValid ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              code,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4572E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Done",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _scanned = false);
        _ctrl.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Scan Ticket"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),
          // Overlay frame
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                    color: const Color(0xFFE4572E), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              "Align QR code within the frame",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}