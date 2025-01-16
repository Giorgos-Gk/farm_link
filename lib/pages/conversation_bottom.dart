import 'package:farm_link/config/Styles.dart';
import 'package:farm_link/config/pallete.dart';
import 'package:farm_link/widgets/chat_row_widget.dart';
import 'package:farm_link/widgets/navigator_pill_widget.dart';
import 'package:flutter/material.dart';

class ConversationBottom extends StatefulWidget {
  @override
  _ConversationBottomState createState() => _ConversationBottomState();

  const ConversationBottom();
}

class _ConversationBottomState extends State<ConversationBottom> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: ListView(children: <Widget>[
              NavigationPillWidget(),
              Center(child: Text('Messages', style: Styles.textHeading)),
              SizedBox(
                height: 20,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(left: 75, right: 20),
                    child: Divider(
                      color: Palette.accentColor,
                    )),
                itemBuilder: (context, index) {
                  return ChatRowWidget();
                },
              )
            ])));
  }
}
