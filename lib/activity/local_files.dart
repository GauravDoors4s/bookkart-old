import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:ext_storage/ext_storage.dart';
import '../activity/AudioBookPlayer.dart';
import '../activity/EpubFilenew.dart';
import '../activity/VideoBookPlayer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/AppPermissionHandler.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: must_be_immutable
class LocalFiles extends StatefulWidget {
  String mBookId, mBookName, mBookImage;
  var platform;

  LocalFiles({Key key, this.title, this.platform}) : super(key: key);

  String title;

  @override
  _LocalFilesState createState() => _LocalFilesState();
}

class _LocalFilesState extends State<LocalFiles> with WidgetsBindingObserver {
  static const platform = const MethodChannel('fileUrl');
  int currentPage = 0;
  var openFileUrl;
  String fileUrl = "";
  bool _isPDFFile = false;
  bool _isVideoFile = false;
  bool _isAudioFile = false;
  bool _isEpubFile = false;
  bool _isDefaultFile = false;
  bool _isFileExist = false;
  String bookId = "0";
  String path;
  String finalString;
  String endString;

  @override
  void initState() {
    super.initState();
    extStroageUrl();
    splitJoinUrl();
    requestPermission();

    // Listen to lifecycle events.
  }




// v5 of permissions handler
  requestPermission() async {
    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]);

      if (statuses[Permission.storage].isGranted) {
        debugPrint("status is granted   isUndetermined");
        try {
          //Do something
          getOpenFileUrl();
        } catch (e) {
          debugPrint("error :   ${e.toString()}");
        }
        //Do something
        getOpenFileUrl();
      } else if (statuses[Permission.storage].isDenied) {
        debugPrint("status is granted   isDenied");
        requestPermission();
      } else if (statuses[Permission.storage].isPermanentlyDenied) {
        debugPrint("status is granted   isPermanentlyDenied");
        openAppSettings();
      }

      // it should print PermissionStatus.granted
    } else if (status.isGranted) {
      debugPrint("status is granted");
      try {
        //Do something.
        getOpenFileUrl();
      } catch (e) {
        debugPrint("error :   ${e.toString()}");
      }
    } else if (status.isDenied) {
      debugPrint("status is denied");
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[Permission.storage]); //
    } else if (status.isPermanentlyDenied) {
      debugPrint("status is permanent denied");
      openAppSettings();
    } else if (status.isRestricted) {
      debugPrint("status is restricted");
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

  Future<String> extStroageUrl() async {
    path = await ExtStorage.getExternalStorageDirectory();
    print('$path here is path '); // /storage/emulated/0
  }

  void splitJoinUrl() async {
    dynamic fileUrl = await platform.invokeMethod("getOpenFileUrl");
    /* var path = await ExtStorage.getExternalStorageDirectory();
    print(path);*/
    print('$fileUrl intent path');

    String rawUrl = fileUrl.toString();
    /*   if (rawUrl.startsWith("/document/1EED-1E08:") ||
        rawUrl.startsWith("/document/msf:31")) {
      final List<String> split = rawUrl.split(":");
      print('"$split "split one');
      endString = split.skip(1).join('');
      print('"$endString "after split');
      finalString = "$path/$endString";
      // finalString = "/storage/1EED-1E08/$endString";
      print('"$finalString "final path');
    }*/

    rawUrl = rawUrl.replaceAll(":", "/");
    finalString = rawUrl.replaceAll('/document/', '/storage/');
    print('"$finalString "final path');
  }

  void getOpenFileUrl() async {
    if (finalString != null && finalString != openFileUrl) {
      setState(() {
        // openFileUrl = 'assets/pot.epub';
        openFileUrl = finalString;
      });

      WidgetsBinding.instance.addObserver(this);
      // finalString = getOpenFileUrl.toString();
      final filename = openFileUrl.substring(openFileUrl.lastIndexOf("/") + 1);
      print(filename);
      if (filename.contains(".pdf")) {
        openPdf();
        // _isPDFFile = true;
      } else if (filename.contains(".mp4") ||
          filename.contains(".mov") ||
          filename.contains(".webm")) {
        /* _isVideoFile = true;
      _isFileExist = true;*/
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoBookPlayer(openFileUrl),
          ),
        );
      } else if (filename.contains(".mp3") || filename.contains(".flac")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioBookPlayer(
              url: openFileUrl,
            ),
          ),
        );
        /*   _isAudioFile = true;
      _isFileExist = true;*/
      } else if (filename.contains(".epub")) {
        openEpub();
        // _isEpubFile = true;
      }
      /*else {
      // _isFileExist = true;
      // _isDefaultFile = true;
    }*/

// for epub
/*
      EpubViewer.setConfig(
          themeColor: Theme.of(context).primaryColor,
          identifier: "iosBook",
          scrollDirection: EpubScrollDirection.VERTICAL,
          allowSharing: true,
          enableTts: true,
          nightMode: false);
      EpubViewer.open(
        openFileUrl,
      );
      print('****** $openFileUrl  *******  IN EPUBVIEWER');
*/

      // for pdf
      /* Container(
        height: MediaQuery.of(context).size.height * 0.85,
        child: PDFView(
          filePath: fileUrl,
          pageSnap: false,
          swipeHorizontal: true,
          onPageChanged: (int page, int total) {
            print('****** $fileUrl  *******  IN PDF HERE');
               print('page change: $page/$total');
            setInt(PAGE_NUMBER + widget.mBookId.toString(), page);
            setState(() {
              currentPage = page;
            });
          },
             defaultPage: currentPage,

        ),
      ); */

/*       if (_isPDFFile) {
  */ /*      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewEPubFileNew(
          'id','NAME','',openFileUrl,
              null,
              true,
            _isFileExist
              ),
          ),
        );*/ /*

         openPdf();
      }
      // for videofile
      else if
      (_isVideoFile) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoBookPlayer(
                openFileUrl
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
              url: openFileUrl,

            ),
          ),
        );
      }
      // for epubfile
      else if
      (_isEpubFile) {
         openEpub();
      } else {
        toast("File format not supported.");
      }*/
    }
  }

  void openPdf() {
    PDFView(
      filePath: fileUrl,
      pageSnap: false,
      swipeHorizontal: true,
      onPageChanged: (int page, int total) {
        print('****** $fileUrl  *******  IN PDF HERE');
        print('page change: $page/$total');
        setInt(PAGE_NUMBER + widget.mBookId.toString(), page);
        setState(() {
          currentPage = page;
        });
      },
      defaultPage: currentPage,
    );
  }

  Future<void> openEpub() async {
    EpubViewer.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "iosBook",
        scrollDirection: EpubScrollDirection.VERTICAL,
        allowSharing: true,
        enableTts: true,
        nightMode: false);

    var epubLocator = EpubLocator();
    String locatorPref = await getString('locator');

    try {
      if (locatorPref.isNotEmpty) {
        Map<String, dynamic> r = jsonDecode(locatorPref);

        epubLocator = EpubLocator.fromJson(r);
        print("***Location prefs Are $r ******");
      }
    } on Exception catch (e) {
      epubLocator = EpubLocator();
      await removeKey('locator');
    }
    EpubViewer.open(Platform.isAndroid ? openFileUrl : openFileUrl,
        lastLocation: epubLocator);

    EpubViewer.locatorStream.listen((locator) {
      setString('locator', locator);
    });
  }
}
