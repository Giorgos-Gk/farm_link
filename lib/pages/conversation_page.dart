import 'package:farm_link/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final String conversationID;
  final String receiverID;
  final String receiverImage;
  final String receiverName;

  const ConversationPage({
    required this.conversationID,
    required this.receiverID,
    required this.receiverName,
    required this.receiverImage,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _listViewController = ScrollController();
  late AuthProvider _auth;
  String _messageText = "";

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1.0),
        title: Text(widget.receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        _auth = auth;
        return Stack(
          children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (context, snapshot) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_listViewController.hasClients) {
              _listViewController
                  .jumpTo(_listViewController.position.maxScrollExtent);
            }
          });

          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          }

          var conversationData = snapshot.data!;
          if (conversationData.messages.isEmpty) {
            return const Center(
              child: Text("Ας ξεκιμησουμε μια συζητηση!"),
            );
          }

          return ListView.builder(
            controller: _listViewController,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: conversationData.messages.length,
            itemBuilder: (context, index) {
              var message = conversationData.messages[index];
              bool isOwnMessage = message.senderID == _auth.user?.uid;
              return _messageListViewChild(isOwnMessage, message);
            },
          );
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwnMessage, Message message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!isOwnMessage) _userImageWidget(),
          SizedBox(width: _deviceWidth * 0.02),
          message.type == MessageType.Text
              ? _textMessageBubble(
                  isOwnMessage, message.content, message.timestamp)
              : _imageMessageBubble(
                  isOwnMessage, message.content, message.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double imageRadius = _deviceHeight * 0.05;
    return Container(
      height: imageRadius,
      width: imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(
      bool isOwnMessage, String message, Timestamp timestamp) {
    List<Color> colorScheme = isOwnMessage
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(69, 69, 69, 1),
            const Color.fromRGBO(43, 43, 43, 1)
          ];

    return Container(
      width: _deviceWidth * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: colorScheme),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(message),
          Text(
            timeago.format(timestamp.toDate()),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool isOwnMessage, String imageURL, Timestamp timestamp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Image.network(imageURL,
            width: _deviceWidth * 0.40, height: _deviceHeight * 0.30),
        Text(
          timeago.format(timestamp.toDate()),
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _messageField() {
    return Container(
      height: _deviceHeight * 0.08,
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return Expanded(
      child: TextFormField(
        validator: (input) => input!.isEmpty ? "Please enter a message" : null,
        onSaved: (input) => setState(() => _messageText = input!),
        cursorColor: Colors.white,
        decoration: const InputDecoration(
            border: InputBorder.none, hintText: "Type a message"),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton() {
    return IconButton(
      icon: const Icon(Icons.send, color: Colors.white),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          DBService.instance.sendMessage(
            widget.conversationID,
            Message(
              content: _messageText,
              timestamp: Timestamp.now(),
              senderID: _auth.user!.uid, // Χρήση του ! για non-null uid
              type: MessageType.Text,
            ),
          );
          _formKey.currentState!.reset();
          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget _imageMessageButton() {
    return IconButton(
      icon: const Icon(Icons.camera_alt),
      onPressed: () async {
        var image = await MediaService.instance.getImageFromLibrary();
        if (image != null) {
          var imageURL = await CloudStorageService.instance
              .uploadMediaMessage(_auth.user!.uid, image);
          await DBService.instance.sendMessage(
            widget.conversationID,
            Message(
              content: imageURL!,
              senderID: _auth.user!.uid,
              timestamp: Timestamp.now(),
              type: MessageType.Image,
            ),
          );
        }
      },
    );
  }
}
