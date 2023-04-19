import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  DownloadScreenState createState() => DownloadScreenState();
  void startDownload() {
    DownloadScreenState downloadScreenState = DownloadScreenState();
    downloadScreenState._downloadVideo();
  }
}

class DownloadScreenState extends State<DownloadScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _formatType = 'mp4';
  bool _downloadSub = false;
  String _responseMessage = '';
  get borderColor => null;

  void _downloadVideo() async {
    // Request permission to access the device's storage
    var status = await Permission.storage.request();
    if (status.isDenied) {
      setState(() {
        _responseMessage = 'Permission to access storage denied';
      });
      return;
    }

    // Get the download directory path
    Directory? downloadDirectory = await getExternalStorageDirectory();
    if (downloadDirectory == null) {
      setState(() {
        _responseMessage = 'Could not get download directory';
      });
      return;
    }

    // Show a file picker dialog to let the user choose the directory
    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) {
      setState(() {
        _responseMessage = 'No directory selected';
      });
      return;
    }

    String url = 'https://ydownlaoder.onrender.com/download';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json =
        '{"url": "${_urlController.text}", "format": "$_formatType", "subtitles": "${_downloadSub.toString()}"}';
    try {
      Dio dio = Dio();
      Response response = await dio.post(
        url,
        options: Options(
          headers: headers,
          responseType: ResponseType.json,
        ),
        data: json,
      );

      if (response.statusCode == 200) {
        // Get the URL of the video file
        String videoUrl = response.data['url'];

        // Download the video file
        Response videoResponse = await dio.get(
          videoUrl,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        );

        if (videoResponse.statusCode == 200) {
          // Save the video to the selected directory
          String fileName = 'video.${_formatType}';
          String path = '$directoryPath/$fileName';
          File file = File(path);
          await file.writeAsBytes(videoResponse.data);
          setState(() {
            _responseMessage = 'Download successful!';
          });
        } else {
          setState(() {
            _responseMessage =
            'Download failed with status code ${videoResponse.statusCode}';
          });
        }
      } else {
        setState(() {
          _responseMessage =
          'Download failed with status code ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Download failed with error $e';
      });
    }
  }

  Future<String> _getDownloadPath(String fileName) async {
    Directory? directory = await getExternalStorageDirectory();
    String newPath = '';
    if (directory != null) {
      newPath = '${directory.path}/Download/$fileName';
    }
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory(); // Use the getApplicationDocumentsDirectory method from dart:io
    }
    return newPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.red,
        title: const Text('YouTube Downloader'),
        centerTitle: true,
      ),
      body: GlassContainer(
        borderColor: borderColor ?? Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        borderRadius: BorderRadius.circular(40),
        blur: 10,
        alignment: Alignment.center,
        borderWidth: 2,
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white24.withOpacity(0.2),
            Colors.white70.withOpacity(0.2),
          ],
        ),
        color: Colors.white.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text('Select format:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _formatType,
                onChanged: (String? newValue) {
                  setState(() {
                    _formatType = newValue!;
                  });
                },
                items: <String>[
                  'mp3',
                  'mp4',
                  'webm',
                  '3gp',
                  'flv',
                  'mov',
                  'avi'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Checkbox(
                    value: _downloadSub,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _downloadSub = newValue!;
                      });
                    },
                  ),
                  const SizedBox(width: 8.0),
                  const Text('Download subtitles'),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _downloadVideo,
                child: const Text('Download'),
              ),
              const SizedBox(height: 16.0),
              Text(
                _responseMessage,
                style: const TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
