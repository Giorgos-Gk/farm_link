import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/models/message.dart';

class ConversationSnippet {
  final String id;
  final String conversationID;
  final String lastMessage;
  final String name;
  final String image;
  final MessageType type;
  final int unseenCount;
  final Timestamp timestamp;

  ConversationSnippet({
    required this.id,
    required this.conversationID,
    required this.lastMessage,
    required this.unseenCount,
    required this.timestamp,
    required this.name,
    required this.image,
    required this.type,
  });

  factory ConversationSnippet.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;

    MessageType messageType = MessageType.Text;
    if (data["type"] != null) {
      switch (data["type"]) {
        case "image":
          messageType = MessageType.Image;
          break;
        default:
          messageType = MessageType.Text;
      }
    }

    return ConversationSnippet(
      id: snapshot.id,
      conversationID: data["conversationID"] ?? "",
      lastMessage: data["lastMessage"] ?? "",
      unseenCount: data["unseenCount"] ?? 0,
      timestamp: data["timestamp"] ?? Timestamp.now(),
      name: data["name"] ?? "Unknown",
      image: data["image"] ?? "",
      type: messageType,
    );
  }
}

class Conversation {
  final String id;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversation({
    required this.id,
    required this.members,
    required this.ownerID,
    required this.messages,
  });

  factory Conversation.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;

    List<Message> messages = [];
    if (data["messages"] != null) {
      messages = List<Map<String, dynamic>>.from(data["messages"]).map((msg) {
        return Message(
          type: msg["type"] == "text" ? MessageType.Text : MessageType.Image,
          content: msg["message"],
          timestamp: msg["timestamp"],
          senderID: msg["senderID"],
        );
      }).toList();
    }

    return Conversation(
      id: snapshot.id,
      members: List<String>.from(data["members"] ?? []),
      ownerID: data["ownerID"] ?? "",
      messages: messages,
    );
  }
}
