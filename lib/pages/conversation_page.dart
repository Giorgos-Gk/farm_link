import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/widgets/chat_app_bar.dart';
import 'package:farm_link/widgets/chat_list_widget.dart';
import 'package:flutter/material.dart';

class ConversationPage extends StatefulWidget {
  @override
  _ConversationPageState createState() => _ConversationPageState();

  const ConversationPage();
}

class _ConversationPageState extends State<ConversationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            key: _scaffoldKey,
            appBar: ChatAppBar(),
            body: Container(
                color: Palette.chatBackgroundColor,
                child: Stack(children: <Widget>[
                  Column(
                    children: <Widget>[
                      ChatListWidget(),
                    ],
                  ),
                ]))));
  }
}
