import 'package:flutter/material.dart';
import 'package:finalproject/services/ticket_service.dart';

class TicketPurchase extends StatefulWidget {
  final Map<String, dynamic> event;

  const TicketPurchase({super.key, required this.event});

  @override
  State<TicketPurchase> createState() => _TicketPurchaseState();
}

class _TicketPurchaseState extends State<TicketPurchase> {
  List ticketTypes = [];
  bool isLoading = true;
  String? selectedTypeId;
  int quantity = 1;
  bool isProcessing = false;
  String? appliedVoucherCode;
  int discountPercent = 0;

  @override
  void initState() {
    super.initState();
    loadTicketTypes();
  }

  Future<void> loadTicketTypes() async {
    try {
      final eventId = widget.event["id"]?.toString() ?? "";
      final data = await TicketService.getTicketTypes(eventId);
      setState(() {
        ticketTypes = data;
        if (data.isNotEmpty) selectedTypeId = data[0]["id"].toString();
        isLoading = false;
      });
    } catch (e) {
      // Fallback: use dummy types based on event price
      final basePrice = int.tryParse(widget.event["price"].toString()) ?? 89;
      setState(() {
        ticketTypes = [
          {
            "id": "general",
            "name": "General Admission",
            "price": basePrice,
            "description": "Access to main event area",
            "quota": 150,
          },
          {
            "id": "vip",
            "name": "VIP Pass",
            "price": (basePrice * 2.2).round(),
            "description": "Front row access + backstage tour",
            "quota": 45,
          },
          {
            "id": "premium",
            "name": "Premium Package",
            "price": (basePrice * 3.9).round(),
            "description": "All VIP benefits + meet & greet",
            "quota": 12,
          },
        ];
        selectedTypeId = "general";
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? get selectedTicket {
    if (selectedTypeId == null) return null;
    try {
      return ticketTypes.firstWhere(
        (t) => t["id"].toString() == selectedTypeId,
      );
    } catch (_) {
      return ticketTypes.isNotEmpty ? ticketTypes[0] : null;
    }
  }

  int get baseTotal {
    final price = int.tryParse(selectedTicket?["price"].toString() ?? "0") ?? 0;
    return price * quantity;
  }

  int get discountAmount => (baseTotal * discountPercent / 100).round();
  int get total => baseTotal - discountAmount + 5;

  Future<void> handlePurchase() async {
    setState(() => isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isProcessing = false);

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2F3E2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              "Purchase Successful!",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tickets will be stored securely in your wallet",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4572E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("View My Tickets",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Color(0xFF2F3E2F)),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Purchase Tickets",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3E2F)),
                      ),
                      Text("Select your tickets",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TICKET TYPES
                          const Text("Ticket Type",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F))),
                          const SizedBox(height: 12),

                          ...ticketTypes.map((ticket) {
                            final isSelected =
                                selectedTypeId == ticket["id"].toString();
                            final price = ticket["price"] ?? 0;
                            final quota = ticket["quota"] ?? 0;

                            return GestureDetector(
                              onTap: () => setState(
                                  () => selectedTypeId = ticket["id"].toString()),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE4572E)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? const Color(0xFFE4572E)
                                              .withOpacity(0.1)
                                          : Colors.black12,
                                      blurRadius: 6,
                                    )
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                (ticket["name"] ?? "").toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2F3E2F)),
                                              ),
                                              if (isSelected) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFE4572E),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(Icons.check,
                                                      color: Colors.white,
                                                      size: 10),
                                                )
                                              ]
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            (ticket["description"] ?? "")
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\$$price",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE4572E),
                                          ),
                                        ),
                                        Text(
                                          "$quota left",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 8),

                          // QUANTITY
                          const Text("Quantity",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F))),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6)
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _qtyBtn(
                                  Icons.remove,
                                  quantity <= 1
                                      ? null
                                      : () => setState(() => quantity--),
                                ),
                                Text(
                                  "$quantity",
                                  style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2F3E2F)),
                                ),
                                _qtyBtn(
                                  Icons.add,
                                  quantity >= 10
                                      ? null
                                      : () => setState(() => quantity++),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // VOUCHER (if applied)
                          if (discountPercent > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4572E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: const Color(0xFFE4572E)
                                        .withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer,
                                      color: Color(0xFFE4572E), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Discount $discountPercent% applied",
                                    style: const TextStyle(
                                        color: Color(0xFFE4572E),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      discountPercent = 0;
                                      appliedVoucherCode = null;
                                    }),
                                    child: const Icon(Icons.close,
                                        color: Color(0xFFE4572E), size: 18),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // SUMMARY
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Summary",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2F3E2F))),
                                const SizedBox(height: 16),
                                _summaryRow("Ticket Price",
                                    "\$${selectedTicket?["price"] ?? 0}"),
                                const SizedBox(height: 8),
                                _summaryRow("Quantity", "× $quantity"),
                                const SizedBox(height: 8),
                                _summaryRow("Service Fee", "\$5"),
                                if (discountPercent > 0) ...[
                                  const SizedBox(height: 8),
                                  _summaryRow(
                                      "Discount $discountPercent%",
                                      "-\$$discountAmount",
                                      valueColor: Colors.green),
                                ],
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2F3E2F))),
                                    Text("\$$total",
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFE4572E))),
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // PURCHASE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isProcessing ? null : handlePurchase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE4572E),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                              child: isProcessing
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text("Processing...",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16)),
                                      ],
                                    )
                                  : Text(
                                      "Purchase for \$$total",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Center(
                            child: Text(
                              "Tickets will be stored securely in your wallet",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.grey.shade200
              : const Color(0xFFF5F1E8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color:
                onTap == null ? Colors.grey : const Color(0xFF2F3E2F)),
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
