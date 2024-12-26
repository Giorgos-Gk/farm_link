import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ImageFormat { JPEG, PNG, WEBP }

class VideoThumbnail {
  static const MethodChannel _channel = MethodChannel('app.messio.channel');

  static Future<String?> thumbnailFile({
    required String video,
    String? thumbnailPath,
    ImageFormat imageFormat = ImageFormat.JPEG,
    int maxHeightOrWidth = 0,
    int quality = 100,
  }) async {
    assert(video.isNotEmpty, 'Video path or URL cannot be empty.');
    final reqMap = <String, dynamic>{
      'video': video,
      'path': thumbnailPath,
      'format': imageFormat.index,
      'maxHeightOrWidth': maxHeightOrWidth,
      'quality': quality
    };
    try {
      final result = await _channel.invokeMethod<String>('file', reqMap);
      return result;
    } catch (e) {
      debugPrint('Error generating thumbnail file: $e');
      return null;
    }
  }

  static Future<Uint8List?> thumbnailData({
    required String video,
    ImageFormat imageFormat = ImageFormat.JPEG,
    int maxHeightOrWidth = 0,
    int quality = 100,
  }) async {
    assert(video.isNotEmpty, 'Video path or URL cannot be empty.');
    final reqMap = <String, dynamic>{
      'video': video,
      'format': imageFormat.index,
      'maxHeightOrWidth': maxHeightOrWidth,
      'quality': quality
    };
    try {
      final result = await _channel.invokeMethod<Uint8List>('data', reqMap);
      return result;
    } catch (e) {
      debugPrint('Error generating thumbnail data: $e');
      return null;
    }
  }
}
