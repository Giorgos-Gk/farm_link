import 'package:farm_link/models/farmlink_user.dart';
import 'package:farm_link/provider/user_data_provider.dart';
import '../models/contact.dart';
import '../provider/base_provider.dart';
import 'base_repository.dart';

class UserDataRepository extends BaseRepository {
  final BaseUserDataProvider userDataProvider;

  UserDataRepository({BaseUserDataProvider? provider})
      : userDataProvider = provider ?? UserDataProvider();

  Future<Contact?> getContactByUsername(String username) async {
    final contacts = await getContacts().first;
    return contacts.firstWhere(
      (contact) => contact.username == username,
    );
  }

  Future<FarmLinkUser> saveProfileDetails(
          String profileImageUrl, String username) =>
      userDataProvider.saveProfileDetails(profileImageUrl, username);

  Future<bool> isProfileComplete() => userDataProvider.isProfileComplete();

  Stream<List<Contact>> getContacts() {
    return Stream.fromFuture(userDataProvider.getContacts());
  }

  Future<FarmLinkUser> getUser(String username) =>
      userDataProvider.getUser(username);

  Future<void> addContact(String username) =>
      userDataProvider.addContact(username);

  // Future<void> updateProfilePicture(String profilePictureUrl) =>
  //     userDataProvider.updateProfilePicture(profilePictureUrl);

  @override
  void dispose() {
    userDataProvider.dispose();
  }
}
