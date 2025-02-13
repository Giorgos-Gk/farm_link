import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/config/Constants.dart';
import 'package:farm_link/utils/shared_objects.dart';

abstract class Message {
  final int timeStamp;
  final String senderName;
  final String senderUsername;
  final bool isSelf;
  String? documentId;

  Message(this.timeStamp, this.senderName, this.senderUsername)
      : isSelf = SharedObjects.prefs.getString(Constants.sessionUsername) ==
            senderUsername;

  factory Message.fromFireStore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final int type = data['type'];
    Message message;

    switch (type) {
      case 0:
        message = TextMessage.fromFirestore(doc);
        break;
      case 1:
        message = ImageMessage.fromFirestore(doc);
        break;
      case 2:
        message = VideoMessage.fromFirestore(doc);
        break;
      case 3:
        message = FileMessage.fromFirestore(doc);
        break;
      default:
        throw Exception('Unknown message type: $type');
    }
    message.documentId = doc.id;
    return message;
  }

  Map<String, dynamic> toMap();
}

class TextMessage extends Message {
  final String text;

  TextMessage(
      this.text, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory TextMessage.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TextMessage(
      data['text'],
      data['timeStamp'],
      data['senderName'],
      data['senderUsername'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 0,
    };
  }
}

class ImageMessage extends Message {
  final String imageUrl;

  ImageMessage(
      this.imageUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory ImageMessage.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ImageMessage(
      data['imageUrl'],
      data['timeStamp'],
      data['senderName'],
      data['senderUsername'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 1,
    };
  }
}

class VideoMessage extends Message {
  final String videoUrl;

  VideoMessage(
      this.videoUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory VideoMessage.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VideoMessage(
      data['videoUrl'],
      data['timeStamp'],
      data['senderName'],
      data['senderUsername'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 2,
    };
  }
}

class FileMessage extends Message {
  final String fileUrl;

  FileMessage(
      this.fileUrl, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory FileMessage.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FileMessage(
      data['fileUrl'],
      data['timeStamp'],
      data['senderName'],
      data['senderUsername'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'fileUrl': fileUrl,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 3,
    };
  }
}
