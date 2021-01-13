import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import 'Constant.dart';
import 'app_widget.dart';
import 'utils.dart';

// ignore: must_be_immutable
class DownloadFiles extends StatefulWidget {
  Downloads downloads;

  DownloadFiles(this.downloads);

  @override
  _DownloadFilesState createState() => _DownloadFilesState();
}

class _DownloadFilesState extends State<DownloadFiles> {
  String percentageCompleted = "";
  double _progress = 0;

  get downloadProgress => _progress;

  @override
  void initState() {
    super.initState();
    downloadFileFromServer();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String bookName = getFileNewName(widget.downloads);
    return File('$path/$bookName');
  }

  downloadFileFromServer() async {
    final request = Request('GET', Uri.parse(widget.downloads.file));
    final StreamedResponse response = await Client().send(request);
    final contentLength = response.contentLength;
    _progress = 0;
    List<int> bytes = [];
    final file = await _localFile;
    response.stream.listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        final downloadedLength = bytes.length;
        _progress = downloadedLength / contentLength;
        percentageCompleted = (_progress * 100).toStringAsFixed(2).toString();
        percentageCompleted = percentageCompleted + "% Completed";
        setState(() {});
      },
      onDone: () async {
        _progress = 0;
        await file.writeAsBytes(bytes);
        if (!mounted) return;
        finish(context);
      },
      onError: (e) {
        printLogs(e);
      },
      cancelOnError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing_control),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 250,
        decoration: boxDecoration(color: Colors.white, radius: 10.0),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 20,
                value: downloadProgress,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: spacing_standard_new),
              child: Text(
                percentageCompleted,
                style: TextStyle(
                    fontSize: fontSizeLarge,
                    color: appStore.appTextPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
              child: AppButton(
                value: keyString(context, "lbl_cancel_download"),
                onPressed: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}
