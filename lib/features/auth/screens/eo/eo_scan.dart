import 'package:flutter/material.dart';

class OrganizerTickets extends StatelessWidget {
  OrganizerTickets({super.key});

  final List<Map<String, dynamic>> recentValidations = [
    {
      "id": "TIX-8547",
      "event": "Summer Music Fest",
      "user": "Sarah Wilson",
      "time": "2 min ago",
      "status": "valid",
    },
    {
      "id": "TIX-8546",
      "event": "Jazz Night Live",
      "user": "Mike Johnson",
      "time": "8 min ago",
      "status": "valid",
    },
    {
      "id": "TIX-8545",
      "event": "Summer Music Fest",
      "user": "John Doe",
      "time": "15 min ago",
      "status": "invalid",
    },
    {
      "id": "TIX-8544",
      "event": "Rock Festival 2026",
      "user": "Emma Davis",
      "time": "22 min ago",
      "status": "valid",
    },
  ];

  final stats = {
    "today": 45,
    "thisWeek": 234,
    "total": 1254,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2F4F3F),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ticket Validation",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Scan and verify tickets",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SCANNER CARD
            _card(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner,
                        size: 60, color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  const Text("Scan QR Code",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text(
                    "Position the ticket QR code to validate entry",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {},
                    child: const Text("Open Scanner"),
                  )
                ],
              ),
            ),

            /// STATS
            _card(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Validation Stats",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Icon(Icons.trending_up, color: Colors.green)
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _statBox("${stats["today"]}", "Today", Colors.grey),
                      _statBox("${stats["thisWeek"]}", "This Week",
                          Colors.orange),
                      _statBox("${stats["total"]}", "Total", Colors.green),
                    ],
                  )
                ],
              ),
            ),

            /// RECENT VALIDATIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Recent Validations",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  ...recentValidations.map((item) {
                    return _ticketCard(item);
                  }).toList()
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// CARD WRAPPER
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5),
        ],
      ),
      child: child,
    );
  }

  /// STAT BOX
  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /// TICKET CARD
  Widget _ticketCard(Map<String, dynamic> item) {
    bool isValid = item["status"] == "valid";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item["id"],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Icon(
                isValid ? Icons.check_circle : Icons.cancel,
                color: isValid ? Colors.green : Colors.red,
                size: 18,
              ),
              const Spacer(),
              Text(item["time"],
                  style: const TextStyle(fontSize: 11, color: Colors.grey))
            ],
          ),
          const SizedBox(height: 6),
          Text(item["event"],
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(item["user"],
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isValid ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isValid ? "Validated" : "Invalid",
              style: TextStyle(
                fontSize: 11,
                color: isValid ? Colors.green : Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}