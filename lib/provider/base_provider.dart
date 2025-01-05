import 'dart:io';
import 'package:farm_link/models/contact.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:farm_link/models/chat.dart';
import 'package:farm_link/models/message.dart';
import 'package:farm_link/models/farmlink_user.dart';

abstract class BaseProvider {
  void dispose();
}

abstract class BaseAuthenticationProvider extends BaseProvider {
  Future<User?> signUpWithEmailAndPassword(String email, String password);
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  User? getCurrentUser();
  bool isLoggedIn();
}

abstract class BaseUserDataProvider extends BaseProvider {
  Future<FarmLinkUser> saveDetailsFromGoogleAuth(User user);
  Future<FarmLinkUser> saveProfileDetails(
      String profileImageUrl, String username);
  Future<bool> isProfileComplete();
  Future<List<Contact>> getContacts();
  Future<void> addContact(String username);
  Future<void> updateProfilePicture(String profilePictureUrl);
}

abstract class BaseStorageProvider extends BaseProvider {
  Future<String> uploadFile(File file, String path);
}

abstract class BaseChatProvider extends BaseProvider {
  Stream<List<Message>> getMessages(String chatId);
  // Future<List<Message>> getPreviousMessages(String chatId, Message prevMessage);
  // Future<List<Message>> getAttachments(String chatId, int type);
  Stream<List<Chat>> getChats();
  Future<void> sendMessage(String chatId, Message message);
  // Future<String> getChatIdByUsername(String username);
  // Future<void> createChatIdForContact(FarmLinkUser user);
}

abstract class BaseDeviceStorageProvider extends BaseProvider {
  Future<File> getThumbnail(String videoUrl);
}
