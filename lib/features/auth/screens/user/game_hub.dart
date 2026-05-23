import 'package:flutter/material.dart';
import 'package:finalproject/features/auth/screens/user/minigame.dart';
import 'package:finalproject/features/auth/screens/user/tilt_maze_game.dart';

class GameHub extends StatelessWidget {
  const GameHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Mini Games 🎮",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              "Pilih game & raih hadiah!",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(Icons.sports_esports,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Pilih Game",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3E2F)),
                ),
              ),

              const SizedBox(height: 14),

              // ── GAME CARD 1: SPIN WHEEL ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GameCard(
                  title: "Spin & Win",
                  subtitle: "Kocok HP untuk memutar roda!\nMenangkan poin & voucher diskon.",
                  icon: Icons.rotate_right,
                  sensorLabel: "Sensor: Accelerometer",
                  sensorIcon: Icons.vibration,
                  gradient: const [Color(0xFF2F3E2F), Color(0xFF4E5F4E)],
                  badgeText: "SHAKE",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MiniGame()),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── GAME CARD 2: TILT MAZE ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _GameCard(
                  title: "Tilt Maze",
                  subtitle: "Miringkan HP untuk gerakkan bola!\nCapai finish untuk menang poin.",
                  icon: Icons.sports_soccer,
                  sensorLabel: "Sensor: Gyroscope",
                  sensorIcon: Icons.screen_rotation,
                  gradient: const [Color(0xFFE4572E), Color(0xFFB83E1F)],
                  badgeText: "TILT",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TiltMazeGame()),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── INFO CARD ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6)
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("💡 Tips",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 10),
                      _TipRow(
                          icon: Icons.vibration,
                          text: "Spin Wheel: kocok HP kuat-kuat untuk spin otomatis"),
                      SizedBox(height: 6),
                      _TipRow(
                          icon: Icons.screen_rotation,
                          text: "Tilt Maze: miringkan HP pelan-pelan untuk kontrol bola"),
                      SizedBox(height: 6),
                      _TipRow(
                          icon: Icons.stars,
                          text: "Poin & voucher bisa dipakai saat beli tiket"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String sensorLabel;
  final IconData sensorIcon;
  final List<Color> gradient;
  final String badgeText;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sensorLabel,
    required this.sensorIcon,
    required this.gradient,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(sensorIcon, color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        sensorLabel,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFE4572E)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
      ],
    );
  }
}