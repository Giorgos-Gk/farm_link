import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:farm_link/config/constants.dart';
import 'package:farm_link/utils/video_thumbnail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedObjects {
  static late CachedSharedPreferences prefs;

  static Future<void> downloadFile(String fileUrl, String fileName) async {
    await FlutterDownloader.enqueue(
      url: fileUrl,
      fileName: fileName,
      savedDir: Constants.downloadsDirPath,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  static Future<File> getThumbnail(String videoUrl) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: Constants.cacheDirPath,
      imageFormat: ImageFormat.WEBP,
      maxHeightOrWidth: 0,
      quality: 30,
    );
    if (thumbnailPath != null) {
      return File(thumbnailPath);
    } else {
      throw Exception("Failed to generate thumbnail.");
    }
  }

  static int getTypeFromFileType(FileType fileType) {
    if (fileType == FileType.image) {
      return 1;
    } else if (fileType == FileType.video) {
      return 2;
    } else {
      return 3;
    }
  }
}

class CachedSharedPreferences {
  static SharedPreferences? sharedPreferences;
  static CachedSharedPreferences? instance;

  static final Set<String> cachedKeyList = {
    Constants.firstRun,
    Constants.sessionUid,
    Constants.sessionUsername,
    Constants.sessionName,
    Constants.sessionProfilePictureUrl,
    Constants.configDarkMode,
    Constants.configMessagePaging,
    Constants.configMessagePeek,
  };

  static final Set<String> sessionKeyList = {
    Constants.sessionName,
    Constants.sessionUid,
    Constants.sessionUsername,
    Constants.sessionProfilePictureUrl
  };

  static Map<String, dynamic> map = {};
  static Future<CachedSharedPreferences> getInstance() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    if (sharedPreferences!.getBool(Constants.firstRun) ?? true) {
      await sharedPreferences!.setBool(Constants.configDarkMode, false);
      await sharedPreferences!.setBool(Constants.configMessagePaging, false);
      await sharedPreferences!.setBool(Constants.configImageCompression, true);
      await sharedPreferences!.setBool(Constants.configMessagePeek, true);
      await sharedPreferences!.setBool(Constants.firstRun, false);
    }
    for (String key in cachedKeyList) {
      map[key] = sharedPreferences!.get(key);
    }
    instance ??= CachedSharedPreferences();
    return instance!;
  }

  String? getString(String key) {
    if (cachedKeyList.contains(key)) {
      return map[key];
    }
    return sharedPreferences?.getString(key);
  }

  bool? getBool(String key) {
    if (cachedKeyList.contains(key)) {
      return map[key];
    }
    return sharedPreferences?.getBool(key);
  }

  Future<bool> setString(String key, String value) async {
    final result = await sharedPreferences!.setString(key, value);
    if (result) map[key] = value;
    return result;
  }

  Future<bool> setBool(String key, bool value) async {
    final result = await sharedPreferences!.setBool(key, value);
    if (result) map[key] = value;
    return result;
  }

  Future<void> clearAll() async {
    await sharedPreferences!.clear();
    map.clear();
  }

  Future<void> clearSession() async {
    for (String key in sessionKeyList) {
      await sharedPreferences!.remove(key);
      map.remove(key);
    }
  }
}
