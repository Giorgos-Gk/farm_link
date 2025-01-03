import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ContactsEvent extends Equatable {
  const ContactsEvent(); // Κενός constructor

  @override
  List<Object?> get props => [];
}

class FetchContactsEvent extends ContactsEvent {
  const FetchContactsEvent();

  @override
  String toString() => 'FetchContactsEvent';
}

class AddContactsEvent extends ContactsEvent {
  final String username;

  const AddContactsEvent({required this.username});

  @override
  List<Object?> get props => [username];

  @override
  String toString() => 'AddContactsEvent { username: $username }';
}

class ClickedContactsEvent extends ContactsEvent {
  const ClickedContactsEvent();

  @override
  String toString() => 'ClickedContactEvent';
}
