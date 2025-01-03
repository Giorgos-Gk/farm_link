import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/provider/user_data_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact.dart';
import '../provider/base_provider.dart';
import 'base_repository.dart';

class UserDataRepository extends BaseRepository {
  final BaseUserDataProvider userDataProvider;

  UserDataRepository({BaseUserDataProvider? provider})
      : userDataProvider = provider ?? UserDataProvider();

  Future<FarmLinkUser> saveDetailsFromGoogleAuth(User user) =>
      userDataProvider.saveDetailsFromGoogleAuth(user);

  Future<FarmLinkUser> saveProfileDetails(
          String profileImageUrl, String username) =>
      userDataProvider.saveProfileDetails(profileImageUrl, username);

  Future<bool> isProfileComplete() => userDataProvider.isProfileComplete();

  Future<List<Contact>> getContacts() => userDataProvider.getContacts();

  Future<void> addContact(String username) =>
      userDataProvider.addContact(username);

  Future<void> updateProfilePicture(String profilePictureUrl) =>
      userDataProvider.updateProfilePicture(profilePictureUrl);

  @override
  void dispose() {
    userDataProvider.dispose();
  }
}
