import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SocialShare {
  static const MethodChannel _channel = const MethodChannel('social_share');

  static Future<String> copyToTemporaryDir(String mediaPath) async {
    final tempDir = await getTemporaryDirectory();

    File file = File(mediaPath);
    String extension = file.path.split('.').last;
    String AssetName = file.path.substring(file.parent.path.length + 1);
    if (tempDir.toString().compareTo(file.parent.toString()) != 0) {
      AssetName = "stickerAsset." + extension;
      await file.copy('${tempDir.path}/${AssetName}');
    }
    return AssetName;
  }

  static Future<Map<String, dynamic>> getArgumentsForInstagram(String mediaPath) async {
    String AssetName = await copyToTemporaryDir(mediaPath);
    String extension = AssetName.split('.').last;
    String intentType = 'image/*';
    if (extension.compareTo("mp4") == 0 ||
        extension.compareTo("mkv") == 0) {
      intentType = "video/*";
    }

    return <String, dynamic>{
      "backgroundImage": AssetName,
      "intentType": intentType,
    };
  }
  static Future<String> shareInstagramStory(
      String mediaPath,
      String backgroundTopColor,
      String backgroundBottomColor,
      String attributionURL) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{
        "stickerImage": mediaPath,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL
      };
    } else {
      args = await getArgumentsForInstagram(mediaPath);
      args["backgroundTopColor"] = backgroundTopColor;
      args["backgroundBottomColor"] = backgroundBottomColor;
      args["attributionURL"] = attributionURL;
    }
    final String response =
        await _channel.invokeMethod('shareInstagramStory', args);
    return response;
  }

  static Future<String> shareInstagramStorywithBackground(
      String mediaPath,
      String backgroundTopColor,
      String backgroundBottomColor,
      String attributionURL,
      {String stickerImagePath}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{
        "stickerImage": mediaPath,
        "backgroundImage": stickerImagePath,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL
      };
    } else {
      args = await getArgumentsForInstagram(mediaPath);
      String AssetName = await copyToTemporaryDir(stickerImagePath);
      args["stickerImage"] = AssetName;
      args["backgroundTopColor"] = backgroundTopColor;
      args["backgroundBottomColor"] = backgroundBottomColor;
      args["attributionURL"] = attributionURL;
    }

    final String response =
        await _channel.invokeMethod('shareInstagramStory', args);

    return response;
  }

  static Future<String> shareFacebookStory(
      String imagePath,
      String backgroundTopColor,
      String backgroundBottomColor,
      String attributionURL,
      {String appId}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{
        "stickerImage": imagePath,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL,
      };
    } else {
      File file = File(imagePath);
      Uint8List bytes = file.readAsBytesSync();
      var stickerdata = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      String stickerAssetName = 'stickerAsset.png';
      final Uint8List stickerAssetAsList = stickerdata;
      final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
      file = await File(stickerAssetPath).create();
      file.writeAsBytesSync(stickerAssetAsList);
      args = <String, dynamic>{
        "stickerImage": stickerAssetName,
        "backgroundTopColor": backgroundTopColor,
        "backgroundBottomColor": backgroundBottomColor,
        "attributionURL": attributionURL,
        "appId": appId
      };
    }
    final String response =
        await _channel.invokeMethod('shareFacebookStory', args);
    return response;
  }

  static Future<String> shareTwitter(String captionText,
      {List<String> hashtags, String url, String trailingText}) async {
    Map<String, dynamic> args;
    String modifiedUrl;
    if (Platform.isAndroid) {
      modifiedUrl = Uri.parse(url).toString().replaceAll('#', "%23");
    } else {
      modifiedUrl = Uri.parse(url).toString();
    }
    if (hashtags != null && hashtags.isNotEmpty) {
      String tags = "";
      hashtags.forEach((f) {
        tags += ("%23" + f.toString() + " ").toString();
      });
      args = <String, dynamic>{
        "captionText":
            Uri.parse(captionText + "\n" + tags.toString()).toString(),
        "url": modifiedUrl,
        "trailingText": Uri.parse(trailingText).toString()
      };
    } else {
      args = <String, dynamic>{
        "captionText": Uri.parse(captionText + " ").toString(),
        "url": modifiedUrl,
        "trailingText": Uri.parse(trailingText).toString()
      };
    }
    print('hello');
    final String version = await _channel.invokeMethod('shareTwitter', args);
    return version;
  }

  static Future<String> shareSms(String message,
      {String url, String trailingText}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      if (url == null) {
        args = <String, dynamic>{
          "message": Uri.parse(message).toString(),
        };
      } else {
        args = <String, dynamic>{
          "message": Uri.parse(message + " ").toString(),
          "urlLink": Uri.parse(url).toString(),
          "trailingText": Uri.parse(trailingText).toString()
        };
      }
    } else if (Platform.isAndroid) {
      args = <String, dynamic>{
        "message": message + url + trailingText,
      };
    }
    final String version = await _channel.invokeMethod('shareSms', args);
    return version;
  }

  static Future<bool> copyToClipboard(content) async {
    final Map<String, String> args = <String, String>{
      "content": content.toString()
    };
    final bool response = await _channel.invokeMethod('copyToClipboard', args);
    return response;
  }

  static Future<bool> shareOptions(String contentText,
      {String imagePath}) async {
    Map<String, dynamic> args;
    if (Platform.isIOS) {
      args = <String, dynamic>{"image": imagePath, "content": contentText};
    } else {
      if (imagePath != null) {
        File file = File(imagePath);
        Uint8List bytes = file.readAsBytesSync();
        var imagedata = bytes.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        String imageName = 'stickerAsset.png';
        final Uint8List imageAsList = imagedata;
        final imageDataPath = '${tempDir.path}/$imageName';
        file = await File(imageDataPath).create();
        file.writeAsBytesSync(imageAsList);
        args = <String, dynamic>{"image": imageName, "content": contentText};
      } else {
        args = <String, dynamic>{"image": imagePath, "content": contentText};
      }
    }
    final bool version = await _channel.invokeMethod('shareOptions', args);
    return version;
  }

  static Future<String> shareWhatsapp(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String version = await _channel.invokeMethod('shareWhatsapp', args);
    return version;
  }

  static Future<Map> checkInstalledAppsForShare() async {
    final Map apps = await _channel.invokeMethod('checkInstalledApps');
    return apps;
  }
  static Future<String> shareTelegram(String content) async {
    final Map<String, dynamic> args = <String, dynamic>{"content": content};
    final String version = await _channel.invokeMethod('shareTelegram', args);
    return version;
  }

  // static Future<String> shareSlack() async {
  //   final String version = await _channel.invokeMethod('shareSlack');
  //   return version;
  // }
}
