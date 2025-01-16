import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/repository/chat_repository.dart';
import 'package:farm_link/repository/user_data_repository.dart';
import 'package:farm_link/utils/exceptions.dart';
import './Bloc.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final UserDataRepository userDataRepository;
  final ChatRepository chatRepository;
  StreamSubscription? subscription;

  ContactsBloc({
    required this.userDataRepository,
    required this.chatRepository,
  }) : super(InitialContactsState()) {
    on<FetchContactsEvent>(_onFetchContactsEvent);
    on<ReceivedContactsEvent>(_onReceivedContactsEvent);
    on<AddContactEvent>(_onAddContactEvent);
    on<ClickedContactEvent>(_onClickedContactEvent);
  }

  Future<void> _onFetchContactsEvent(
      FetchContactsEvent event, Emitter<ContactsState> emit) async {
    emit(FetchingContactsState());
    try {
      subscription?.cancel();
      subscription = userDataRepository.getContacts().listen((contacts) {
        add(ReceivedContactsEvent(contacts));
      });
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  void _onReceivedContactsEvent(
      ReceivedContactsEvent event, Emitter<ContactsState> emit) {
    emit(FetchedContactsState(event.contacts));
  }

  Future<void> _onAddContactEvent(
      AddContactEvent event, Emitter<ContactsState> emit) async {
    emit(AddContactProgressState());
    try {
      await userDataRepository.addContact(event.username);
      final user = await userDataRepository.getUser(event.username);
      await chatRepository.createChatIdForContact(user);
      emit(AddContactSuccessState());
    } on FarmLinkException catch (exception) {
      emit(AddContactFailedState(exception));
    }
  }

  void _onClickedContactEvent(
      ClickedContactEvent event, Emitter<ContactsState> emit) {
    emit(ClickedContactState(event.contact));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
