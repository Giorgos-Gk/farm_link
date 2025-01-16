import 'package:farm_link/bloc/chat/chat_bloc.dart';
import 'package:farm_link/bloc/chat/chat_state.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/widgets/chat_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({Key? key}) : super(key: key);

  @override
  _ChatListWidgetState createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  final ScrollController listScrollController = ScrollController();
  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is FetchedMessagesState) {
          messages = state.messages;
        }

        // Debugging output for state
        debugPrint('ChatListWidget state: $state');
        debugPrint('Messages: ${messages.length}');

        if (messages.isEmpty) {
          return const Center(
            child: Text(
              'Δεν υπάρχουν μηνύματα.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemBuilder: (context, index) =>
              ChatItemWidget(messages[index] as int),
          itemCount: messages.length,
          reverse: true,
          controller: listScrollController,
        );
      },
    );
  }
}
