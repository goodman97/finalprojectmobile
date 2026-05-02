import 'dart:math';
import 'package:flutter/material.dart';
import 'package:finalproject/services/minigame_service.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';

//  Wheel segment data
class WheelSegment {
  final String label;
  final Color color;
  final String type;
  final int value;

  const WheelSegment({
    required this.label,
    required this.color,
    required this.type,
    required this.value,
  });
}

const List<WheelSegment> kSegments = [
  WheelSegment(label: "10 pts",    color: Color(0xFF2F3E2F), type: "points",   value: 10),
  WheelSegment(label: "5% OFF",    color: Color(0xFFE4572E), type: "discount", value: 5),
  WheelSegment(label: "25 pts",    color: Color(0xFF4E5F4E), type: "points",   value: 25),
  WheelSegment(label: "10% OFF",   color: Color(0xFFB83E1F), type: "discount", value: 10),
  WheelSegment(label: "100 pts",   color: Color(0xFF2F3E2F), type: "points",   value: 100),
  WheelSegment(label: "5% OFF",    color: Color(0xFFE4572E), type: "discount", value: 5),
  WheelSegment(label: "250 pts",   color: Color(0xFF4E5F4E), type: "points",   value: 250),
  WheelSegment(label: "15% OFF",   color: Color(0xFF8B2500), type: "discount", value: 15),
];

//  Custom painter for the wheel
class WheelPainter extends CustomPainter {
  final double rotationAngle;

  WheelPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / kSegments.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < kSegments.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;
      final paint = Paint()..color = kSegments[i].color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Divider line
      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;
      final lineEnd = Offset(
        center.dx + radius * cos(startAngle),
        center.dy + radius * sin(startAngle),
      );
      canvas.drawLine(center, lineEnd, linePaint);

      // Label
      final midAngle = startAngle + segmentAngle / 2;
      final labelRadius = radius * 0.65;
      final labelPos = Offset(
        center.dx + labelRadius * cos(midAngle),
        center.dy + labelRadius * sin(midAngle),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: kSegments[i].label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(labelPos.dx, labelPos.dy);
      canvas.rotate(midAngle + pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    canvas.restore();

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, ringPaint);

    // Center dot
    canvas.drawCircle(center, 14, Paint()..color = Colors.white);
    canvas.drawCircle(center, 10, Paint()..color = const Color(0xFFE4572E));
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) =>
      oldDelegate.rotationAngle != rotationAngle;
}

//  MiniGame screen
class MiniGame extends StatefulWidget {
  const MiniGame({super.key});

  @override
  State<MiniGame> createState() => _GameScreenState();
}

