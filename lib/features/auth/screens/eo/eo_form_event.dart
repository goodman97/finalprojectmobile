import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:finalproject/services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final quotaController = TextEditingController();
  final descController = TextEditingController();

  File? imageFile;
  Uint8List? webImage;

  final picker = ImagePicker();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          imageFile = File(picked.path);
        });
      }
    }
  }

  String formatDateTime(DateTime date, TimeOfDay time) {
    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return dt.toIso8601String();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text("Create Event"),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// IMAGE
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: webImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(webImage!, fit: BoxFit.cover),
                      )
                    : imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.image, size: 40),
                              Text("Click to upload image"),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 20),

            _field("Event Name", controller: nameController),
            _field("Location", controller: locationController),

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

            _timeField(),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(child: _field("Price", controller: priceController)),
                const SizedBox(width: 10),
                Expanded(child: _field("Quota", controller: quotaController)),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Description...",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () async {
                try {
                  if (startDate == null || endDate == null || startTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lengkapi tanggal & waktu")),
                    );
                    return;
                  }

                  final start = formatDateTime(startDate!, startTime!);
                  final end = formatDateTime(endDate!, startTime!);

                  await EventService.createEvent(
                    name: nameController.text,
                    location: locationController.text,
                    description: descController.text,
                    startDate: start,
                    endDate: end,
                    price: priceController.text,
                    quota: quotaController.text,
                    image: imageFile,
                    webImage: webImage,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Event berhasil dibuat")),
                  );

                  Navigator.pop(context, true);
                } catch (e) {
                  print("ERROR: $e");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gagal membuat event")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4572E),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Publish Event"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String hint, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, Function(DateTime) onPick) {
    return GestureDetector(
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value == null
              ? label
              : "${value.day}/${value.month}/${value.year}",
        ),
      ),
    );
  }

  Widget _timeField() {
    return GestureDetector(
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          startTime == null ? "Select Time" : startTime!.format(context),
        ),
      ),
    );
  }
}