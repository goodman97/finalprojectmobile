import 'package:flutter/material.dart';
import 'package:finalproject/services/eo_event_service.dart';

class ManageTicketTypesPage extends StatefulWidget {
  final String eventId;

  const ManageTicketTypesPage({
    super.key,
    required this.eventId,
  });

  @override
  State<ManageTicketTypesPage> createState() =>
      _ManageTicketTypesPageState();
}

class _ManageTicketTypesPageState
    extends State<ManageTicketTypesPage> {

  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController quotaController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTickets();
  }

  Future<void> loadTickets() async {
    try {
      final result =
          await EoEventService.getTicketTypes(
        widget.eventId,
      );

      setState(() {
        tickets =
            List<Map<String, dynamic>>.from(
          result,
        );
        isLoading = false;
      });
    } catch (e) {
      print("LOAD TICKET ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTicketType() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        quotaController.text.isEmpty) {
      return;
    }

    try {
      await EoEventService.createTicketType(
        eventId: widget.eventId,
        name: nameController.text,
        price: priceController.text,
        quota: quotaController.text,
      );

      nameController.clear();
      priceController.clear();
      quotaController.clear();

      Navigator.pop(context);

      loadTickets();
    } catch (e) {
      print("ADD TICKET ERROR: $e");
    }
  }

  void showEditDialog(
    Map<String, dynamic> ticket,
  ) {
    nameController.text =
        ticket["name"].toString();

    priceController.text =
        ticket["price"].toString();

    quotaController.text =
        ticket["quota"].toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        backgroundColor:
            Colors.white,
        title: const Text(
          "Edit Ticket Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3E2F),
          ),
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  InputDecoration(
                hintText:
                    "Ticket name",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                hintText: "Price",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  quotaController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                hintText: "Quota",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(
                        context);
                  },
                  style:
                      OutlinedButton
                          .styleFrom(
                    side:
                        const BorderSide(
                      color: Color(
                          0xFFE4572E),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(
                          0xFFE4572E),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await EoEventService
                          .updateTicketType(
                        ticketTypeId:
                            ticket["id"],
                        name:
                            nameController
                                .text,
                        price:
                            priceController
                                .text,
                        quota:
                            quotaController
                                .text,
                      );

                      Navigator.pop(
                          context);

                      loadTickets();
                    } catch (e) {
                      print(e);
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
                              16),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(24),
        ),
        title: const Text(
          "Add Ticket Type",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F3E2F),
          ),
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  InputDecoration(
                hintText:
                    "Ticket name",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                hintText: "Price",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller:
                  quotaController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  InputDecoration(
                hintText: "Quota",
                filled: true,
                fillColor:
                    const Color(
                        0xFFF5F1E8),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          16),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed:
                addTicketType,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(
                      0xFFE4572E),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
            ),
            child: const Text(
              "Save",
              style: TextStyle(
                color:
                    Colors.white,
              ),
            ),
          )
        ],
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
            const Color(0xFFF5F1E8),
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color:
              Color(0xFF2F3E2F),
        ),
        title: const Text(
          "Ticket Types",
          style: TextStyle(
            color:
                Color(0xFF2F3E2F),
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding:
                const EdgeInsets.only(
                    right: 16),
            child:
                ElevatedButton(
              onPressed:
                  showAddDialog,
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
              child:
                  const Text(
                "+ Add Ticket Type",
                style:
                    TextStyle(
                  color:
                      Colors.white,
                ),
              ),
            ),
          )
        ],
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : tickets.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada ticket type",
                    style:
                        TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(16),
                  itemCount:
                      tickets.length,
                  itemBuilder:
                      (_, index) {
                    final t =
                        tickets[index];

                    final quota =
                        int.tryParse(
                              t["quota"]
                                  .toString(),
                            ) ??
                            0;

                    final available =
                        int.tryParse(
                              t["available"]
                                      ?.toString() ??
                                  quota
                                      .toString(),
                            ) ??
                            quota;

                    final sold =
                        quota -
                            available;

                    final progress =
                        quota == 0
                            ? 0.0
                            : sold /
                                quota;

                    return Container(
                      margin:
                          const EdgeInsets.only(
                              bottom:
                                  16),
                      padding:
                          const EdgeInsets
                              .all(20),
                      decoration:
                          BoxDecoration(
                        color: Colors
                            .white,
                        borderRadius:
                            BorderRadius.circular(
                                22),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors
                                .black12,
                            blurRadius:
                                6,
                          )
                        ],
                      ),
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:
                                    Text(
                                  t["name"],
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Color(0xFF2F3E2F),
                                  ),
                                ),
                              ),
                              Text(
                                "$sold/$quota",
                                style:
                                    const TextStyle(
                                  fontSize:
                                      26,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF2F3E2F),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(
                              height:
                                  8),

                          Text(
                            "Rp ${t["price"]}",
                            style:
                                const TextStyle(
                              color: Color(
                                  0xFFE4572E),
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(
                              height:
                                  14),

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    10),
                            child:
                                LinearProgressIndicator(
                              value:
                                  progress,
                              minHeight:
                                  8,
                              backgroundColor:
                                  Colors.grey.shade300,
                              valueColor:
                                  const AlwaysStoppedAnimation(
                                Color(
                                    0xFFE4572E),
                              ),
                            ),
                          ),

                          const SizedBox(
                              height:
                                  14),

                          Row(
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 18,
                                color: Colors.grey,
                              ),

                              const SizedBox(width: 6),

                              Text(
                                "$available available",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const Spacer(),

                              GestureDetector(
                                onTap: () {
                                  showEditDialog(t);
                                },
                                child: const Text(
                                  "Manage →",
                                  style: TextStyle(
                                    color: Color(0xFFE4572E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}