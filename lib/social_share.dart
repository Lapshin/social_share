import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<Map<String, dynamic>> getArguments(String mediaPath) async {
    String extension = mediaPath.split('.').last;
    String intentType = 'image/*';
    if (extension.compareTo("mp4") == 0 ||
        extension.compareTo("mkv") == 0) {
      intentType = "video/*";
    }

    return <String, dynamic>{
      "filePath": mediaPath,
      "intentType": intentType,
    };
  }

  static Future<String> shareFile(String mediaPath) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{
        "mediaPath": mediaPath,
      };
    } else {
      args = await getArguments(mediaPath);
    }
    final String response =
        await _channel.invokeMethod('shareFile', args);
    return response;
  }
}
