import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/confi/application.dart';
import 'package:flutterapp/model/pdfBookMark.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flushbar/flushbar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import '../activity/AudioBookPlayer.dart';
import '../activity/VideoBookPlayer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutterapp/utils/Constant.dart';
import '../main.dart';

// ignore: must_be_immutable
class LocalFiles extends StatefulWidget {
  String mBookId, mBookName, mBookImage;
  String bookImage = "";
  String bookName = "";
  var platform;

  LocalFiles({Key key, this.title, this.platform}) : super(key: key);

  String title;

  @override
  _LocalFilesState createState() => _LocalFilesState();
}

class _LocalFilesState extends State<LocalFiles> with WidgetsBindingObserver {
  static const platform = const MethodChannel('fileUrl');
  var openFileUrl;
  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();
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
  int currentPage = 0;
  int pages = 0;
  bool isReady = false;
  String errorMessage = '';
  @override
  void initState() {
    super.initState();
    extStroageUrl();
    splitJoinExUrl();
    // requestPermission();
    ApplicationGlobal.requestPermission(() {
      getOpenFileUrl();
    });
    // Listen to lifecycle events.
  }

// v5 of permissions handler
/*  requestPermission() async {
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
  }*/

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
  List<PdfBookMark> pageMarksList = List<PdfBookMark>();
  List<int> marksList = [];
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
      body:
      Container(
        //   color: Colors.yellow,
        child: Center(
            child: Text(
                "file: " + (openFileUrl != null ? openFileUrl : "Nothing!"))),
      ),
    );
 /*   return Container(

    );*/
  }

  void checkUrl() {}

  Future<String> extStroageUrl() async {
    path = await ExtStorage.getExternalStorageDirectory();
    print('$path here is path '); // /storage/emulated/0
  }

  // internal url work
