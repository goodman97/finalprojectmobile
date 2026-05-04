import 'package:flutter/material.dart';
import 'package:finalproject/services/user_tickets_service.dart';
import 'package:finalproject/config/api_config.dart';
import 'package:finalproject/features/auth/screens/user/navigation.dart';
import 'package:finalproject/features/auth/screens/user/ticket_detail.dart';

class MyTickets extends StatefulWidget {
  const MyTickets({super.key});

  @override
  State<MyTickets> createState() => _MyTicketsState();
}

class _MyTicketsState extends State<MyTickets> {
  List upcoming = [];
  List past = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      final data = await UserTicketsService.getMyTickets();

      setState(() {
        upcoming = data["upcoming"] ?? [];
        past = data["past"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD TICKETS: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // HEADER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "My Tickets",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F3E2F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text("${upcoming.length} active tickets"),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFE4572E),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () {
                              Navigation.setIndex(context, 3);
                            },
                          ),
                        )
                      ],
                    ),
                  ),

                  // CONTENT
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: loadTickets,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // UPCOMING
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Upcoming",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (upcoming.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("No active tickets"),
                              ),

                            ...upcoming.map((item) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketDetail(
                                          ticket: Map<String, dynamic>.from(item),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: ticketCard(
                                      title: item["event_name"] ?? "",
                                      type: item["ticket_type"] ?? "",
                                      date: formatDate(item["event_date"]),
                                      location: item["location"] ?? "",
                                      image: item["image"],
                                    ),
                                  ),
                                )),

                            const SizedBox(height: 20),

                            // PAST
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Past Events",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (past.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text("No past tickets"),
                              ),

                            ...past.map((item) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketDetail(
                                          ticket: Map<String, dynamic>.from(item),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: pastTicketCard(
                                      title: item["event_name"] ?? "",
                                      type: item["ticket_type"] ?? "",
                                      date: formatDate(item["event_date"]),
                                      image: item["image"],
                                    ),
                                  ),
                                )),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String formatDate(String? date) {
    if (date == null) return "";
    final d = DateTime.tryParse(date);
    if (d == null) return date;
    return "${d.day}/${d.month}/${d.year}";
  }

  /// Bangun URL gambar dari path yang dikembalikan backend.
  /// DB lama: hanya filename (1234.jpg)
  /// DB baru: path relatif (uploads/events/1234.jpg atau /uploads/events/1234.jpg)
  ImageProvider getImage(String? image) {
    if (image == null || image.isEmpty) {
      return const AssetImage("assets/images/placeholder.jpg");
    }

    final base = ApiConfig.baseUrl;

    // Sudah URL penuh
    if (image.startsWith('http')) return NetworkImage(image);

    // Sudah ada leading slash → langsung concat
    if (image.startsWith('/uploads/')) return NetworkImage('$base$image');

    // Path relatif tanpa leading slash (uploads/events/...)
    if (image.startsWith('uploads/')) return NetworkImage('$base/$image');

    // Hanya filename — coba di folder events dulu
    return NetworkImage('$base/uploads/events/$image');
  }

  Widget ticketCard({
    required String title,
    required String type,
    required String date,
    required String location,
    String? image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              image: getImage(image),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(type,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(date),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.chevron_right, color: Colors.grey),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.qr_code, color: Color(0xFFE4572E)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget pastTicketCard({
    required String title,
    required String type,
    required String date,
    String? image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image(
              image: getImage(image),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              color: Colors.grey,
              colorBlendMode: BlendMode.saturation,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported,
                    color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                Text(type,
                    style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(date),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Used"),
          )
        ],
      ),
    );
  }
}