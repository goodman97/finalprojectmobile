import 'package:flutter/material.dart';
import 'package:finalproject/services/chat_service.dart';

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() =>
      _ChatBotPageState();
}

class _ChatBotPageState
    extends State<ChatBotPage> {
  final TextEditingController
      messageController =
      TextEditingController();
      bool isLoading = false;

  List<Map<String, dynamic>> messages =
      [
    {
      "text":
          "Halo! Saya Gelatix Assistant. Ada yang bisa saya bantu terkait event, tiket, voucher, atau akun?",
      "isUser": false,
    }
  ];

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty ||
        isLoading) {
      return;
    }

    final userMessage =
        messageController.text.trim();

    setState(() {
      messages.add({
        "text": userMessage,
        "isUser": true,
      });

      isLoading = true;
    });

    messageController.clear();

    try {
      final botReply =
          await ChatService.sendMessage(
        userMessage,
      );

      setState(() {
        messages.add({
          "text": botReply,
          "isUser": false,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "text":
              "Bot sedang error.",
          "isUser": false,
        });
      });
    }

    setState(() {
      isLoading = false;
    });
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
          "Gelatix Assistant",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.all(
                      16),
              itemCount:
                  messages.length,
              itemBuilder:
                  (context, index) {
                final msg =
                    messages[index];

                return Align(
                  alignment:
                      msg["isUser"]
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.only(
                            bottom:
                                12),
                    padding:
                        const EdgeInsets
                            .all(14),
                    decoration:
                        BoxDecoration(
                      color: msg["isUser"]
                          ? const Color(
                              0xFFE4572E)
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              16),
                    ),
                    child: Text(
                      msg["text"],
                      style:
                          TextStyle(
                        color: msg[
                                "isUser"]
                            ? Colors
                                .white
                            : Colors
                                .black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding:
                const EdgeInsets.all(
                    16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        messageController,
                    decoration:
                        InputDecoration(
                      hintText:
                          "Type message...",
                      filled: true,
                      fillColor:
                          const Color(
                              0xFFF5F1E8),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                                20),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    width: 10),
                CircleAvatar(
                  backgroundColor:
                      const Color(
                          0xFFE4572E),
                  child: IconButton(
                    onPressed:
                        isLoading ? null : sendMessage,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}