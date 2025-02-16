import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DBService {
  static final DBService instance = DBService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String _userCollection = "Users";
  final String _conversationsCollection = "Conversations";

  Future<void> createUserInDB(
      String uid, String name, String email, String imageURL) async {
    try {
      return await _db.collection(_userCollection).doc(uid).set({
        "name": name,
        "email": email,
        "image": imageURL,
        "lastSeen": DateTime.now().toUtc(),
      });
    } catch (e) {
      print("Error creating user in DB: $e");
    }
  }

  Future<void> updateUserLastSeenTime(String userID) async {
    try {
      var ref = _db.collection(_userCollection).doc(userID);
      return await ref.update({"lastSeen": Timestamp.now()});
    } catch (e) {
      print("Error updating last seen time: $e");
    }
  }

  Future<void> sendMessage(String conversationID, Message message) async {
    try {
      var ref = _db.collection(_conversationsCollection).doc(conversationID);
      String messageType = message.type == MessageType.Text ? "text" : "image";

      return await ref.update({
        "messages": FieldValue.arrayUnion([
          {
            "message": message.content,
            "senderID": message.senderID,
            "timestamp": message.timestamp,
            "type": messageType,
          },
        ]),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> createOrGetConversation(
      String currentID, String recipientID, Function(String) onSuccess) async {
    try {
      var currentUserConvRef = _db
          .collection(_userCollection)
          .doc(currentID)
          .collection(_conversationsCollection);
      var conversationDoc = await currentUserConvRef.doc(recipientID).get();

      if (conversationDoc.exists) {
        String convID =
            conversationDoc.data()?["conversationID"] ?? conversationDoc.id;
        return onSuccess(convID);
      } else {
        // Δημιουργία συνομιλίας στην κύρια συλλογή
        var conversationRef = _db.collection(_conversationsCollection).doc();
        await conversationRef.set({
          "members": [currentID, recipientID],
          "ownerID": currentID,
          "messages": [],
          "conversationID": conversationRef.id,
        });

        // Ανάκτηση στοιχείων παραλήπτη
        var recipientSnapshot =
            await _db.collection(_userCollection).doc(recipientID).get();
        var recipientData = recipientSnapshot.data() ?? {};

        // Ανάκτηση στοιχείων αποστολέα
        var senderSnapshot =
            await _db.collection(_userCollection).doc(currentID).get();
        var senderData = senderSnapshot.data() ?? {};

        // Δημιουργία pointer για τον αποστολέα
        await currentUserConvRef.doc(recipientID).set({
          "conversationID": conversationRef.id,
          "name": recipientData["name"] ?? "Unknown",
          "image": recipientData["image"] ?? "",
          "lastMessage": "",
          "timestamp": FieldValue.serverTimestamp(),
        });

        // Δημιουργία pointer για τον παραλήπτη
        var recipientConvRef = _db
            .collection(_userCollection)
            .doc(recipientID)
            .collection(_conversationsCollection);
        await recipientConvRef.doc(currentID).set({
          "conversationID": conversationRef.id,
          "name": senderData["name"] ?? "Unknown",
          "image": senderData["image"] ?? "",
          "lastMessage": "",
          "timestamp": FieldValue.serverTimestamp(),
        });

        return onSuccess(conversationRef.id);
      }
    } catch (e) {
      print("Error creating/getting conversation: $e");
    }
  }

  Stream<Contact> getUserData(String userID) {
    var ref = _db.collection(_userCollection).doc(userID);
    return ref.snapshots().map((snapshot) {
      return Contact.fromFirestore(snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String userID) {
    var ref = _db
        .collection(_userCollection)
        .doc(userID)
        .collection(_conversationsCollection);
    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConversationSnippet.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String searchName) {
    var ref = _db
        .collection(_userCollection)
        .where("name", isGreaterThanOrEqualTo: searchName)
        .where("name", isLessThan: searchName + 'z');

    return ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromFirestore(doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String conversationID) {
    var ref = _db.collection(_conversationsCollection).doc(conversationID);
    return ref.snapshots().map((doc) {
      return Conversation.fromFirestore(doc);
    });
  }
}
