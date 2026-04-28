import 'package:flutter/material.dart';

class AssignTicketScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const AssignTicketScreen({
    super.key,
    required this.event,
  });

  @override
  State<AssignTicketScreen> createState() =>
      _AssignTicketScreenState();
}

class _AssignTicketScreenState extends State<AssignTicketScreen> {
  final name = TextEditingController();
  final email = TextEditingController();

  int selectedIndex = 0;

  final List<Map<String, dynamic>> ticketTypes = [
    {"name": "Client Invitation", "price": 120, "available": 5},
    {"name": "General Admission", "price": 45, "available": 166},
    {"name": "Student Discount", "price": 30, "available": 11},
  ];

  void submit() {
    if (name.text.isEmpty || email.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Navigator.pop(context, {
      "id": "TIX-CLT-${DateTime.now().millisecondsSinceEpoch}",
      "status": "assigned",
      "name": name.text,
      "email": email.text,
      "date": "Today"
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Column(
        children: [

          /// 🔥 HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Assign Ticket",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      "Send ticket to a user",
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                )
              ],
            ),
          ),

          /// 🔥 FORM
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// 🔹 TICKET TYPE
                  const Text("Ticket Type"),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedIndex,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: List.generate(ticketTypes.length, (i) {
                          final t = ticketTypes[i];
                          return DropdownMenuItem(
                            value: i,
                            child: Text(
                              "${t["name"]} • \$${t["price"]} • ${t["available"]} available",
                            ),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedIndex = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    "Select the ticket type to assign",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 FULL NAME
                  const Text("Full Name"),
                  const SizedBox(height: 6),
                  _input(
                    controller: name,
                    hint: "Enter user name",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    "Enter the full name of the ticket recipient",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  /// 🔹 EMAIL
                  const Text("Email Address"),
                  const SizedBox(height: 6),
                  _input(
                    controller: email,
                    hint: "user@email.com",
                    icon: Icons.email,
                  ),

                  const SizedBox(height: 4),
                  const Text(
                    "Enter the email address of the ticket recipient",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const Spacer(),

                  /// 🔥 SEND BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: submit,
                      icon: const Icon(Icons.send),
                      label: const Text("Send Ticket"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// CANCEL
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}