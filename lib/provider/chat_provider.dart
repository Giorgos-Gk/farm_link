import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/config/contacts.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/provider/base_provider.dart';
import 'package:farm_link/utils/shared_objects.dart';

class ChatProvider extends BaseChatProvider {
  final FirebaseFirestore fireStoreDb;

  ChatProvider({FirebaseFirestore? fireStoreDb})
      : fireStoreDb = fireStoreDb ?? FirebaseFirestore.instance;

  @override
  Stream<List<Chat>> getChats() {
    String uId = SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    return fireStoreDb
        .collection(Paths.usersPath)
        .doc(uId)
        .snapshots()
        .transform(
      StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
          List<Chat>>.fromHandlers(
        handleData: (DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
            EventSink<List<Chat>> sink) {
          mapDocumentToChat(documentSnapshot, sink);
        },
      ),
    );
  }

  void mapDocumentToChat(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot,
      EventSink<List<Chat>> sink) {
    List<Chat> chats = [];
    Map<String, dynamic>? data = documentSnapshot.data()?['chats'];
    if (data != null) {
      data.forEach(
          (key, value) => chats.add(Chat(chatId: value, username: key)));
      sink.add(chats);
    }
  }

  @override
  Future<List<Message>> getPreviousMessages(
      String chatId, Message prevMessage) async {
    CollectionReference messagesCollection = fireStoreDb
        .collection(Paths.chatsPath)
        .doc(chatId)
        .collection(Paths.messagesPath);
    DocumentSnapshot prevDocument =
        await messagesCollection.doc(prevMessage.documentId).get();
    QuerySnapshot querySnapshot = await messagesCollection
        .orderBy('timeStamp', descending: true)
        .startAfterDocument(prevDocument)
        .limit(20)
        .get();
    return querySnapshot.docs.map((doc) => Message.fromFireStore(doc)).toList();
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    CollectionReference messagesCollection = fireStoreDb
        .collection(Paths.chatsPath)
        .doc(chatId)
        .collection(Paths.messagesPath);
    return messagesCollection
        .orderBy('timeStamp', descending: true)
        .limit(20)
        .snapshots()
        .transform(StreamTransformer<QuerySnapshot<Map<String, dynamic>>,
                List<Message>>.fromHandlers(
            handleData: (QuerySnapshot<Map<String, dynamic>> querySnapshot,
                EventSink<List<Message>> sink) {
      mapDocumentToMessage(querySnapshot, sink);
    }));
  }

  void mapDocumentToMessage(QuerySnapshot<Map<String, dynamic>> querySnapshot,
      EventSink<List<Message>> sink) {
    List<Message> messages =
        querySnapshot.docs.map((doc) => Message.fromFireStore(doc)).toList();
    sink.add(messages);
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    DocumentReference chatDocRef =
        fireStoreDb.collection(Paths.chatsPath).doc(chatId);
    CollectionReference messagesCollection =
        chatDocRef.collection(Paths.messagesPath);
    await messagesCollection.add(message.toMap());
    await chatDocRef.update({'latestMessage': message.toMap()});
  }

  @override
  Future<String> getChatIdByUsername(String username) async {
    String uId = SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    String selfUsername =
        SharedObjects.prefs.getString(Constants.sessionUsername) ?? '';
    DocumentReference userRef =
        fireStoreDb.collection(Paths.usersPath).doc(uId);
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await userRef.get() as DocumentSnapshot<Map<String, dynamic>>;
    ;
    String? chatId = documentSnapshot.data()?['chats'][username];
    if (chatId == null) {
      chatId = await createChatIdForUsers(selfUsername, username);
      await userRef.update({
        'chats': {username: chatId}
      });
    }
    return chatId;
  }

  @override
  Future<void> createChatIdForContact(FarmLinkUser user) async {
    String contactUid = user.documentId;
    String contactUsername = user.username;
    String uId = SharedObjects.prefs.getString(Constants.sessionUid) ?? '';
    String selfUsername =
        SharedObjects.prefs.getString(Constants.sessionUsername) ?? '';
    DocumentReference userRef =
        fireStoreDb.collection(Paths.usersPath).doc(uId);
    DocumentReference contactRef =
        fireStoreDb.collection(Paths.usersPath).doc(contactUid);
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await userRef.get() as DocumentSnapshot<Map<String, dynamic>>;
    ;
    if (userSnapshot.data()?['chats']?[contactUsername] == null) {
      String chatId = await createChatIdForUsers(selfUsername, contactUsername);
      await userRef.set({
        'chats': {contactUsername: chatId}
      }, SetOptions(merge: true));
      await contactRef.set({
        'chats': {selfUsername: chatId}
      }, SetOptions(merge: true));
    }
  }

  Future<String> createChatIdForUsers(
      String selfUsername, String contactUsername) async {
    DocumentReference documentReference =
        await fireStoreDb.collection(Paths.chatsPath).add({
      'members': [selfUsername, contactUsername]
    });
    return documentReference.id;
  }

  @override
  void dispose() {}
}
