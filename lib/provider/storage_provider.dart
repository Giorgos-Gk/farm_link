import 'dart:io';
import 'package:farm_link/provider/base_provider.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageProvider extends BaseStorageProvider {
  final FirebaseStorage firebaseStorage;

  StorageProvider({FirebaseStorage? firebaseStorage})
      : firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(File file, String path) async {
    final String fileName = basename(file.path);
    final int milliSecs = DateTime.now().millisecondsSinceEpoch;
    final reference =
        firebaseStorage.ref().child('$path/$milliSecs\_$fileName');
    final String uploadPath = reference.fullPath;
    print('Uploading to $uploadPath');
    final UploadTask uploadTask = reference.putFile(file);
    final TaskSnapshot result = await uploadTask.whenComplete(() {});
    final String url = await result.ref.getDownloadURL();
    return url;
  }

  @override
  void dispose() {}
}
