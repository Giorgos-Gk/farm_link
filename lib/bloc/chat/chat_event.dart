import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/message.dart';
import 'package:file_picker/file_picker.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class FetchChatListEvent extends ChatEvent {
  const FetchChatListEvent();

  @override
  String toString() => 'FetchChatListEvent';
}

class ReceivedChatsEvent extends ChatEvent {
  final List<Chat> chatList;

  const ReceivedChatsEvent(this.chatList);

  @override
  List<Object?> get props => [chatList];

  @override
  String toString() =>
      'ReceivedChatsEvent {chatList: ${chatList.length} chats}';
}

class FetchConversationDetailsEvent extends ChatEvent {
  final Chat chat;

  const FetchConversationDetailsEvent(this.chat);

  @override
  List<Object?> get props => [chat];

  @override
  String toString() => 'FetchConversationDetailsEvent {chat: ${chat.username}}';
}

class FetchMessagesEvent extends ChatEvent {
  final Chat chat;

  const FetchMessagesEvent(this.chat);

  @override
  List<Object?> get props => [chat];

  @override
  String toString() => 'FetchMessagesEvent {chat: ${chat.username}}';
}

class ReceivedMessagesEvent extends ChatEvent {
  final List<Message> messages;

  const ReceivedMessagesEvent(this.messages);

  @override
  List<Object?> get props => [messages];

  @override
  String toString() => 'ReceivedMessagesEvent {messages: ${messages.length}}';
}

class SendTextMessageEvent extends ChatEvent {
  final String message;

  const SendTextMessageEvent(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'SendTextMessageEvent {message: $message}';
}

class SendAttachmentEvent extends ChatEvent {
  final String chatId;
  final File file;
  final FileType fileType;

  const SendAttachmentEvent(this.chatId, this.file, this.fileType);

  @override
  List<Object?> get props => [chatId, file, fileType];

  @override
  String toString() =>
      'SendAttachmentEvent {chatId: $chatId, fileType: $fileType}';
}

class PageChangedEvent extends ChatEvent {
  final int index;
  final Chat activeChat;

  const PageChangedEvent(this.index, this.activeChat);

  @override
  List<Object?> get props => [index, activeChat];

  @override
  String toString() =>
      'PageChangedEvent {index: $index, activeChat: ${activeChat.username}}';
}
