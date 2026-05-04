import 'package:flutter/material.dart';
import 'package:finalproject/services/admin_service.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  /// Format currency to IDR (Rupiah)
  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await AdminService.getTransactions(
        status: filter != "all" ? filter : null,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );

      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
      print("ERROR FETCHING TRANSACTIONS: $e");
    }
  }

  List<Map<String, dynamic>> get filteredTransactions {
    return transactions;
  }

  int get total => transactions.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                        _fetchTransactions();
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

              /// ERROR MESSAGE
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
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
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// LOADING STATE
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFE4572E)),
                      ),
                      const SizedBox(height: 10),
                      const Text("Loading transactions..."),
                    ],
                  ),
                )
              else if (filteredTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 10),
                      Text("No transactions found",
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              else
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
              Text(
                _formatCurrency(t["amount"]),
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