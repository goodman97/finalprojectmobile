import 'package:flutter/material.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState
    extends State<AdminTransactionsScreen> {
  String filter = "all";
  String searchQuery = "";

  final List<Map<String, dynamic>> transactions = [
    {
      "id": "TXN-8547",
      "user": "Sarah Wilson",
      "event": "Jazz Night Live",
      "ticketId": "TIX-3421",
      "amount": "\$40",
      "status": "completed",
      "time": "5 min ago",
    },
    {
      "id": "TXN-8545",
      "user": "Emma Davis",
      "event": "Rock Concert",
      "ticketId": "TIX-3419",
      "amount": "\$120",
      "status": "pending",
      "time": "18 min ago",
    },
    {
      "id": "TXN-8543",
      "user": "Lisa Anderson",
      "event": "Art Exhibition",
      "ticketId": "TIX-3417",
      "amount": "\$25",
      "status": "failed",
      "time": "32 min ago",
    },
  ];

  List<Map<String, dynamic>> get filteredTransactions {
    return transactions.where((t) {
      final matchSearch = t["id"]
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          t["user"]
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchFilter =
          filter == "all" ? true : t["status"] == filter;

      return matchSearch && matchFilter;
    }).toList();
  }

  int get total => transactions.length;
  int get completed =>
      transactions.where((t) => t["status"] == "completed").length;
  int get pending =>
      transactions.where((t) => t["status"] == "pending").length;
  int get failed =>
      transactions.where((t) => t["status"] == "failed").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transaction Monitoring",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Track all platform transactions",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

                  /// SEARCH
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search transactions...",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statBox("$total", "Total", Colors.white, Colors.black),
                  _statBox("$completed", "Done",
                      Colors.green.withOpacity(0.1), Colors.green),
                  _statBox("$pending", "Pending",
                      Colors.orange.withOpacity(0.1), Colors.orange),
                  _statBox("$failed", "Failed",
                      Colors.red.withOpacity(0.1), Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// FILTER
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _tab("all", "All"),
                  _tab("completed", "Completed"),
                  _tab("pending", "Pending"),
                  _tab("failed", "Failed"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Column(
              children: filteredTransactions
                  .map((t) => _transactionCard(t))
                  .toList(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// TAB
  Widget _tab(String key, String label) {
    bool isSelected = filter == key;

    return GestureDetector(
      onTap: () {
        setState(() {
          filter = key;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE4572E)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// STAT BOX
  Widget _statBox(
      String value, String label, Color bg, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(fontSize: 11, color: textColor)),
          ],
        ),
      ),
    );
  }

  /// CARD
  Widget _transactionCard(Map<String, dynamic> t) {
    Color color;
    if (t["status"] == "completed") {
      color = Colors.green;
    } else if (t["status"] == "pending") {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Text(t["id"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    _chip(t["status"], color),
                  ],
                ),

                const SizedBox(height: 5),

                Text(t["user"]),

                const SizedBox(height: 3),

                Text(
                  "${t["event"]} • ${t["ticketId"]}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 3),

                Text(
                  t["time"],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          /// AMOUNT
          Column(
            children: [
              const Icon(Icons.attach_money,
                  color: Color(0xFFE4572E)),
              Text(
                t["amount"],
                style: const TextStyle(
                    color: Color(0xFFE4572E),
                    fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  /// CHIP
  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color),
      ),
    );
  }
}