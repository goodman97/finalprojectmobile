import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/services/storage_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;
  String? scanStatus; // valid / invalid / already_used / error
  Map<String, dynamic>? ticketData;

  Future<void> validateTicket(String code) async {
    if (isProcessing || scanStatus != null) return;

    setState(() {
      isProcessing = true;
      scanStatus = null;
    });

    try {
      final token = await StorageService.getToken();

      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/tickets/scan"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"qr": code}),
      );

      final data = jsonDecode(res.body);

      setState(() {
        isProcessing = false;
        scanStatus = data["status"] ?? "invalid";
        ticketData = data["ticket"];
      });

      // Auto reset setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            scanStatus = null;
            ticketData = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        isProcessing = false;
        scanStatus = "error";
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => scanStatus = null);
      });
    }
  }

  Color get _overlayColor {
    switch (scanStatus) {
      case "valid":
        return Colors.green.withValues(alpha: 0.88);
      case "already_used":
        return Colors.orange.withValues(alpha: 0.88);
      case "event_ended":
        return Colors.purple.withValues(alpha: 0.88);
      case "error":
        return Colors.grey.withValues(alpha: 0.88);
      default:
        return Colors.red.withValues(alpha: 0.88);
    }
  }

  IconData get _overlayIcon {
    switch (scanStatus) {
      case "valid":
        return Icons.check_circle_outline;
      case "already_used":
        return Icons.warning_amber_rounded;
      case "event_ended":
        return Icons.event_busy;
      default:
        return Icons.cancel_outlined;
    }
  }

  String get _overlayText {
    switch (scanStatus) {
      case "valid":
        return "ACCESS GRANTED";
      case "already_used":
        return "ALREADY USED";
      case "event_ended":
        return "EVENT SUDAH BERAKHIR";
      case "error":
        return "SERVER ERROR";
      default:
        return "INVALID TICKET";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Tiket"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [

          // Camera 
          MobileScanner(
            onDetect: (barcodeCapture) {
              final code = barcodeCapture.barcodes.firstOrNull?.rawValue;
              if (code != null) validateTicket(code);
            },
          ),

          // Scan frame overlay 
          if (scanStatus == null && !isProcessing)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE4572E),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Arahkan ke QR Code",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading 
          if (isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Result overlay 
          if (scanStatus != null)
            AnimatedOpacity(
              opacity: scanStatus != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: _overlayColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_overlayIcon, size: 100, color: Colors.white),

                      const SizedBox(height: 20),

                      Text(
                        _overlayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 12),

                      if (ticketData != null) ...[
                        Text(
                          ticketData!["name"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticketData!["email"] ?? "",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Scanning lagi dalam 3 detik...",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}