import 'package:flutter/material.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SingleChildScrollView(
        child: Column(
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
                        "Create Event",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Fill in the event details",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  )
                ],
              ),
            ),

            /// 🔥 BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// IMAGE UPLOAD
                  const Text("Event Image"),
                  const SizedBox(height: 10),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.image, size: 40, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Click to upload image"),
                        Text("PNG, JPG up to 5MB",
                            style: TextStyle(fontSize: 12))
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// EVENT NAME
                  _field("Event Name"),

                  /// LOCATION
                  _field("Location", icon: Icons.location_on),

                  /// DATE ROW
                  Row(
                    children: [
                      Expanded(child: _dateField("Start Date", startDate, (d) {
                        setState(() => startDate = d);
                      })),
                      const SizedBox(width: 10),
                      Expanded(child: _dateField("End Date", endDate, (d) {
                        setState(() => endDate = d);
                      })),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// TIME
                  _timeField(),

                  const SizedBox(height: 15),

                  /// PRICE & QUOTA
                  Row(
                    children: [
                      Expanded(child: _field("Ticket Price", icon: Icons.attach_money)),
                      const SizedBox(width: 10),
                      Expanded(child: _field("Quota", icon: Icons.people)),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// DESCRIPTION
                  const Text("Description"),
                  const SizedBox(height: 5),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Tell people about your event...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// 🔥 PUBLISH BUTTON
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
                      child: const Text("Publish Event"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// CANCEL BUTTON
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
            )
          ],
        ),
      ),
    );
  }

  /// 🔹 INPUT FIELD
  Widget _field(String hint, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔹 DATE FIELD
  Widget _dateField(String label, DateTime? value, Function(DateTime) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(value == null
                    ? "dd/mm/yyyy"
                    : "${value.day}/${value.month}/${value.year}")
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 🔹 TIME FIELD
  Widget _timeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Start Time"),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() => startTime = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(startTime == null
                    ? "--:--"
                    : startTime!.format(context))
              ],
            ),
          ),
        ),
      ],
    );
  }
}