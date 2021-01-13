import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/AudioBookPlayer.dart';
import 'package:flutterapp/activity/EpubFilenew.dart';
import 'package:flutterapp/activity/VideoBookPlayer.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class DownloadFilesView extends StatefulWidget {
  Downloads downloads;
  String bookImage = "";
  String bookName = "";
  String mBookId = "0";
  bool isOffline = false;
  bool isSampleFile = false;

  DownloadFilesView(this.mBookId, this.downloads, this.bookImage, this.bookName,
      {this.isOffline, this.isSampleFile = false});

  @override
  _DownloadFilesViewState createState() => _DownloadFilesViewState();
}

class _DownloadFilesViewState extends State<DownloadFilesView> {
  String fileUrl = "";
  bool _isPDFFile = false;
  bool _isVideoFile = false;
  bool _isAudioFile = false;
  bool _isEpubFile = false;
  bool _isDefaultFile = false;
  bool _isFileExist = false;
  String bookId = "0";

  @override
  void initState() {
    super.initState();
    fileUrl = widget.downloads.file.toString();
    final filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
    if (filename.contains(".pdf")) {
      checkFileIsExist();
      _isPDFFile = true;
    } else if (filename.contains(".mp4") ||
        filename.contains(".mov") ||
        filename.contains(".webm")) {
      _isVideoFile = true;
      _isFileExist = true;
    } else if (filename.contains(".mp3") || filename.contains(".flac")) {
      _isAudioFile = true;
      _isFileExist = true;
    } else if (filename.contains(".epub")) {
      checkFileIsExist();
      _isEpubFile = true;
    } else {
      _isFileExist = true;
      _isDefaultFile = true;
    }
  }

/*
  Future<File> get _localFile async {
    String path = await localPath;
    String filePath =
        path + "/" + getFileName(widget.downloads.file, widget.mBookId);
    return File(filePath);
  }
*/

  checkFileIsExist() async {
    String path = (await getBookFilePath(widget.mBookId, widget.downloads.file,
        isSampleFile: widget.isSampleFile));
    if (!File(path).existsSync()) {
      printLogs("_isFileExist False");
      setState(() {
        _isFileExist = false;
      });
    } else {
      printLogs("_isFileExist False");
      setState(() {
        _isFileExist = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    // todo bookmarks of book
    return GestureDetector(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (_isPDFFile)
                        Image.asset(
                          "pdf.png",
                          width: 24,
                          color: appStore.iconColor,
                        ),
                      if (_isVideoFile)
                        Image.asset(
                          "video.png",
                          width: 24,
                          color: appStore.iconColor,
                        ),
                      if (_isAudioFile)
                        Image.asset(
                          "music.png",
                          width: 24,
                          color: appStore.iconColor,
                        ),
                      if (_isEpubFile)
                        Image.asset(
                          "epub.png",
                          width: 24,
                          color: appStore.iconColor,
                        ),
                      if (_isDefaultFile)
                        Image.asset(
                          "default.png",
                          width: 24,
                          color: appStore.iconColor,
                        ),
                      8.width,
                      // file name
                      Container(
                        color: Colors.yellow,
                        child: Expanded(
                          child: Text(
                            widget.downloads.name,
                            textAlign: TextAlign.start,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: fontSizeNormal,
                              color: appStore.appTextPrimaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: (!_isFileExist)
                      ? Image.asset(
                          "downloads.png",
                          color: appStore.iconColor,
                          width: 24,
                        )
                      : SizedBox(),
                  flex: 1,
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  top: spacing_standard_new, bottom: spacing_standard),
              height: 1,
            )
          ],
        ),
      ),



      // todo ontap of file

      onTap: () {
        Navigator.of(context).pop();
        if (_isPDFFile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewEPubFileNew(
                  widget.mBookId,
                  widget.bookName,
                  widget.bookImage,
                  widget.downloads,
                  platform,
                  true,
                  _isFileExist),
            ),
          );
        } else if (_isVideoFile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoBookPlayer(widget.downloads),
            ),
          );
        } else if (_isAudioFile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioBookPlayer(
                url: widget.downloads.file,
                bookImage: widget.bookImage,
                bookName: widget.bookName,
              ),
            ),
          );
        } else if (_isEpubFile) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewEPubFileNew(
                  widget.mBookId,
                  widget.bookName,
                  widget.bookImage,
                  widget.downloads,
                  platform,
                  false,
                  _isFileExist),
            ),
          );
        } else {
          toast("File format not supported.");
        }
      },
    );
  }
}
