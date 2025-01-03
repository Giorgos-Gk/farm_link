import 'package:bloc/bloc.dart';
import 'package:farm_link/bloc/contacts/contacts_event.dart';
import 'package:farm_link/bloc/contacts/contacts_state.dart';
import 'package:farm_link/repository/user_data_repository.dart';
import 'package:farm_link/utils/exceptions.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final UserDataRepository userDataRepository;

  ContactsBloc({required this.userDataRepository})
      : super(const InitialContactsState()) {
    on<FetchContactsEvent>(_onFetchContactsEvent);
    on<AddContactsEvent>(_onAddContactsEvent);
    on<ClickedContactsEvent>(_onClickedContactsEvent);
  }

  Future<void> _onFetchContactsEvent(
      FetchContactsEvent event, Emitter<ContactsState> emit) async {
    try {
      emit(const FetchingContactsState());
      final contacts = await userDataRepository.getContacts();
      emit(FetchedContactsState(contacts));
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  Future<void> _onAddContactsEvent(
      AddContactsEvent event, Emitter<ContactsState> emit) async {
    try {
      emit(const AddContactsProgressState());
      await userDataRepository.addContact(event.username);
      emit(const AddContactsSuccessState());
    } on FarmLinkException catch (exception) {
      emit(AddContactsFailedState(exception));
    }
  }

  Future<void> _onClickedContactsEvent(
      ClickedContactsEvent event, Emitter<ContactsState> emit) async {
    // TODO: Redirect to chat screen or handle contact click event
    emit(const ClickedContactsState());
  }
}
