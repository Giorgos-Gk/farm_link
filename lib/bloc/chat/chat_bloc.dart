import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:farm_link/bloc/chat/chat_event.dart';
import 'package:farm_link/bloc/chat/chat_state.dart';
import 'package:farm_link/config/contacts.dart';
import 'package:farm_link/config/paths.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/repository/chat_repository.dart';
import 'package:farm_link/repository/storage_repository.dart';
import 'package:farm_link/repository/user_data_repository.dart';
import 'package:farm_link/utils/exceptions.dart';
import 'package:farm_link/utils/shared_objects.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final UserDataRepository userDataRepository;
  final StorageRepository storageRepository;
  StreamSubscription? messagesSubscription;
  StreamSubscription? chatsSubscription;
  String? activeChatId;

  ChatBloc({
    required this.chatRepository,
    required this.userDataRepository,
    required this.storageRepository,
  }) : super(InitialChatState()) {
    on<FetchChatListEvent>(_onFetchChatListEvent);
    on<ReceivedChatsEvent>(_onReceivedChatsEvent);
    on<PageChangedEvent>(_onPageChangedEvent);
    on<FetchConversationDetailsEvent>(_onFetchConversationDetailsEvent);
    on<FetchMessagesEvent>(_onFetchMessagesEvent);
    on<ReceivedMessagesEvent>(_onReceivedMessagesEvent);
    on<SendTextMessageEvent>(_onSendTextMessageEvent);
    on<SendAttachmentEvent>(_onSendAttachmentEvent);
  }

  Future<void> _onFetchChatListEvent(
      FetchChatListEvent event, Emitter<ChatState> emit) async {
    try {
      chatsSubscription?.cancel();
      chatsSubscription = chatRepository.getChats().listen((chats) {
        add(ReceivedChatsEvent(chats));
      });
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  void _onReceivedChatsEvent(
      ReceivedChatsEvent event, Emitter<ChatState> emit) {
    emit(FetchedChatListState(event.chatList));
  }

  void _onPageChangedEvent(PageChangedEvent event, Emitter<ChatState> emit) {
    activeChatId = event.activeChat.chatId;
  }

  Future<void> _onFetchConversationDetailsEvent(
      FetchConversationDetailsEvent event, Emitter<ChatState> emit) async {
    try {
      final user = await userDataRepository.getUser(event.chat.username);
      emit(FetchedContactDetailsState(user));
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  Future<void> _onFetchMessagesEvent(
      FetchMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      emit(InitialChatState());
      final chatId =
          await chatRepository.getChatIdByUsername(event.chat.username);
      messagesSubscription?.cancel();
      messagesSubscription =
          chatRepository.getMessages(chatId).listen((messages) {
        add(ReceivedMessagesEvent(messages));
      });
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  void _onReceivedMessagesEvent(
      ReceivedMessagesEvent event, Emitter<ChatState> emit) {
    emit(FetchedMessagesState(event.messages));
  }

  Future<void> _onSendTextMessageEvent(
      SendTextMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final message = TextMessage(
        event.message,
        DateTime.now().millisecondsSinceEpoch,
        SharedObjects.prefs.getString(Constants.sessionName) ?? '',
        SharedObjects.prefs.getString(Constants.sessionUsername) ?? '',
      );
      await chatRepository.sendMessage(activeChatId ?? '', message);
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  Future<void> _onSendAttachmentEvent(
      SendAttachmentEvent event, Emitter<ChatState> emit) async {
    try {
      final url = await storageRepository.uploadFile(
        event.file,
        Paths.imageAttachmentsPath,
      );
      final username =
          SharedObjects.prefs.getString(Constants.sessionUsername) ?? '';
      final name = SharedObjects.prefs.getString(Constants.sessionName) ?? '';
      final message = VideoMessage(
        url,
        DateTime.now().millisecondsSinceEpoch,
        name,
        username,
      );
      await chatRepository.sendMessage(event.chatId, message);
    } on FarmLinkException catch (exception) {
      emit(ErrorState(exception));
    }
  }

  @override
  Future<void> close() async {
    messagesSubscription?.cancel();
    chatsSubscription?.cancel();
    return super.close();
  }
}