/*  void splitJoinInUrl() async {
    dynamic fileUrl = await platform.invokeMethod("getOpenFileUrl");
    */ /* var path = await ExtStorage.getExternalStorageDirectory();
    print(path);*/ /*
    print('$fileUrl intent path');

    String rawUrl = fileUrl.toString();
    if (rawUrl.startsWith("/document/msf:31")) {
      final List<String> split = rawUrl.split(":");
      print('"$split "split one');
      endString = split.skip(1).join('');
      print('"$endString "after split');
      // finalString = "$path/$endString";
      // finalString = "/storage/1EED-1E08/$endString";
      finalString = "/storage/msf/24/download/pot.epub";
      print('"$finalString "final path');
    }

*/ /*    rawUrl = rawUrl.replaceAll(":", "/");
    finalString = rawUrl.replaceAll('/document/', '/storage/');
    print('"$finalString "final path');*/ /*
  }*/

  // external url work
  void splitJoinExUrl() async {
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
    // finalString = "/storage/msf/24/download/pot.epub";
    print('"$finalString "final path');
  }

  void getOpenFileUrl() async {
    if (finalString != null && finalString != openFileUrl) {
      setState(() {
        // openFileUrl = 'assets/pot.epub';
        // openFileUrl = '$path/Downloads/pot.epub';
        openFileUrl = finalString;
      });

      WidgetsBinding.instance.addObserver(this);
      // finalString = getOpenFileUrl.toString();
      final filename = openFileUrl.substring(openFileUrl.lastIndexOf("/") + 1);
      print(filename);
      if (filename.contains(".pdf")) {
        openPdf(context, openFileUrl);
        print('head is in pdf');
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
        print('head is in video player');
      } else if (filename.contains(".mp3") || filename.contains(".flac")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AudioBookPlayer(
                  url: openFileUrl,
                  bookImage: widget.bookImage,
                  bookName: widget.bookName,
                ),
          ),
        );
        print('head is in audio player');
        /*   _isAudioFile = true;
      _isFileExist = true;*/
      } else if (filename.contains(".epub")) {
        openEpub(context, openFileUrl);
        print('head is in epub');
        // _isEpubFile = true;
      }
      /*else {
      // _isFileExist = true;
      // _isDefaultFile = true;
    }*/

    }
  }

 /* Widget openPdf(BuildContext context, String fileUrl) {
    return Scaffold(
      appBar: AppBar( automaticallyImplyLeading: false, actions: <Widget>[
        GestureDetector(
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
            decoration: BoxDecoration(
              color: appStore.editTextBackColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                  color: appStore.isDarkModeOn
                      ? appStore.scaffoldBackground
                      : shadow_color,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Icon(
              Icons.list,
              color: Colors.black,
            ),
          ),
          onTap: () {
            pdfMarks(context);
          },
        ),
      ]),
      body: PDFView(
        filePath: fileUrl,
        enableSwipe: true,
        pageSnap: false,
        swipeHorizontal: false,
        onRender: (_page) {
          setState(() {
            pages = _page;
            isReady = true;
          });
        },
        onViewCreated: (PDFViewController pdfViewController) {
          _controller.complete(pdfViewController);
        },
        onPageChanged: (page, total) {
          print('page change: $page/$total');
          setInt(PAGE_NUMBER + widget.mBookId.toString(), page);
          setState(() {
            currentPage = page;
          });
        },
        defaultPage: currentPage,
      ),
      floatingActionButton: GestureDetector(
          onTap: () async {
            if (pageMarksList.length < 1) {
              marksList.insert(0, currentPage);
              pageMarksList.insert(
                  0, PdfBookMark(id: widget.mBookId, marksList: marksList));
              flushBar("Bookmark Added");
              // saveData();
              print('bookmark in null condition');
            } else if (!marksList.contains(currentPage)) {
              marksList.insert(0, currentPage);
              pageMarksList.insert(
                  0, PdfBookMark(id: widget.mBookId, marksList: marksList));
              flushBar("Bookmark Added");
              // saveData();
              print('bookmark in 2 condition');
            } else {
              flushBar("Bookmark Already Exists");
              print('bookmark in 3 condition');
            }

            print('saved page $marksList');
            print(
                'whole saved list ${pageMarksList[0].id},${pageMarksList[0].marksList}');
          },
          child: Container(
            decoration: BoxDecoration(
                color: appStore.appBarColor,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: 50,
            width: 50,
            child: Icon(Icons.book),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  }*/
  void openPdf(BuildContext context, String fileUrl) {
    /* PDFView(
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
    );*/
    PdftronFlutter.openDocument(fileUrl,);
  }

  Future<void> openEpub(BuildContext context, String fileUrl) async {
    EpubViewer.setConfig(
        themeColor: Theme
            .of(context)
            .primaryColor,
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
    EpubViewer.open(Platform.isAndroid ? fileUrl : fileUrl,
        lastLocation: epubLocator);

    EpubViewer.locatorStream.listen((locator) {
      setString('locator', locator);
    });
  }

  void flushBar(String content) {
    Flushbar(
      message: content,
      duration: Duration(seconds: 2),
    )..show(context);
  }

  void pdfMarks(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30.0),
          ),
        ),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) =>
            StatefulBuilder(builder: (BuildContext context, StateSetter state) {
              return Container(
                  height: MediaQuery.of(context).size.height * .70,
                  //height of bottomsheet
                  padding: EdgeInsets.symmetric(
                    horizontal: 05,
                  ),
                  // color: Colors.green,
                  child: Column(
                    children: [
                      AppBar(
                        automaticallyImplyLeading: false,
                        title: Center(
                            child: Text(
                              'Your BookMarks',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black),
                            )),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.black,
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * .60,
                        child: (marksList.length > 0)
                            ? FutureBuilder<PDFViewController>(
                          future: _controller.future,
                          builder: (context,
                              AsyncSnapshot<PDFViewController> snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: marksList.length,
                                itemBuilder: (context, int index) {
                                  return ListTile(
                                    dense: false,
                                    onTap: () async {
                                      await snapshot.data
                                          .setPage(marksList[index]);
                                      Navigator.pop(context);
                                      print(snapshot);
                                      print(
                                          'PageMarked @ $index, ${marksList[index]}');
                                    },
                                    title: Text(pageMarksList[index]
                                        .marksList[index]
                                        .toString()),
                                    trailing: GestureDetector(
                                        onTap: () {
                                          print(
                                              'delete clicked in bottom sheet');
                                          state(() {
                                            pageMarksList[index]
                                                .marksList
                                                .removeAt(index);
                                          });
                                          flushBar("Bookmark Deleted");
                                        },
                                        child: Container(
                                            height: 50,
                                            width: 50,
                                            // color: Colors.black,
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))),
                                  );
                                },
                              );
                            }
                            return Container();
                          },
                        )
                            : Container(
                          // color: Colors.red,
                          child: Center(
                            child: Text(
                              "No BookMarks yet!\nHappy Reading",
                              style: TextStyle(
                                  color: Colors.black,
                                  wordSpacing: 05,
                                  height: 02),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                    ],
                  ));
            }));
  }
}
