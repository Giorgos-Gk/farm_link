import 'package:cloud_firestore/cloud_firestore.dart';

abstract class Message {
  final int timeStamp;
  final String senderName;
  final String senderUsername;

  Message(this.timeStamp, this.senderName, this.senderUsername);

  factory Message.fromFireStore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final int type = data['type'] as int;
    switch (type) {
      case 0:
        return TextMessage.fromFirestore(doc);
      case 1:
        return ImageMessage.fromFirestore(doc);
      case 2:
        return VideoMessage.fromFirestore(doc);
      case 3:
        return FileMessage.fromFirestore(doc);
      default:
        throw ArgumentError('Invalid message type: $type');
    }
  }

  Map<String, dynamic> toMap();
}

class TextMessage extends Message {
  final String text;

  TextMessage(
      this.text, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory TextMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TextMessage(
      data['text'] as String,
      data['timeStamp'] as int,
      data['senderName'] as String,
      data['senderUsername'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 0,
        'text': text,
        'timeStamp': timeStamp,
        'senderName': senderName,
        'senderUsername': senderUsername,
      };
}

class ImageMessage extends Message {
  final String imageUrl;

  ImageMessage(
      this.imageUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory ImageMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ImageMessage(
      data['imageUrl'] as String,
      data['timeStamp'] as int,
      data['senderName'] as String,
      data['senderUsername'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 1,
        'imageUrl': imageUrl,
        'timeStamp': timeStamp,
        'senderName': senderName,
        'senderUsername': senderUsername,
      };
}

class VideoMessage extends Message {
  final String videoUrl;

  VideoMessage(
      this.videoUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory VideoMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VideoMessage(
      data['videoUrl'] as String,
      data['timeStamp'] as int,
      data['senderName'] as String,
      data['senderUsername'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 2,
        'videoUrl': videoUrl,
        'timeStamp': timeStamp,
        'senderName': senderName,
        'senderUsername': senderUsername,
      };
}

class FileMessage extends Message {
  final String fileUrl;

  FileMessage(
      this.fileUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory FileMessage.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FileMessage(
      data['fileUrl'] as String,
      data['timeStamp'] as int,
      data['senderName'] as String,
      data['senderUsername'] as String,
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        'type': 3,
        'fileUrl': fileUrl,
        'timeStamp': timeStamp,
        'senderName': senderName,
        'senderUsername': senderUsername,
      };
}
