import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:farm_link/models/message.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchMessagesEvent extends ChatEvent {
  final String chatId;

  const FetchMessagesEvent(this.chatId);

  @override
  List<Object?> get props => [chatId];

  @override
  String toString() => 'FetchMessagesEvent(chatId: $chatId)';
}

class ReceivedMessagesEvent extends ChatEvent {
  final List<Message> messages;

  const ReceivedMessagesEvent(this.messages);

  @override
  List<Object?> get props => [messages];

  @override
  String toString() => 'ReceivedMessagesEvent(messages: $messages)';
}

class SendTextMessageEvent extends ChatEvent {
  final String chatId;
  final Message message;

  const SendTextMessageEvent(this.chatId, this.message);

  @override
  List<Object?> get props => [chatId, message];

  @override
  String toString() =>
      'SendTextMessageEvent(chatId: $chatId, message: $message)';
}

class PickedAttachmentEvent extends ChatEvent {
  final String chatId;
  final File file;
  final FileType fileType;

  const PickedAttachmentEvent(this.chatId, this.file, this.fileType);

  @override
  List<Object?> get props => [chatId, file, fileType];

  @override
  String toString() =>
      'PickedAttachmentEvent(chatId: $chatId, file: ${file.path}, fileType: $fileType)';
}
