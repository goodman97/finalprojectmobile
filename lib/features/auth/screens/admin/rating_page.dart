import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() =>
      _RatingPageState();
}

class _RatingPageState
    extends State<RatingPage> {
  int selectedRating = 0;

  bool isEditMode = false;
  bool hasExistingRating = false;

  final TextEditingController feedbackController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedRating();
  }

  Future<void> loadSavedRating() async {
    final prefs =
        await SharedPreferences.getInstance();

    int savedRating =
        prefs.getInt("admin_rating") ?? 0;

    String savedFeedback =
        prefs.getString(
              "admin_feedback",
            ) ??
            "";

    setState(() {
      selectedRating = savedRating;
      feedbackController.text =
          savedFeedback;

      hasExistingRating =
          savedRating > 0 ||
              savedFeedback.isNotEmpty;

      // kalau belum ada data → langsung edit mode
      isEditMode = !hasExistingRating;
    });
  }

  Future<void> saveRating() async {
    String feedback =
        feedbackController.text.trim();

    if (selectedRating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Please give rating first"),
        ),
      );
      return;
    }

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "Please write feedback"),
        ),
      );
      return;
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      "admin_rating",
      selectedRating,
    );

    await prefs.setString(
      "admin_feedback",
      feedback,
    );

    setState(() {
      hasExistingRating = true;
      isEditMode = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text("Rating saved"),
      ),
    );
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: isEditMode
          ? () {
              setState(() {
                selectedRating = index;
              });
            }
          : null,
      icon: Icon(
        index <= selectedRating
            ? Icons.star
            : Icons.star_border,
        color: Colors.orange,
        size: 35,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F1E8),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF2F3E2F),
        title: const Text(
          "Impressions & Suggestions for TPM",
          style: TextStyle(
              color: Colors.white),
        ),
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Rate Your Experience ",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF2F3E2F),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) =>
                    buildStar(index + 1),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Your Feedback",
              style: TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  feedbackController,
              enabled: isEditMode,
              maxLines: 5,
              decoration:
                  InputDecoration(
                hintText:
                    "Write your impressions and suggestions...",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              20),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  ElevatedButton(
                onPressed: () {
                  if (isEditMode) {
                    saveRating();
                  } else {
                    setState(() {
                      isEditMode =
                          true;
                    });
                  }
                },
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                          0xFFE4572E),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            20),
                  ),
                ),
                child: Text(
                  isEditMode
                      ? "Save"
                      : "Edit Rating",
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}