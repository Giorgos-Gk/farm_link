import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:farm_link/config/contacts.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/repository/storage_repository.dart';
import 'package:farm_link/utils/exceptions.dart';
import 'package:farm_link/utils/shared_objects.dart';
import '../../repository/chat_repository.dart';
import '../../repository/user_data_repository.dart';
import 'chats_event.dart';
import 'chats_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final UserDataRepository userDataRepository;
  final StorageRepository storageRepository;
  StreamSubscription<List<Message>>? subscription;

  ChatBloc({
    required this.chatRepository,
    required this.userDataRepository,
    required this.storageRepository,
  }) : super(InitialChatState());

  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    print(event);
    if (event is FetchMessagesEvent) {
      yield* mapFetchMessagesEventToState(event);
    } else if (event is ReceivedMessagesEvent) {
      print(event.messages);
      yield FetchedMessagesState(event.messages);
    } else if (event is SendTextMessageEvent) {
      await chatRepository.sendMessage(event.chatId, event.message);
    } else if (event is PickedAttachmentEvent) {
      await mapPickedAttachmentEventToState(event);
    }
  }

  Stream<ChatState> mapFetchMessagesEventToState(
      FetchMessagesEvent event) async* {
    try {
      yield InitialChatState();
      await subscription?.cancel();
      subscription = chatRepository
          .getMessages(event.chatId)
          .listen((messages) => add(ReceivedMessagesEvent(messages)));
    } on FarmLinkException catch (exception) {
      print(exception.errorMessage());
      yield ErrorState(exception);
    }
  }

  Future<void> mapPickedAttachmentEventToState(
      PickedAttachmentEvent event) async {
    String url = await storageRepository.uploadFile(
      event.file,
      Paths.imageAttachmentsPath,
    );
    String username =
        SharedObjects.prefs.getString(Constants.sessionUsername) ?? '';
    String name = SharedObjects.prefs.getString(Constants.sessionName) ?? '';
    Message message = VideoMessage(
      url,
      DateTime.now().millisecondsSinceEpoch,
      name,
      username,
    );
    await chatRepository.sendMessage(event.chatId, message);
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
