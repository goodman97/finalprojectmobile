import 'package:flutter/material.dart';

class CreateTicketTypeScreen extends StatefulWidget {
  const CreateTicketTypeScreen({super.key});

  @override
  State<CreateTicketTypeScreen> createState() =>
      _CreateTicketTypeScreenState();
}

class _CreateTicketTypeScreenState
    extends State<CreateTicketTypeScreen> {

  final name = TextEditingController();
  final price = TextEditingController();
  final quota = TextEditingController();

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
                      "Create Ticket Type",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Define a new ticket category",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
          ),

          /// 🔥 BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TICKET NAME
                  const Text("Ticket Name"),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: name,
                    hint: "Enter ticket name",
                    icon: Icons.text_fields,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "e.g., VIP Pass, General Admission, Student Discount",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  /// PRICE
                  const Text("Price"),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: price,
                    hint: "0.00",
                    icon: Icons.attach_money,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Set the price per ticket",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  /// QUOTA
                  const Text("Quota"),
                  const SizedBox(height: 6),
                  _inputField(
                    controller: quota,
                    hint: "100",
                    icon: Icons.people,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Total number of tickets available",
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),

                  const Spacer(),

                  /// 🔥 CREATE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4572E),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text("Create Ticket Type"),
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

  /// 🔹 INPUT FIELD
  Widget _inputField({
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