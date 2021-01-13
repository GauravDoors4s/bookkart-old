import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/OfflineBookList.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';

import '../main.dart';

// ignore: must_be_immutable
class DownloadFilesViewOffline extends StatefulWidget {
  OfflineBook downloads;
  String bookImage = "";
  String bookName = "";
  String mBookId = "0";

  DownloadFilesViewOffline(
    this.mBookId,
    this.downloads,
    this.bookImage,
    this.bookName,
  );

  @override
  _DownloadFilesViewOfflineState createState() =>
      _DownloadFilesViewOfflineState();
}

class _DownloadFilesViewOfflineState extends State<DownloadFilesViewOffline> {
  String fileUrl = "";
  bool _isPDFFile = false;
  bool _isVideoFile = false;
  bool _isAudioFile = false;
  bool _isEpubFile = false;
  bool _isDefaultFile = false;
  bool _isFileExist = true;
  String bookId = "0";

  @override
  void initState() {
    super.initState();
    fileUrl = widget.downloads.filePath.toString();
    final filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
    if (filename.contains(".pdf")) {
      _isPDFFile = true;
    } else if (filename.contains(".mp4") ||
        filename.contains(".mov") ||
        filename.contains(".webm")) {
      _isVideoFile = true;
    } else if (filename.contains(".mp3") || filename.contains(".flac")) {
      _isAudioFile = true;
    } else if (filename.contains(".epub")) {
      _isEpubFile = true;
    } else {
      _isDefaultFile = true;
    }
    // checkFileIsExist();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  flex: 1,
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
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        widget.downloads.fileName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSizeNormal,
                          color: appStore.appTextPrimaryColor,
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: (!_isFileExist)
                      ? Image.asset(
                          "downloads.png",
                          color: appStore.iconColor,
                          width: 24,
                        )
                      : SizedBox(),
                  flex: 1,
                )
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
      onTap: () {
        readFile(context, widget.mBookId,widget.downloads.filePath, widget.bookName,
            isCloseApp: false);
      },
    );
  }
}
