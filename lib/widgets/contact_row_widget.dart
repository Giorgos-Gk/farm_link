import 'package:farm_link/models/contact.dart';
import 'package:flutter/material.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/pages/conversation_page.dart';

class ContactRowWidget extends StatelessWidget {
  final Contact contact;

  const ContactRowWidget({
    Key? key,
    required this.contact,
    required String username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final chat = Chat(username: contact.username, chatId: "temp_chat_id");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(chat),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: contact.photoUrl != null
                  ? NetworkImage(contact.photoUrl!)
                  : const AssetImage('assets/user.png') as ImageProvider,
            ),
            const SizedBox(width: 16),
            Text(
              contact.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
