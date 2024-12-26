import 'package:farm_link/pages/conversation_page.dart';
import 'package:farm_link/widgets/input_widget.dart';
import 'package:flutter/material.dart';
import '../widgets/conversation_bottom.dart';

class ConversationPageSlide extends StatefulWidget {
  @override
  _ConversationPageSlideState createState() => _ConversationPageSlideState();

  const ConversationPageSlide();
}

class _ConversationPageSlideState extends State<ConversationPageSlide> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                children: <Widget>[
                  ConversationPage(),
                  ConversationPage(),
                  ConversationPage(),
                ],
              ),
            ),
            Container(
              child: GestureDetector(
                child: InputWidget(),
                onPanUpdate: (details) {
                  if (details.delta.dy < 0) {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return ConversationBottom();
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
