import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Running on: $_platformVersion\n',
                  textAlign: TextAlign.center,
                ),
                RaisedButton(
                  onPressed: () async {
                    File file = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    SocialShare.shareFile(file.path).then((data) {
                      print(data);
                    });
                  },
                  child: Text("Share photo"),
                ),
                RaisedButton(
                  onPressed: () async {
                    File file = await ImagePicker.pickVideo(
                        source: ImageSource.gallery);
                    SocialShare.shareFile(file.path).then((data) {
                      print(data);
                    });
                  },
                  child: Text("Share video"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
