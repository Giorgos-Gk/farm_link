import 'package:farm_link/services/cloud_storage_service.dart';
import 'package:farm_link/services/media_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/db_service.dart';
import 'package:farm_link/provider/auth_provider.dart';

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
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  late double _deviceHeight, _deviceWidth;
  final _listViewController = ScrollController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthProvider _auth;
  String _messageText = "";

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('el', timeago.GrMessages());
    timeago.setDefaultLocale('el');
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
        title: Text(widget.receiverName),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            _auth = auth;
            return Stack(
              children: [
                _messageListView(),
                Align(
                    alignment: Alignment.bottomCenter, child: _messageField()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _messageListView() {
    return SizedBox(
      height: _deviceHeight * .75,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(widget.conversationID),
        builder: (ctx, snap) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_listViewController.hasClients) {
              _listViewController.jumpTo(
                _listViewController.position.maxScrollExtent,
              );
            }
          });
          if (!snap.hasData) {
            return const Center(
              child: SpinKitWanderingCubes(color: Colors.blue, size: 50),
            );
          }
          final conv = snap.data!;
          if (conv.messages.isEmpty) {
            return const Center(child: Text("Ας ξεκινήσουμε μια συζήτηση!"));
          }
          return ListView.builder(
            controller: _listViewController,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            itemCount: conv.messages.length,
            itemBuilder: (ctx, i) {
              final msg = conv.messages[i];
              final isOwn = msg.senderID == _auth.user?.uid;
              return _messageListViewChild(isOwn, msg);
            },
          );
        },
      ),
    );
  }

  Widget _messageListViewChild(bool isOwn, Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn) _userImageWidget(),
          SizedBox(width: _deviceWidth * .02),
          msg.type == MessageType.Text
              ? _textMessageBubble(isOwn, msg.content, msg.timestamp)
              : _imageMessageBubble(isOwn, msg.content, msg.timestamp),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    final size = _deviceHeight * .05;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.receiverImage),
        ),
      ),
    );
  }

  Widget _textMessageBubble(bool isOwn, String text, Timestamp ts) {
    final colors = isOwn
        ? [Colors.blue, const Color.fromRGBO(42, 117, 188, 1)]
        : [
            const Color.fromRGBO(69, 69, 69, 1),
            const Color.fromRGBO(43, 43, 43, 1)
          ];
    return Container(
      width: _deviceWidth * .75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          const SizedBox(height: 4),
          Text(
            timeago.format(ts.toDate(), locale: 'el'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(bool isOwn, String url, Timestamp ts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImagePreviewPage(imageUrl: url),
              ),
            );
          },
          child: Image.network(
            url,
            width: _deviceWidth * .4,
            height: _deviceHeight * .3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          timeago.format(ts.toDate(), locale: 'el'),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _messageField() {
    return Container(
      height: _deviceHeight * .08,
      margin: EdgeInsets.symmetric(
        horizontal: _deviceWidth * .04,
        vertical: _deviceHeight * .03,
      ),
      child: Form(
        key: _formKey,
        child: Row(children: [
          Expanded(
            child: TextFormField(
              validator: (v) =>
                  v!.isEmpty ? "Παρακαλώ γράψτε ένα μήνυμα" : null,
              onSaved: (v) => setState(() => _messageText = v!),
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: "Γράψτε εδώ..."),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                DBService.instance.sendMessage(
                  widget.conversationID,
                  Message(
                    content: _messageText,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user!.uid,
                    type: MessageType.Text,
                  ),
                );
                _formKey.currentState!.reset();
                FocusScope.of(context).unfocus();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              final img = await MediaService.instance.getImageFromLibrary();
              if (img != null) {
                final url = await CloudStorageService.instance
                    .uploadMediaMessage(_auth.user!.uid, img);
                await DBService.instance.sendMessage(
                  widget.conversationID,
                  Message(
                    content: url!,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user!.uid,
                    type: MessageType.Image,
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  const ImagePreviewPage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
