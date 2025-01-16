import 'package:equatable/equatable.dart';
import 'package:farm_link/models/contact.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

class FetchContactsEvent extends ContactsEvent {
  const FetchContactsEvent();

  @override
  String toString() => 'FetchContactsEvent';
}

// Dispatch received contacts from stream
class ReceivedContactsEvent extends ContactsEvent {
  final List<Contact> contacts;

  const ReceivedContactsEvent(this.contacts);

  @override
  List<Object?> get props => [contacts];

  @override
  String toString() => 'ReceivedContactsEvent {contacts: ${contacts.length}}';
}

class AddContactEvent extends ContactsEvent {
  final String username;

  const AddContactEvent({required this.username});

  @override
  List<Object?> get props => [username];

  @override
  String toString() => 'AddContactEvent {username: $username}';
}

class ClickedContactEvent extends ContactsEvent {
  final Contact contact;

  const ClickedContactEvent(this.contact);

  @override
  List<Object?> get props => [contact];

  @override
  String toString() => 'ClickedContactEvent {contact: ${contact.username}}';
}
