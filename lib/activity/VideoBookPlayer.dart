import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/AppPermissionHandler.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/DownloadFiles.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:flutterapp/videoPlayer/chewie_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

// ignore: must_be_immutable
class VideoBookPlayer extends StatefulWidget {
  Downloads downloads;

  VideoBookPlayer(this.downloads);

  @override
  _VideoBookPlayerState createState() => _VideoBookPlayerState();
}

class _VideoBookPlayerState extends State<VideoBookPlayer> {
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  bool fileExist = false;

  @override
  void initState() {
    super.initState();
    //  checkFileIsExist();
    _videoPlayerController1 =
        VideoPlayerController.network(widget.downloads.file);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
      // showControls: false,
      placeholder: Container(
        color: screenBackgroundColor,
      ),
      // autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  checkFileIsExist() async {
    fileExist = await isFileExist(widget.downloads);
    setState(() {});
    if (fileExist) {
      printLogs("Play from Local File");
      _videoPlayerController1 =
          VideoPlayerController.file(await getFilePathFile(widget.downloads));
    } else {
      printLogs("Play from Server");
      _videoPlayerController1 =
          VideoPlayerController.network(widget.downloads.file);
    }
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
      // showControls: false,
      placeholder: Container(
        color: screenBackgroundColor,
      ),
      // autoInitialize: true,
    );
  }

  downloadFile() async {
    var result =
        await requestPermissionGranted(context, [PermissionGroup.storage]);
    if (result) {
      showDialog(
          context: context,
          builder: (BuildContext context) => DownloadFiles(widget.downloads));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(
        context,
        title: widget.downloads.name,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Chewie(
                controller: _chewieController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
