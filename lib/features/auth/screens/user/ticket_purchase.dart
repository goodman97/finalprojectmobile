import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';
import 'package:finalproject/services/ticket_service.dart';

class TicketPurchase extends StatefulWidget {
  final Map<String, dynamic> event;

  const TicketPurchase({
    super.key,
    required this.event,
  });

  @override
  State<TicketPurchase> createState() =>
      _TicketPurchaseState();
}

class _TicketPurchaseState
    extends State<TicketPurchase> {
  List ticketTypes = [];
  List vouchers = [];

  bool isLoading = true;
  bool isProcessing = false;

  String? selectedTypeId;
  String? appliedVoucherCode;

  int quantity = 1;
  int discountPercent = 0;
  int userPoints = 0;
  int pointsUsed = 0;

  // Currency Conversion
  static const String _exchangeApiKey = 'cc924ed5bb5159482cfc6dca';
  static const String _exchangeBaseUrl =
      'https://v6.exchangerate-api.com/v6/$_exchangeApiKey';

  /// Supported currencies: code → display label
  static const Map<String, String> _currencies = {
    'IDR': '🇮🇩 IDR – Rupiah',
    'USD': '🇺🇸 USD – US Dollar',
    'EUR': '🇪🇺 EUR – Euro',
    'JPY': '🇯🇵 JPY – Japanese Yen',
    'SGD': '🇸🇬 SGD – Singapore Dollar',
    'MYR': '🇲🇾 MYR – Malaysian Ringgit',
    'GBP': '🇬🇧 GBP – British Pound',
    'AUD': '🇦🇺 AUD – Australian Dollar',
    'KRW': '🇰🇷 KRW – Korean Won',
  };

  String _selectedCurrency = 'IDR';
  double _exchangeRate = 1.0;      // IDR → selectedCurrency
  bool _isLoadingRate = false;
  String? _rateError;

  @override
  void initState() {
    super.initState();
    loadTicketTypes();
    loadUserPoints();
  }

  // Currency helpers 
  Future<void> _fetchExchangeRate(String targetCurrency) async {
    if (targetCurrency == 'IDR') {
      setState(() {
        _exchangeRate = 1.0;
        _selectedCurrency = 'IDR';
        _rateError = null;
      });
      return;
    }

    setState(() {
      _isLoadingRate = true;
      _rateError = null;
    });

    try {
      final url = Uri.parse('$_exchangeBaseUrl/latest/IDR');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          final rates = data['conversion_rates'] as Map<String, dynamic>;
          final rate = (rates[targetCurrency] as num?)?.toDouble() ?? 1.0;

          setState(() {
            _exchangeRate = rate;
            _selectedCurrency = targetCurrency;
            _isLoadingRate = false;
          });
        } else {
          throw Exception(data['error-type'] ?? 'Unknown error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingRate = false;
        _rateError = 'Gagal memuat kurs: $e';
      });
    }
  }

  /// Convert an IDR amount to the selected currency and format it.
  String _convertAmount(int idrAmount) {
    if (_selectedCurrency == 'IDR') {
      return 'Rp ${_formatNumber(idrAmount)}';
    }
    final converted = idrAmount * _exchangeRate;
    final symbol = _currencySymbol(_selectedCurrency);
    return '$symbol ${_formatConverted(converted)}';
  }

  String _currencySymbol(String code) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'JPY': '¥',
      'GBP': '£',
      'AUD': 'A\$',
      'SGD': 'S\$',
      'MYR': 'RM',
      'KRW': '₩',
    };
    return symbols[code] ?? code;
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatConverted(double value) {
    if (value >= 1000) {
      return value.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return value.toStringAsFixed(4);
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange, color: Color(0xFFE4572E)),
                  SizedBox(width: 8),
                  Text(
                    'Pilih Mata Uang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ..._currencies.entries.map((entry) {
              final isSelected = _selectedCurrency == entry.key;
              return ListTile(
                leading: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFFE4572E))
                    : const Icon(Icons.radio_button_unchecked,
                        color: Colors.grey),
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context);
                  _fetchExchangeRate(entry.key);
                },
                tileColor: isSelected
                    ? const Color(0xFFE4572E).withValues(alpha: 0.06)
                    : null,
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> loadTicketTypes() async {
    try {
      final eventId =
          widget.event["id"]?.toString() ?? "";

      final data =
          await TicketService.getTicketTypes(
        eventId,
      );

      setState(() {
        ticketTypes = data;

        if (data.isNotEmpty) {
          selectedTypeId =
              data[0]["id"].toString();
        } else {
          // Fallback: coba ambil ticket_type_id langsung dari event object
          final fallback = widget.event["ticket_type_id"]?.toString();
          if (fallback != null && fallback.isNotEmpty) {
            selectedTypeId = fallback;
          } else {
          }
        }

        isLoading = false;
      });
    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadUserPoints() async {
    try {
      final token =
          await StorageService.getToken();

      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/api/minigame",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        setState(() {
          userPoints = int.tryParse(
                data["points"].toString(),
              ) ??
              0;

          vouchers =
              data["vouchers"] ?? [];
        });
      }
    } catch (e) {
    }
  }

  Map<String, dynamic>? get selectedTicket {
    if (selectedTypeId == null) return null;

    try {
      return ticketTypes.firstWhere(
        (e) =>
            e["id"].toString() ==
            selectedTypeId,
      );
    } catch (_) {
      return null;
    }
  }

  int get ticketPrice {
    int price = 0;

    if (selectedTicket != null) {
      price = int.tryParse(
            selectedTicket!["price"]
                .toString(),
          ) ??
          0;
    }

    if (price == 0) {
      price = int.tryParse(
            widget.event["price"]
                .toString(),
          ) ??
          0;
    }

    return price;
  }

  int get baseTotal =>
      ticketPrice * quantity;

  int get voucherDiscount =>
      ((baseTotal * discountPercent) / 100)
          .round();

  int get finalPointsUsed {
    final subtotal =
        baseTotal - voucherDiscount;

    if (pointsUsed > subtotal) {
      return subtotal;
    }

    return pointsUsed;
  }

  int get total {
    final subtotal =
        baseTotal - voucherDiscount;

    return subtotal -
        finalPointsUsed +
        5;
  }

  Future<void> handlePurchase() async {
    try {
      // Validasi ticket type ID sebelum purchase
      if (selectedTypeId == null || selectedTypeId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal: ticket type tidak ditemukan. Coba refresh halaman."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isProcessing = true;
      });

      // Kirim ke backend — backend yang generate qr_code di server
      final result = await TicketService.purchase(
        ticketTypeId: selectedTypeId!,
        quantity: quantity,
        voucherCode: appliedVoucherCode,
        pointsUsed: finalPointsUsed,
      );

      setState(() {
        isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 3),
          content: Text(
            "🎉 You earned +1 spin! Check your notifications.",
          ),
        ),
      );

      // Backend return: { tickets: [{ticketId, qrCode}, ...] }
      // Field qrCode (camelCase) sesuai ticketController.js: createdTickets.push({ ticketId, qrCode })
      List<String> allQrCodes = [];
      final dynamic ticketsData = result['tickets'];

      if (ticketsData is List && ticketsData.isNotEmpty) {
        allQrCodes = ticketsData
            .map((t) => (t['qrCode'] ?? t['qr_code'])?.toString() ?? '')
            .where((q) => q.isNotEmpty)
            .toList();
      }

      // Fallback jika struktur response tidak sesuai
      if (allQrCodes.isEmpty) {
        final singleQr = result['qrCode'] ?? result['qr_code'];
        if (singleQr != null) allQrCodes = [singleQr.toString()];
      }

      _showTicketDialog(
        qrCodes: allQrCodes,
        discountPercent: discountPercent,
        pointsUsed: finalPointsUsed,
        total: total,
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  void _showTicketDialog({
    required List<String> qrCodes,
    required int discountPercent,
    required int pointsUsed,
    required int total,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ──────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE4572E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${qrCodes.length} tiket telah dibeli',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Summary ──────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F1E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _dialogRow('Diskon Voucher', '$discountPercent%'),
                      _dialogRow('Poin Digunakan', '$pointsUsed pts'),
                      const Divider(height: 12),
                      _dialogRow(
                        'Total Bayar',
                        _convertAmount(total),
                        bold: true,
                        valueColor: const Color(0xFFE4572E),
                      ),
                      if (_selectedCurrency != 'IDR')
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '(Rp ${_formatNumber(total)} IDR)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'Tunjukkan QR Code ini\nsaat check-in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // ── QR Code(s) ───────────────────────
                if (qrCodes.length == 1)
                  _buildQrWidget(qrCodes.first, label: null)
                else
                  SizedBox(
                    height: 260,
                    child: PageView.builder(
                      itemCount: qrCodes.length,
                      itemBuilder: (_, i) => _buildQrWidget(
                        qrCodes[i],
                        label: 'Tiket ${i + 1} / ${qrCodes.length}',
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Close button ─────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE4572E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrWidget(String data, {String? label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Color(0xFF1A1A2E),
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          data,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontFamily: 'monospace',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _dialogRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade700, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
              fontSize: bold ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }

  void showVoucherPopup() {
    final unused =
        vouchers.where((v) => v["used"] == false).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(2),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer,
                    color: Color(0xFFE4572E),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "My Vouchers",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: unused.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "No vouchers available",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount: unused.length,
                      itemBuilder: (ctx, i) {
                        final v = unused[i];
                        final pct =
                            v["value"] ?? 0;

                        return Container(
                          margin:
                              const EdgeInsets.only(
                                  bottom: 12),
                          decoration:
                              BoxDecoration(
                            color: const Color(
                                0xFFF5F1E8),
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        18),
                            border: Border.all(
                              color: const Color(
                                      0xFFE4572E)
                                  .withValues(
                                      alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration:
                                    const BoxDecoration(
                                  color: Color(
                                      0xFFE4572E),
                                  borderRadius:
                                      BorderRadius
                                          .only(
                                    topLeft:
                                        Radius.circular(
                                            18),
                                    bottomLeft:
                                        Radius.circular(
                                            18),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      "$pct%",
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize:
                                            22,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    const Text(
                                      "OFF",
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .white70,
                                        fontSize:
                                            11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              CustomPaint(
                                size: const Size(
                                    10, 80),
                                painter:
                                    _DashedLinePainter(),
                              ),

                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        "$pct% Discount Voucher",
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color: Color(
                                              0xFF2F3E2F),
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 4),
                                      const Text(
                                        "Valid for this ticket purchase",
                                        style:
                                            TextStyle(
                                          color: Colors
                                              .grey,
                                          fontSize:
                                              12,
                                        ),
                                      ),
                                      const SizedBox(
                                          height: 8),

                                      SizedBox(
                                        height: 32,
                                        child:
                                            ElevatedButton(
                                          onPressed:
                                              () {
                                            setState(
                                                () {
                                              appliedVoucherCode =
                                                  v["id"];

                                              discountPercent =
                                                  int.tryParse(
                                                        v["value"]
                                                            .toString(),
                                                      ) ??
                                                      0;
                                            });

                                            Navigator.pop(
                                                context);
                                          },
                                          style:
                                              ElevatedButton
                                                  .styleFrom(
                                            backgroundColor:
                                                const Color(
                                                    0xFFE4572E),
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10),
                                            ),
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal:
                                                  16,
                                            ),
                                          ),
                                          child:
                                              const Text(
                                            "Use",
                                            style:
                                                TextStyle(
                                              color: Colors
                                                  .white,
                                              fontSize:
                                                  13,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Purchase Ticket"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Currency Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        const Row(
                          children: [
                            Icon(
                              Icons.currency_exchange,
                              color: Color(0xFFE4572E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Konversi Mata Uang",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _showCurrencyPicker,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE4572E),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _currencies[_selectedCurrency] ??
                                  _selectedCurrency,
                              style: const TextStyle(
                                color: Color(0xFFE4572E),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Main Purchase Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Ticket Type

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Color(0xFFE4572E),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Choose Ticket Type",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F3E2F),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              if (ticketTypes.isEmpty)
                                const Text(
                                  "No ticket types available",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                )
                              else
                                DropdownButtonFormField<String>(
                                value: selectedTypeId,
                                dropdownColor: Colors.white,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xFF2F3E2F),
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF2F3E2F),
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF5F1E8),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE4572E),
                                    ),
                                  ),
                                ),
                                items: ticketTypes.map((ticket) {
                                  return DropdownMenuItem<String>(
                                    value:
                                        ticket["id"].toString(),
                                    child: Text(
                                      "${ticket["name"]} - Rp ${ticket["price"]}",
                                      style: const TextStyle(
                                        color: Color(0xFF2F3E2F),
                                        fontWeight:
                                            FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        _summaryRow(
                          "Ticket Price",
                          _convertAmount(
                              ticketPrice),
                        ),

                        _summaryRow(
                          "Quantity",
                          "$quantity",
                        ),

                        const SizedBox(
                            height: 20),

                        // Quantity
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    onPressed: quantity > 1
                                        ? () {
                                            setState(() {
                                              quantity--;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text(
                                    "$quantity",
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        // Voucher Button
                        SizedBox(
                          width:
                              double.infinity,
                          child:
                             ElevatedButton.icon(
                              onPressed: showVoucherPopup,
                              icon: const Icon(
                                Icons.local_offer,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Choose Voucher",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE4572E),
                                minimumSize:
                                    const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                              ),
                            ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Use Points",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "$userPoints pts",
                                    style: const TextStyle(
                                      color: Color(0xFFE4572E),
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: pointsUsed.toDouble(),
                                min: 0,
                                max: userPoints.toDouble(),
                                activeColor:
                                    const Color(0xFFE4572E),
                                onChanged: (value) {
                                  setState(() {
                                    pointsUsed = value.toInt();
                                  });
                                },
                              ),
                              Center(
                                child: Text(
                                  "Using $pointsUsed points",
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

                        _summaryRow(
                          "Voucher Discount",
                          "-Rp $voucherDiscount",
                        ),

                        _summaryRow(
                          "Points Used",
                          "-Rp $finalPointsUsed",
                        ),

                        _summaryRow(
                          "Service Fee",
                          "Rp 5",
                        ),

                        const Divider(),

                        _summaryRow(
                          "Total",
                          _convertAmount(
                              total),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,
                    child:
                        ElevatedButton(
                      onPressed:
                          isProcessing
                              ? null
                              : handlePurchase,
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                                0xFFE4572E),
                      ),
                      child:
                          isProcessing
                              ? const CircularProgressIndicator(
                                  color: Colors
                                      .white,
                                )
                              : Text(
                                  "Purchase ${_convertAmount(total)}",
                                  style:
                                      const TextStyle(
                                    color: Colors
                                        .white,
                                  ),
                                ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
              vertical: 6),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 5.0;
    const dashSpace = 4.0;

    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;

    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}