class _GameScreenState extends State<MiniGame>
    with SingleTickerProviderStateMixin {
  int totalPoints = 0;
  int remainingSpins = 0;
  int totalTickets = 0;
  List vouchers = [];

  double _wheelAngle = 0;
  bool isSpinning = false;
  bool isLoading = true;

  late AnimationController _animCtrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    loadGameData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> loadGameData() async {
    try {
      final data = await MiniGameService.getGameData();
      setState(() {
        totalPoints = data["points"] ?? 0;
        remainingSpins = data["spins"] ?? 0;
        vouchers = data["vouchers"] ?? [];
        totalTickets = data["tickets"] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print("LOAD ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // Find segment index by type+value from spin result
  int _findSegmentIndex(String type, int value) {
    for (int i = 0; i < kSegments.length; i++) {
      if (kSegments[i].type == type && kSegments[i].value == value) return i;
    }
    // Closest match by type
    for (int i = 0; i < kSegments.length; i++) {
      if (kSegments[i].type == type) return i;
    }
    return 0;
  }

  void spinWheel() async {
    if (remainingSpins <= 0 || isSpinning) return;

    setState(() => isSpinning = true);

    try {
      final result = await MiniGameService.spin();

      final targetSegment = _findSegmentIndex(
        result["type"] ?? "points",
        (result["value"] ?? 0) as int,
      );

      final segmentAngle = 2 * pi / kSegments.length;
      // We want pointer (top) to point at center of target segment
      final targetAngle = -(targetSegment * segmentAngle + segmentAngle / 2);
      // Add 5 full rotations for visual effect
      final totalAngle = _wheelAngle + (5 * 2 * pi) +
          (targetAngle - _wheelAngle % (2 * pi) + 2 * pi) % (2 * pi);

      _animation = Tween<double>(begin: _wheelAngle, end: totalAngle).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
      );

      _animCtrl.reset();

      _animation.addListener(() {
        setState(() => _wheelAngle = _animation.value);
      });

      await _animCtrl.forward();

      setState(() {
        _wheelAngle = totalAngle % (2 * pi);
        isSpinning = false;
        totalPoints = result["totalPoints"] ?? totalPoints;
        remainingSpins = result["spinsLeft"] ?? 0;
        // Reload vouchers if discount was won
        if (result["type"] == "discount") {
          loadGameData();
        }
      });

      // Show reward dialog
      _showRewardDialog(result);
    } catch (e) {
      setState(() => isSpinning = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showRewardDialog(Map<String, dynamic> result) {
    final type = result["type"] ?? "points";
    final value = result["value"] ?? 0;
    final isDiscount = type == "discount";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDiscount
                      ? const Color(0xFFE4572E)
                      : const Color(0xFF2F3E2F),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDiscount ? Icons.local_offer : Icons.stars,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text("Congratulations! 🎉",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                isDiscount ? "You won $value% Discount!" : "You won $value Points!",
                style: TextStyle(
                  fontSize: 16,
                  color: isDiscount
                      ? const Color(0xFFE4572E)
                      : const Color(0xFF2F3E2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4572E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Awesome!",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Show voucher list popup
  void _showVoucherPopup() {
    final unused = vouchers.where((v) => v["used"] == false).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Color(0xFFE4572E)),
                  SizedBox(width: 8),
                  Text("My Vouchers",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: unused.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("No vouchers yet",
                              style: TextStyle(color: Colors.grey)),
                          Text("Spin the wheel to earn discount vouchers!",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: unused.length,
                      itemBuilder: (ctx, i) {
                        final v = unused[i];
                        final pct = v["value"] ?? 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F1E8),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: const Color(0xFFE4572E).withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              // Left ticket stub
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE4572E),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("$pct%",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold)),
                                    const Text("OFF",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              // Dashed separator
                              CustomPaint(
                                size: const Size(10, 80),
                                painter: _DashedLinePainter(),
                              ),
                              // Right content
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("$pct% Discount Voucher",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2F3E2F))),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Valid for any event ticket",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // Navigate to Market tab
                                            Navigation.setIndex(context, 3);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFE4572E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                          child: const Text("Use",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unusedVouchers =
        vouchers.where((v) => v["used"] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ─── HEADER ───────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(40)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Spin & Win",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                Text("Earn points & vouchers",
                                    style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.auto_awesome,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: _statCard("Total Points", "$totalPoints",
                                    Icons.stars)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _statCard("Spins Left",
                                    "$remainingSpins", Icons.refresh)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── PRIZE LEGEND ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("🎁 Possible Prizes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: kSegments.map((s) {
                              final isDiscount = s.type == "discount";
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: s.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: s.color.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                        isDiscount
                                            ? Icons.local_offer
                                            : Icons.stars,
                                        color: s.color,
                                        size: 14),
                                    const SizedBox(width: 4),
                                    Text(s.label,
                                        style: TextStyle(
                                            color: s.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── SPIN WHEEL ──────────────────────────────
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow circle
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE4572E).withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                      ),
                      // Wheel
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: CustomPaint(
                          painter: WheelPainter(rotationAngle: _wheelAngle),
                        ),
                      ),
                      // Pointer arrow
                      Positioned(
                        top: 0,
                        child: CustomPaint(
                          size: const Size(30, 30),
                          painter: _PointerPainter(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── SPIN BUTTON ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: (remainingSpins > 0 && !isSpinning)
                            ? spinWheel
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE4572E),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          isSpinning
                              ? "Spinning..."
                              : remainingSpins <= 0
                                  ? "No Spins Left"
                                  : "Spin the Wheel  ($remainingSpins left)",
                          style: TextStyle(
                              color: remainingSpins <= 0 && !isSpinning
                                  ? Colors.grey
                                  : Colors.white,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── REWARDS SUMMARY ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("My Rewards",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F3E2F))),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Points
                              Expanded(
                                child: _rewardCard(
                                  icon: Icons.stars,
                                  color: const Color(0xFF2F3E2F),
                                  label: "Points",
                                  value: "$totalPoints",
                                  onTap: null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Tickets
                              Expanded(
                                child: _rewardCard(
                                  icon: Icons.confirmation_num,
                                  color: const Color(0xFF4E5F4E),
                                  label: "Tickets",
                                  value: "$totalTickets",
                                  onTap: null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Vouchers (tappable)
                              Expanded(
                                child: _rewardCard(
                                  icon: Icons.local_offer,
                                  color: const Color(0xFFE4572E),
                                  label: "Vouchers",
                                  value: "$unusedVouchers",
                                  badge: unusedVouchers > 0,
                                  onTap: _showVoucherPopup,
                                ),
                              ),
                            ],
                          ),

                          // Progress bar
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Next milestone",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              Text("$totalPoints / 1000 pts",
                                  style: const TextStyle(
                                      color: Color(0xFF2F3E2F),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (totalPoints / 1000).clamp(0.0, 1.0),
                              minHeight: 8,
                              color: const Color(0xFFE4572E),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── HOW IT WORKS ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("How It Works",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text("• Spin berdasarkan jumlah tiket yang dibeli"),
                          Text("• Kumpulkan points untuk reward eksklusif"),
                          Text("• Dapatkan voucher diskon untuk pembelian tiket"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rewardCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    bool badge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 11)),
                if (onTap != null)
                  const SizedBox(height: 4),
                if (onTap != null)
                  Text("tap to view",
                      style: TextStyle(
                          color: color, fontSize: 9, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (badge)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4572E),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//  Pointer arrow painter
class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE4572E);
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_) => false;
}

//  Dashed line painter for voucher card
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
