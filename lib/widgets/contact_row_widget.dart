import 'package:farm_link/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/pages/conversation_page.dart';

class ContactRowWidget extends StatelessWidget {
  final String username;

  const ContactRowWidget({
    Key? key,
    required Contact contact,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Δημιουργία ενός Chat αντικειμένου με προσωρινό chatId
        final chat = Chat(username: username, chatId: "temp_chat_id");

        // Πλοήγηση στη σελίδα συνομιλίας
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(chat),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          username,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
