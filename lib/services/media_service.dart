import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MediaService {
  static final MediaService instance = MediaService();
  final ImagePicker _picker = ImagePicker();

  Future<File?> getImageFromLibrary() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
