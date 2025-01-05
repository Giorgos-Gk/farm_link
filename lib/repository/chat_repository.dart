import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/provider/base_provider.dart';
import 'package:farm_link/provider/chat_provider.dart';

class ChatRepository {
  BaseChatProvider chatProvider = ChatProvider();
  Stream<List<Chat>> getChats() => chatProvider.getChats();
  Stream<List<Message>> getMessages(String chatId) =>
      chatProvider.getMessages(chatId);
  Future<void> sendMessage(String chatId, Message message) =>
      chatProvider.sendMessage(chatId, message);
}
