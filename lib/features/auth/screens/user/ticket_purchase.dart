import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    loadTicketTypes();
    loadUserPoints();
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
        }

        isLoading = false;
      });
    } catch (e) {
      print("LOAD TICKET ERROR: $e");

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

      print("POINT BODY: ${response.body}");

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
      print("LOAD POINT ERROR: $e");
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
      setState(() {
        isProcessing = true;
      });

      await TicketService.purchase(
        eventId:
            widget.event["id"].toString(),
        ticketTypeId:
            selectedTypeId ?? "general",
        quantity: quantity,
        voucherCode:
            appliedVoucherCode,
        pointsUsed:
            finalPointsUsed,
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

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text(
              "Purchase Success"),
          content: Text(
            "Voucher: $discountPercent%\n"
            "Points Used: $finalPointsUsed\n"
            "Final Total: Rp $total",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
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
          // handle bar
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
                                .withOpacity(
                                    0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // left side
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

                            // dashed separator
                            CustomPaint(
                              size: const Size(
                                  10, 80),
                              painter:
                                  _DashedLinePainter(),
                            ),

                            // right side
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
      backgroundColor:
          const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text(
            "Purchase Ticket"),
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(
                      16),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .all(16),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          "Ticket Price",
                          "Rp $ticketPrice",
                        ),
                        _summaryRow(
                          "Quantity",
                          "$quantity",
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
                            children: [
                              const Text(
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

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
                                      fontSize: 28,
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
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                            height: 20),

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
                              const Text(
                                "Voucher Discount",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      vouchers.isEmpty
                                          ? null
                                          : showVoucherPopup,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFFE4572E),
                                  ),
                                  icon: const Icon(
                                    Icons.discount,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    appliedVoucherCode == null
                                        ? "Choose Voucher"
                                        : "$discountPercent% Voucher Applied",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "$userPoints pts",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE4572E),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Slider(
                                value: pointsUsed.toDouble(),
                                min: 0,
                                max: userPoints.toDouble(),
                                divisions:
                                    userPoints > 0
                                        ? userPoints
                                        : 1,
                                activeColor:
                                    const Color(0xFFE4572E),
                                onChanged: userPoints == 0
                                    ? null
                                    : (value) {
                                        setState(() {
                                          pointsUsed =
                                              value.toInt();
                                        });
                                      },
                              ),

                              Center(
                                child: Text(
                                  "Using $pointsUsed points",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

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
                          "Rp $total",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                      height: 20),

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
                                  color: Colors.white,
                                )
                              : Text(
                                  "Purchase Rp $total",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
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
        Offset(
          size.width / 2,
          startY + dashHeight,
        ),
        paint,
      );

      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}