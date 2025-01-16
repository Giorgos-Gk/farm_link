import 'package:equatable/equatable.dart';
import 'package:farm_link/models/contact.dart';
import 'package:farm_link/utils/exceptions.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];

  get exception => null;
}

class InitialContactsState extends ContactsState {
  const InitialContactsState();

  @override
  String toString() => 'InitialContactsState';
}

class FetchingContactsState extends ContactsState {
  const FetchingContactsState();

  @override
  String toString() => 'FetchingContactsState';
}

class FetchedContactsState extends ContactsState {
  final List<Contact> contacts;

  const FetchedContactsState(this.contacts);

  @override
  List<Object?> get props => [contacts];

  @override
  String toString() => 'FetchedContactsState {contacts: ${contacts.length}}';
}

class AddContactProgressState extends ContactsState {
  const AddContactProgressState();

  @override
  String toString() => 'AddContactProgressState';
}

class AddContactSuccessState extends ContactsState {
  const AddContactSuccessState();

  @override
  String toString() => 'AddContactSuccessState';
}

class AddContactFailedState extends ContactsState {
  final FarmLinkException exception;

  const AddContactFailedState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'AddContactFailedState {exception: $exception}';
}

class ClickedContactState extends ContactsState {
  final Contact contact;

  const ClickedContactState(this.contact);

  @override
  List<Object?> get props => [contact];

  @override
  String toString() => 'ClickedContactState {contact: ${contact.username}}';
}

class ErrorState extends ContactsState {
  final FarmLinkException exception;

  const ErrorState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'ErrorState {exception: $exception}';
}
