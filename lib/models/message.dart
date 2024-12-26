import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_link/config/constants.dart';
import 'package:farm_link/utils/shared_objects.dart';

abstract class Message {
  int timeStamp;
  String senderName;
  String senderUsername;
  late bool isSelf;
  late String documentId;

  Message(this.timeStamp, this.senderName, this.senderUsername);

  factory Message.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final int type = data['type'] ?? -1;
    late Message message;

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
        throw UnsupportedError("Unsupported message type: $type");
    }

    message.isSelf = SharedObjects.prefs.getString(Constants.sessionUsername) ==
        message.senderUsername;
    message.documentId = doc.id;
    return message;
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    final int type = map['type'] ?? -1;
    late Message message;

    switch (type) {
      case 0:
        message = TextMessage.fromMap(map);
        break;
      case 1:
        message = ImageMessage.fromMap(map);
        break;
      case 2:
        message = VideoMessage.fromMap(map);
        break;
      case 3:
        message = FileMessage.fromMap(map);
        break;
      default:
        throw UnsupportedError("Unsupported message type: $type");
    }

    message.isSelf = SharedObjects.prefs.getString(Constants.sessionUsername) ==
        message.senderUsername;
    return message;
  }

  Map<String, dynamic> toMap();
}

class TextMessage extends Message {
  String text;

  TextMessage(
      this.text, int timeStamp, String senderName, String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory TextMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TextMessage.fromMap(data);
  }

  factory TextMessage.fromMap(Map<String, dynamic> data) {
    return TextMessage(
      data['text'] ?? '',
      data['timeStamp'] ?? 0,
      data['senderName'] ?? '',
      data['senderUsername'] ?? '',
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

  @override
  String toString() =>
      '{ senderName: $senderName, senderUsername: $senderUsername, isSelf: $isSelf, timeStamp: $timeStamp, type: 0, text: $text }';
}

class ImageMessage extends Message {
  String imageUrl;
  String fileName;

  ImageMessage(this.imageUrl, this.fileName, int timeStamp, String senderName,
      String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory ImageMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ImageMessage.fromMap(data);
  }

  factory ImageMessage.fromMap(Map<String, dynamic> data) {
    return ImageMessage(
      data['imageUrl'] ?? '',
      data['fileName'] ?? '',
      data['timeStamp'] ?? 0,
      data['senderName'] ?? '',
      data['senderUsername'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'fileName': fileName,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 1,
    };
  }

  @override
  String toString() =>
      '{ senderName: $senderName, senderUsername: $senderUsername, isSelf: $isSelf, timeStamp: $timeStamp, type: 1, fileName: $fileName, imageUrl: $imageUrl }';
}

class VideoMessage extends Message {
  String videoUrl;
  String fileName;

  VideoMessage(this.videoUrl, this.fileName, int timeStamp, String senderName,
      String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory VideoMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoMessage.fromMap(data);
  }

  factory VideoMessage.fromMap(Map<String, dynamic> data) {
    return VideoMessage(
      data['videoUrl'] ?? '',
      data['fileName'] ?? '',
      data['timeStamp'] ?? 0,
      data['senderName'] ?? '',
      data['senderUsername'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'videoUrl': videoUrl,
      'fileName': fileName,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 2,
    };
  }

  @override
  String toString() =>
      '{ senderName: $senderName, senderUsername: $senderUsername, isSelf: $isSelf, timeStamp: $timeStamp, type: 2, fileName: $fileName, videoUrl: $videoUrl }';
}

class FileMessage extends Message {
  String fileUrl;
  String fileName;

  FileMessage(this.fileUrl, this.fileName, int timeStamp, String senderName,
      String senderUsername)
      : super(timeStamp, senderName, senderUsername);

  factory FileMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FileMessage.fromMap(data);
  }

  factory FileMessage.fromMap(Map<String, dynamic> data) {
    return FileMessage(
      data['fileUrl'] ?? '',
      data['fileName'] ?? '',
      data['timeStamp'] ?? 0,
      data['senderName'] ?? '',
      data['senderUsername'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'fileUrl': fileUrl,
      'fileName': fileName,
      'timeStamp': timeStamp,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'type': 3,
    };
  }

  @override
  String toString() =>
      '{ senderName: $senderName, senderUsername: $senderUsername, isSelf: $isSelf, timeStamp: $timeStamp, type: 3, fileName: $fileName, fileUrl: $fileUrl }';
}
