import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;

  String? scanStatus; // valid / invalid / already_used
  Map<String, dynamic>? ticketData;

  Future<void> validateTicket(String code) async {
    setState(() {
      isProcessing = true;
      scanStatus = null;
    });

    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/tickets/scan"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"qr": code}),
      );

      final data = jsonDecode(res.body);

      setState(() {
        isProcessing = false;
        scanStatus = data["status"];
        ticketData = data["ticket"];
      });

      // auto reset setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            scanStatus = null;
            ticketData = null;
          });
        }
      });

    } catch (e) {
      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal konek ke server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: Stack(
        children: [

          /// 🔥 CAMERA
          MobileScanner(
            onDetect: (barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              final code = barcode.rawValue;

              if (code != null &&
                  !isProcessing &&
                  scanStatus == null) {
                validateTicket(code);
              }
            },
          ),

          /// 🔄 LOADING
          if (isProcessing)
            const Center(child: CircularProgressIndicator()),

          /// 🔥 RESULT OVERLAY
          if (scanStatus != null)
            Container(
              color: scanStatus == "valid"
                  ? Colors.green.withOpacity(0.85)
                  : Colors.red.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Icon(
                      scanStatus == "valid"
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 100,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    Text(
                      scanStatus == "valid"
                          ? "ACCESS GRANTED"
                          : scanStatus == "already_used"
                              ? "ALREADY USED"
                              : "INVALID TICKET",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (ticketData != null)
                      Text(
                        ticketData!["name"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}