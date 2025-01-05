import 'package:equatable/equatable.dart';
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

class FetchedMessagesState extends ChatState {
  final List<Message> messages;

  const FetchedMessagesState(this.messages);

  @override
  List<Object?> get props => [messages];

  @override
  String toString() => 'FetchedMessagesState(messages: $messages)';
}

class ErrorState extends ChatState {
  final Exception exception;

  const ErrorState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'ErrorState(exception: $exception)';
}
