import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/provider/base_provider.dart';

class ChatProvider extends BaseChatProvider {
  final FirebaseFirestore fireStoreDb;

  ChatProvider({FirebaseFirestore? fireStoreDb})
      : fireStoreDb = fireStoreDb ?? FirebaseFirestore.instance;

  @override
  Stream<List<Chat>> getChats() {
    // TODO: Υλοποιήστε το getChats
    return Stream.empty();
  }

  @override
  void dispose() {}

  @override
  Stream<List<Message>> getMessages(String chatId) {
    DocumentReference chatDocRef =
        fireStoreDb.collection(Paths.chatsPath).doc(chatId);
    CollectionReference messagesCollection =
        chatDocRef.collection(Paths.messagesPath);

    return messagesCollection.snapshots().transform(
          StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
              List<Message>>.fromHandlers(
            handleData: (querySnapshot, sink) =>
                _mapDocumentsToMessages(querySnapshot, sink),
          ),
        );
  }

  void _mapDocumentsToMessages(
      QuerySnapshot<Map<String, dynamic>> querySnapshot,
      EventSink<List<Message>> sink) {
    List<Message> messages = querySnapshot.docs.map((doc) {
      return Message.fromFireStore(doc);
    }).toList();
    sink.add(messages);
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    DocumentReference chatDocRef =
        fireStoreDb.collection(Paths.chatsPath).doc(chatId);
    CollectionReference messagesCollection =
        chatDocRef.collection(Paths.messagesPath);
    await messagesCollection.add(message.toMap());
  }
}
