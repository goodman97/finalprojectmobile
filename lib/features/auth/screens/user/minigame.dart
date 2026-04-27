import 'dart:math';
import 'package:flutter/material.dart';

class MiniGame extends StatefulWidget {
  const MiniGame({super.key});

  @override
  State<MiniGame> createState() => _GameScreenState();
}

class _GameScreenState extends State<MiniGame>
    with SingleTickerProviderStateMixin {
  int totalPoints = 340;
  int dailySpins = 3;

  double rotation = 0;
  bool isSpinning = false;

  final List<Map<String, dynamic>> rewards = [
    {"label": "10 Points", "value": 10},
    {"label": "25 Points", "value": 25},
    {"label": "50 Points", "value": 50},
    {"label": "100 Points", "value": 100},
    {"label": "5% Discount", "value": "discount"},
    {"label": "Free Ticket", "value": "ticket"},
  ];

  void spinWheel() {
    if (dailySpins <= 0 || isSpinning) return;

    setState(() {
      isSpinning = true;
      dailySpins--;
    });

    final random = Random();
    int index = random.nextInt(rewards.length);

    double segment = 360 / rewards.length;
    double targetAngle = index * segment;

    double newRotation = rotation + 360 * 5 + targetAngle;

    setState(() {
      rotation = newRotation;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isSpinning = false;

        if (rewards[index]["value"] is int) {
          totalPoints += rewards[index]["value"] as int;
        }
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Congratulations"),
          content: Text(rewards[index]["label"]),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔥 HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
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
                          Text("Gelatik Flight",
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text("Spin and earn rewards",
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
                      Expanded(child: statCard("Total Points", "$totalPoints")),
                      const SizedBox(width: 10),
                      Expanded(child: statCard("Daily Spins", "$dailySpins")),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 WHEEL
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [

                  Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),

                  AnimatedRotation(
                    turns: rotation / 360,
                    duration: const Duration(seconds: 3),
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2F3E2F),
                      ),
                      child: const Center(
                        child: Text("Spin",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),

                  // POINTER
                  Positioned(
                    top: 0,
                    child: Icon(Icons.arrow_drop_down,
                        size: 40, color: Colors.orange),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: spinWheel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4572E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    isSpinning
                        ? "Spinning..."
                        : "Spin the Wheel ($dailySpins left)",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 PROGRESS CARD
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Your Progress",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Next Reward: Free Ticket"),
                        Text("$totalPoints/1000"),
                      ],
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: totalPoints / 1000,
                      color: const Color(0xFFE4572E),
                      backgroundColor: Colors.grey.shade300,
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        progressStat("$totalPoints", "Points"),
                        progressStat("0", "Tickets"),
                        progressStat("0%", "Discounts"),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 🔥 HOW IT WORKS
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
                    Text("• Get 3 free spins daily"),
                    Text("• Collect points to unlock tickets"),
                    Text("• Win discounts"),
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

  Widget statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget progressStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}