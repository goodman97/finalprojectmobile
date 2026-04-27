import 'package:flutter/material.dart';

class AdminHomescreen extends StatelessWidget {
  const AdminHomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin Dashboard",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text("System overview and monitoring",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STATS GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  Row(
                    children: [
                      Expanded(child: statCard("3,492", "Total Users", "+8.2%")),
                      SizedBox(width: 10),
                      Expanded(child: statCard("24", "Total Events", "+12%")),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: statCard("1,847", "Tickets Sold", "+23%")),
                      SizedBox(width: 10),
                      Expanded(child: statCard("\$42,890", "Revenue", "+18.5%")),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // RECENT ACTIVITY
            sectionCard(
              title: "Recent Activity",
              children: [
                activityItem("Sarah Wilson", "Purchased ticket • Jazz Night Live", "5 min ago"),
                activityItem("Mike Johnson", "Created event • Summer Festival", "12 min ago"),
                activityItem("Emma Davis", "Purchased ticket • Rock Concert", "18 min ago"),
                activityItem("John Smith", "Listed ticket • Tech Conference", "25 min ago"),
              ],
            ),

            const SizedBox(height: 15),

            // TRANSACTIONS
            sectionCard(
              title: "Recent Transactions",
              children: [
                transactionItem("Sarah Wilson", "TXN-8472", "\$245", true),
                transactionItem("Mike Johnson", "TXN-8471", "\$120", true),
                transactionItem("Emma Davis", "TXN-8470", "\$580", false),
                transactionItem("John Smith", "TXN-8469", "\$95", true),
              ],
            ),

            const SizedBox(height: 15),

            // SYSTEM STATUS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("System Status",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        statusBox("99.8%", "Uptime", Colors.green),
                        statusBox("142ms", "Response", Colors.blue),
                        statusBox("3.2K", "Active Now", Colors.purple),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class statCard extends StatelessWidget {
  final String value, label, change;

  const statCard(this.value, this.label, this.change, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(change,
                style: const TextStyle(color: Colors.green, fontSize: 12)),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

Widget sectionCard({required String title, required List<Widget> children}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children
        ],
      ),
    ),
  );
}

Widget activityItem(String name, String action, String time) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name),
          Text(action, style: const TextStyle(fontSize: 12)),
        ]),
        Text(time, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

Widget transactionItem(String name, String id, String amount, bool success) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name),
          Text(id, style: const TextStyle(fontSize: 12)),
        ]),
        Row(
          children: [
            Text(amount),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: success ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                success ? "completed" : "pending",
                style: TextStyle(
                  fontSize: 10,
                  color: success ? Colors.green : Colors.orange,
                ),
              ),
            )
          ],
        )
      ],
    ),
  );
}

class statusBox extends StatelessWidget {
  final String value, label;
  final Color color;

  const statusBox(this.value, this.label, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}