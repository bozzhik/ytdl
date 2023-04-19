import 'package:flutter/material.dart';
import 'download_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YouTube Downloader',
      home: DownloadScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void download() {
  DownloadScreen downloadScreen = const DownloadScreen();
  downloadScreen.startDownload();
}