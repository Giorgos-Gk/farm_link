import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:farm_link/utils/exceptions.dart';
import 'package:farm_link/models/contact.dart';

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
  String toString() => 'FetchedContactsState { contacts: $contacts }';
}

class ShowAddContactsState extends ContactsState {
  const ShowAddContactsState();

  @override
  String toString() => 'ShowAddContactState';
}

class AddContactsProgressState extends ContactsState {
  const AddContactsProgressState();

  @override
  String toString() => 'AddContactProgressState';
}

class AddContactsSuccessState extends ContactsState {
  const AddContactsSuccessState();

  @override
  String toString() => 'AddContactSuccessState';
}

class AddContactsFailedState extends ContactsState {
  final FarmLinkException exception;

  const AddContactsFailedState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'AddContactFailedState { exception: $exception }';
}

class ClickedContactsState extends ContactsState {
  const ClickedContactsState();

  @override
  String toString() => 'ClickedContactState';
}

class ErrorState extends ContactsState {
  final FarmLinkException exception;

  const ErrorState(this.exception);

  @override
  List<Object?> get props => [exception];

  @override
  String toString() => 'ErrorState { exception: $exception }';
}
