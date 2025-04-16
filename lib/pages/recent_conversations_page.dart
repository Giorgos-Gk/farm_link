import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/db_service.dart';
import '../services/navigation_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../pages/conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  RecentConversationsPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider.value(
        value: AuthProvider.instance,
        child: _conversationsListViewWidget(),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<List<ConversationSnippet>>(
          stream: DBService.instance.getUserConversations(auth.user!.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var _data = snapshot.data!;
            _data.removeWhere((_c) => _c.timestamp == null);
            return _data.isNotEmpty
                ? ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          NavigationService.instance.navigateToRoute(
                            MaterialPageRoute(
                              builder: (context) => ConversationPage(
                                conversationID: _data[index].conversationID,
                                receiverID: _data[index].id,
                                receiverName: _data[index].name,
                                receiverImage: _data[index].image,
                              ),
                            ),
                          );
                        },
                        title: Text(_data[index].name),
                        subtitle: Text(
                          _data[index].type == MessageType.Text
                              ? (_data[index].lastMessage)
                              : "Attachment: Image",
                        ),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _data[index].image.isNotEmpty
                                  ? NetworkImage(_data[index].image)
                                  : const AssetImage("assets/default_user.png")
                                      as ImageProvider,
                            ),
                          ),
                        ),
                        trailing:
                            _listTileTrailingWidgets(_data[index].timestamp),
                      );
                    },
                  )
                : const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Δεν υπαρχουν μηνυματα",
                      style: TextStyle(color: Colors.white30, fontSize: 15.0),
                    ),
                  );
          },
        );
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Text(
          "Τελευταίο μήνυμα",
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(lastMessageTimestamp.toDate()),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
