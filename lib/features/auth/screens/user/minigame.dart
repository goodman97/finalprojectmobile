import 'package:flutter/material.dart';
import 'package:finalproject/services/minigame_service.dart';

class MiniGame extends StatefulWidget {
  const MiniGame({super.key});

  @override
  State<MiniGame> createState() => _GameScreenState();
}

class _GameScreenState extends State<MiniGame>
    with SingleTickerProviderStateMixin {

  int totalPoints = 0;
  int remainingSpins = 0;

  double rotation = 0;
  bool isSpinning = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGameData();
  }

  // LOAD DATA 
  Future<void> loadGameData() async {
    try {
      final data = await MiniGameService.getGameData();

      setState(() {
        totalPoints = data["points"] ?? 0;
        remainingSpins = data["spins"] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      print("LOAD ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // SPIN
  void spinWheel() async {
    if (remainingSpins <= 0 || isSpinning) return;

    setState(() {
      isSpinning = true;
    });

    try {
      final result = await MiniGameService.spin();

      setState(() {
        rotation += 360 * 5;
      });

      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        isSpinning = false;
        totalPoints = result["totalPoints"] ?? totalPoints;
        remainingSpins = result["spinsLeft"] ?? 0;
      });

      String text = "";

      if (result["type"] == "points") {
        text = "${result["value"]} Points";
      } else if (result["type"] == "discount") {
        text = "${result["value"]}% Discount";
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Congratulations"),
          content: Text(text),
        ),
      );

    } catch (e) {
      setState(() {
        isSpinning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [

                  // HEADER
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
                            Expanded(child: statCard("Remaining Spins", "$remainingSpins")),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // WHEEL
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

                        Positioned(
                          top: 0,
                          child: Icon(Icons.arrow_drop_down,
                              size: 40, color: Colors.orange),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON
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
                              : "Spin the Wheel ($remainingSpins left)",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PROGRESS
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
                              const Text("Next Reward: Points"),
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
                              progressStat("-", "Discounts"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // HOW IT WORKS (TIDAK DIUBAH)
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
                          Text("• Spin berdasarkan jumlah tiket"),
                          Text("• Kumpulkan points"),
                          Text("• Dapatkan voucher discount"),
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