import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutterapp/activity/EpubFilenew.dart';
import 'package:flutterapp/activity/VideoBookPlayer.dart';
import 'AudioBookPlayer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

// ignore: must_be_immutable
class LocalFiles extends StatefulWidget {
  LocalFiles({Key key, this.title}) : super(key: key);

  String title;

  @override
  _LocalFilesState createState() => _LocalFilesState();
}

class _LocalFilesState extends State<LocalFiles> with WidgetsBindingObserver {
  static const platform =
      const MethodChannel('tinyappsteam.flutter.dev/open_file');

  String openFileUrl;

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
    getOpenFileUrl();
    // Listen to lifecycle events.
    WidgetsBinding.instance.addObserver(this);
    fileUrl = getOpenFileUrl.toString();
    final filename = fileUrl.substring(fileUrl.lastIndexOf("/") + 1);
    if (filename.contains(".pdf")) {
      getOpenFileUrl();
      /*    checkFileIsExist();*/
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
      getOpenFileUrl();
      /* checkFileIsExist();*/
      _isEpubFile = true;
    } else {
      _isFileExist = true;
      _isDefaultFile = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getOpenFileUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        //   color: Colors.yellow,
        child: Center(
            child: Text(
                "file: " + (openFileUrl != null ? openFileUrl : "Nothing!"))),
      ),
    );
  }

  void getOpenFileUrl() async {
    dynamic fileUrl = await platform.invokeMethod("getOpenFileUrl");
    print(getOpenFileUrl);
    print(
        'here is the geturl of the file manager FILE-------- ${openFileUrl} ------------');
    print(
        'HEre is the url of the file manager FILE-------- ${fileUrl} ------------');
    if (fileUrl != null && fileUrl != openFileUrl) {
      print(
          'in setState  url of the file manager FILE---****----- ${fileUrl} ---*****---------');
      setState(() {
        openFileUrl = fileUrl;
      });
// for epub

      EpubViewer.setConfig(
          themeColor: Theme.of(context).primaryColor,
          identifier: "iosBook",
          scrollDirection: EpubScrollDirection.VERTICAL,
          allowSharing: true,
          enableTts: true,
          nightMode: false);
      EpubViewer.open(
        fileUrl,
      );
      print('****** $fileUrl  *******  IN EPUBVIEWER');



      // for pdf
/*      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: PDFView(
          filePath: fileUrl,
          pageSnap: false,
          swipeHorizontal: true,
          onPageChanged: (int page, int total) {
            print('****** $fileUrl  *******  IN PDF HERE');
         *//*   print('page change: $page/$total');
            setInt(PAGE_NUMBER + widget.mBookId.toString(), page);
            setState(() {
              currentPage = page;
            });*//*
          },
       *//*   defaultPage: currentPage,*//*

        ),
      );*/




      /*if (_isPDFFile) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewEPubFileNew(
          'id','NAME','',fileUrl,
              null,
              true,
            _isFileExist
              ),
          ),
        );
      }
      // for videofile
      else if
      (_isVideoFile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoBookPlayer(
              fileUrl
            ),
          ),
        );
      }
      // for audiofile
      else if
      (_isAudioFile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioBookPlayer(
              url: fileUrl,

            ),
          ),
        );
      }
      // for epubfile
      else if
      (_isEpubFile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewEPubFileNew(
                'Epub id',' EpubNAME','',fileUrl,
                null,
                true,
                _isFileExist
            ),
          ),
        );
      } else {
        toast("File format not supported.");
      }*/
    }
  }
}
