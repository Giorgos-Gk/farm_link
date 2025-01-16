import 'package:farm_link/bloc/chat/chat_bloc.dart';
import 'package:farm_link/bloc/chat/chat_event.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/widgets/chat_app_bar.dart';
import 'package:farm_link/widgets/chat_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationPage extends StatefulWidget {
  final Chat chat;

  const ConversationPage(this.chat, {Key? key}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late ChatBloc chatBloc;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatBloc = BlocProvider.of<ChatBloc>(context);
    chatBloc.add(FetchConversationDetailsEvent(widget.chat));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Palette.chatBackgroundColor,
              child: ChatListWidget(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 3.0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Πληκτρολογήστε μήνυμα...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Palette.primaryColor),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      chatBloc
                          .add(SendTextMessageEvent(_messageController.text));
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
