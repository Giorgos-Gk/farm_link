import 'package:equatable/equatable.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/models/message.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class InitialChatState extends ChatState {
  const InitialChatState();

  @override
  String toString() => 'InitialChatState';
}

class FetchedChatListState extends ChatState {
  final List<Chat> chatList;

  const FetchedChatListState(this.chatList);

  @override
  List<Object?> get props => [chatList];

  @override
  String toString() =>
      'FetchedChatListState {chatList: ${chatList.length} chats}';
}

class FetchedMessagesState extends ChatState {
  final List<Message> messages;

  const FetchedMessagesState(this.messages);

  @override
  List<Object?> get props => [messages];

  @override
  String toString() => 'FetchedMessagesState {messages: ${messages.length}}';
}

class ErrorState extends ChatState {
  final Exception exception;

  const ErrorState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'ErrorState {exception: $exception}';
}

class FetchedContactDetailsState extends ChatState {
  final FarmLinkUser user;

  const FetchedContactDetailsState(this.user);

  @override
  List<Object?> get props => [user];

  @override
  String toString() => 'FetchedContactDetailsState {user: ${user.username}}';
}

class PageChangedState extends ChatState {
  final int index;
  final Chat activeChat;

  const PageChangedState(this.index, this.activeChat);

  @override
  List<Object?> get props => [index, activeChat];

  @override
  String toString() =>
      'PageChangedState {index: $index, activeChat: ${activeChat.username}}';
}
