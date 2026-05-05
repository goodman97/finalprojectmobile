import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/utils/date_utils.dart';

class TicketDetail extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const TicketDetail({super.key, required this.ticket});

  String _formatDate(String? date) => AppDateUtils.formatDateLong(date);

  String _formatTime(String? date) => AppDateUtils.formatTime(date);

  ImageProvider _getImage(String? image) {
    if (image == null || image.isEmpty) {
      return const AssetImage('assets/images/placeholder.jpg');
    }
    if (image.startsWith('http')) return NetworkImage(image);
    final base = ApiConfig.baseUrl;
    final path = image.startsWith('/') ? image : '/uploads/$image';
    return NetworkImage('$base$path');
  }

  bool get _isActive => ticket['status'] == 'active';

  @override
  Widget build(BuildContext context) {
    final qrCode = ticket['qr_code']?.toString() ?? '';
    final ticketId = ticket['ticket_id']?.toString() ?? '';
    final eventName = ticket['event_name']?.toString() ?? '';
    final ticketType = ticket['ticket_type']?.toString() ?? '';
    final eventDate = ticket['event_date']?.toString();
    final location = ticket['location']?.toString() ?? '';
    final image = ticket['image']?.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF1A2A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2A1A),
        foregroundColor: Colors.white,
        title: const Text('My Ticket'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Ticket Card ───────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  // Header: Event name + status badge
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image(
                            image: _getImage(image),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eventName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ticketType,
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isActive
                                ? const Color(0xFFE4572E)
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isActive ? 'Active' : 'Used',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // QR Code area
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Corner brackets
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // QR Code
                            qrCode.isNotEmpty
                                ? QrImageView(
                                    data: qrCode,
                                    version: QrVersions.auto,
                                    size: 200,
                                    backgroundColor: Colors.white,
                                    eyeStyle: const QrEyeStyle(
                                      eyeShape: QrEyeShape.square,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                    dataModuleStyle: const QrDataModuleStyle(
                                      dataModuleShape: QrDataModuleShape.circle,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  )
                                : const SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Center(child: Text('No QR Code',
                                        style: TextStyle(color: Colors.grey)))),
                            // Corner brackets overlay
                            SizedBox(
                              width: 220,
                              height: 220,
                              child: CustomPaint(
                                painter: _CornerBracketPainter(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan at venue entrance',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ticket ID
                  Text(
                    'Ticket ID',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qrCode.isNotEmpty ? qrCode : ticketId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF2F3E2F),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dashed divider
                  _DashedDivider(),

                  const SizedBox(height: 20),

                  // Event details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _detailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: _formatDate(eventDate),
                        ),
                        const SizedBox(height: 14),
                        _detailRow(
                          icon: Icons.access_time_outlined,
                          label: 'Time',
                          value: _formatTime(eventDate),
                        ),
                        const SizedBox(height: 14),
                        _detailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Venue',
                          value: location.isNotEmpty ? location : '-',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Ownership Journey ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F1E8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.route_outlined,
                          color: const Color(0xFFE4572E), size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Ownership Journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2F3E2F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _journeyStep(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Ticket Purchased',
                    subtitle: 'You are the original owner',
                    isLast: _isActive,
                  ),
                  if (!_isActive)
                    _journeyStep(
                      icon: Icons.check_circle_outline,
                      title: 'Ticket Used',
                      subtitle: 'Scanned at venue entrance',
                      isLast: true,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF2F3E2F)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _journeyStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE4572E),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: const Color(0xFFE4572E).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dashed Divider ────────────────────────────────────────────────────────────
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left notch
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2A1A),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _DashedLinePainter(),
          ),
        ),
        // Right notch
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;

    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Corner Bracket Painter ────────────────────────────────────────────────────
class _CornerBracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE4572E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 20.0;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawLine(Offset(0, len), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    // Top-right
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    // Bottom-right
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// QR rendering handled by qr_flutter package