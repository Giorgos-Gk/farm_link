import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Text,
  Image,
}

class Message {
  final String senderID;
  final String content;
  final Timestamp timestamp;
  final MessageType type;

  Message({
    required this.senderID,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      "senderID": senderID,
      "content": content,
      "timestamp": timestamp,
      "type": type == MessageType.Text ? "text" : "image",
    };
  }

  factory Message.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data()!;
    return Message(
      senderID: data["senderID"] ?? "",
      content: data["content"] ?? "",
      timestamp: data["timestamp"] ?? Timestamp.now(),
      type: data["type"] == "text" ? MessageType.Text : MessageType.Image,
    );
  }
}
