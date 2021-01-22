import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/database_helper.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

// import 'package:open_file/open_file.dart';
// import 'package:dio/dio.dart';

// ignore: must_be_immutable
class ViewEPubFileNew extends StatefulWidget {
  Downloads downloads;
  static String tag = '/EpubFiles';
  String mBookId, mBookName, mBookImage;
  final TargetPlatform platform;
  bool isPDFFile = false;
  bool _isFileExist = false;
 String bookMark;

  ViewEPubFileNew(this.mBookId, this.mBookName, this.mBookImage, this.downloads,
      this.platform, this.isPDFFile, this._isFileExist, this.bookMark);

  @override
  ViewEPubFileNewState createState() => ViewEPubFileNewState();
}

class ViewEPubFileNewState extends State<ViewEPubFileNew> {
  _TaskInfo _tasks;
  bool isDownloadFile = false;
  bool isDownloadFailFile = false;
  String percentageCompleted = "";
  ReceivePort _port = ReceivePort();
  String fullFilePath = "";
  int userId = 0;
  final dbHelper = DatabaseHelper.instance;
  DownloadedBook mSampleDownloadTask;
  DownloadedBook mBookDownloadTask;
  int currentPage = 0;
  bool _showViewer = true;
  String _version = 'Unknown';
  String _document =
      "https://rise.esmap.org/data/files/webform/pdf-harry-potter-and-the-order-of-the-phoenix-book-5-jk-rowling-pdf-download-free-book-beb8863.pdf";

  String filePath;
  @override
  void initState() {
    super.initState();
     initialDownload();
    initPlatformState();
    // showViewer();
  /*  getBookmark();*/
  }
  Future<void> initPlatformState() async {
    String version;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      PdftronFlutter.initialize("your_pdftron_license_key");
      version = await PdftronFlutter.version;
    } on PlatformException {
      version = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _version = version;
    });
  }
/*
  void showViewer() async {
    // opening without a config file will have all functionality enabled.
    // await PdftronFlutter.openDocument(_document);

    // shows how to disale functionality
//      var disabledElements = [Buttons.shareButton, Buttons.searchButton];
//      var disabledTools = [Tools.annotationCreateLine, Tools.annotationCreateRectangle];
    var config = Config();
//      config.disabledElements = disabledElements;
//      config.disabledTools = disabledTools;
//      config.multiTabEnabled = true;
//      config.customHeaders = {'headerName': 'headerValue'};

    var documentLoadedCancel = startDocumentLoadedListener((filePath) {
      print("document loaded: $filePath");
    });

    await PdftronFlutter.openDocument(_document, config: config);

    try {
      PdftronFlutter.importAnnotationCommand(
          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
              "    <xfdf xmlns=\"http://ns.adobe.com/xfdf/\" xml:space=\"preserve\">\n" +
              "      <add>\n" +
              "        <square style=\"solid\" width=\"5\" color=\"#E44234\" opacity=\"1\" creationdate=\"D:20200619203211Z\" flags=\"print\" date=\"D:20200619203211Z\" name=\"c684da06-12d2-4ccd-9361-0a1bf2e089e3\" page=\"1\" rect=\"113.312,277.056,235.43,350.173\" title=\"\" />\n" +
              "      </add>\n" +
              "      <modify />\n" +
              "      <delete />\n" +
              "      <pdf-info import-version=\"3\" version=\"2\" xmlns=\"http://www.pdftron.com/pdfinfo\" />\n" +
              "    </xfdf>");
    } on PlatformException catch (e) {
      print("Failed to importAnnotationCommand '${e.message}'.");
    }

    try {
      PdftronFlutter.importBookmarkJson('{"0":"Page 1"}');
    } on PlatformException catch (e) {
      print("Failed to importBookmarkJson '${e.message}'.");
    }

    var annotCancel = startExportAnnotationCommandListener((xfdfCommand) {
      // local annotation changed
      // upload XFDF command to server here
      print("flutter xfdfCommand: $xfdfCommand");
    });

    var bookmarkCancel = startExportBookmarkListener((bookmarkJson) {
      print("flutter bookmark: $bookmarkJson");
    });

    var path = await PdftronFlutter.saveDocument();
    print("flutter save: $path");

    // to cancel event:
    // annotCancel();
    // bookmarkCancel();
  }*/
  // ignore: missing_return

  Future initialDownload() async {
    if (widget._isFileExist) {
      filePath =
          await getBookFilePath(widget.mBookId, widget.downloads.file);
      setState(() {
        isDownloadFile = true;
      });
      _openDownloadedFile(filePath);

    } else {
      userId = await getInt(USER_ID);
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
      requestPermission();
    }
    var mCurrentPAgeData = await getInt(PAGE_NUMBER + widget.mBookId);
    print("Page Saved : " + mCurrentPAgeData.toString());
    if (mCurrentPAgeData != null && mCurrentPAgeData.toString().isNotEmpty) {
      currentPage = mCurrentPAgeData;
    } else {
      currentPage = 0;
    }
  }
  void requestPermission() async {
    if (await checkPermission(widget)) {
      _prepare();
    } else {
      if (widget.platform == TargetPlatform.android) {
        Navigator.of(context).pop();
      } else {
        _prepare();
      }
    }
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }


  void _bindBackgroundIsolate() async {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }

    _port.listen((dynamic data) async {
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if (_tasks != null) {
        setState(() {
          _tasks.status = status;
          _tasks.progress = progress;
          percentageCompleted = (_tasks.progress).toStringAsFixed(2).toString();
          percentageCompleted = percentageCompleted + "% Completed";
        });
        if (_tasks.status == DownloadTaskStatus.complete) {
          FlutterDownloader.remove(
              taskId: _tasks.taskId, shouldDeleteContent: false);
          String filePath = await getBookFilePath(widget.mBookId, _tasks.link);
          insertIntoDb(filePath);
          _openDownloadedFile(filePath);
          setState(() {
            isDownloadFile = true;
          });
        } else if (_tasks.status == DownloadTaskStatus.failed) {
          setState(() {
            isDownloadFailFile = true;
          });
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  // for bookmark button
  // bool pressed = false;


  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: widget.downloads.name),
      body: Builder(
        builder: (context) => !isDownloadFile
            ? isDownloadFailFile
                ? new Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: spacing_standard_new),
                          child: Text(
                            keyString(context, "lbl_download_failed"),
                            style: TextStyle(
                                fontSize: fontSizeLarge,
                                color: appStore.appTextPrimaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                : new Center(
                    child: (_tasks != null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  strokeWidth: 15,
                                  value: _tasks.progress.toDouble(),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: spacing_standard_new),
                                child: Text(
                                  percentageCompleted,
                                  style: TextStyle(
                                      fontSize: fontSizeLarge,
                                      color: appStore.appTextPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          )
                        : SizedBox(),
                  )

            // for pdf
            : !widget.isPDFFile
                ? SizedBox()
                : /*Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: PDFView(
                      filePath: fullFilePath,
                      pageSnap: false,
                      swipeHorizontal: false,
                      onPageChanged: (int page, int total) {
                        print('page change: $page/$total');
                        setInt(PAGE_NUMBER + widget.mBookId.toString(), page);
                        setState(() {
                          currentPage = page;
                        });
                      },
                      defaultPage: currentPage,
                    ),
                  ),*/

          PdftronFlutter.openDocument(fullFilePath),
       /* Container(
          width: double.infinity,
          height: double.infinity,
          child:
          // Uncomment this to use Widget version of the viewer
          _showViewer
              ? DocumentView(
            onCreated: _onDocumentViewCreated,
          ):
          Container(
            child: Text('invalid file / not processing it'),
          ),
        ),*/


      ),

      //bookmark page
   /*   floatingActionButton: FloatingActionButton(
        backgroundColor: appStore.scaffoldBackground,
        *//*child: ,*//*
        child: pressed ? Text(widget.bookMark,style: TextStyle(color: Colors.black),):Icon(Icons.bookmark_border_sharp),
        onPressed: () {

          setState(() {
            pressed = true;
            widget.bookMark = currentPage.toString();
            saveBookmark();
          });
          print('${widget.bookMark} page no bookmark Saved');
          print('$pressed bool value bookmark Saved');
        },
      ),*/
    );
  }
/*   saveBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pageBookmark',widget.bookMark );
    prefs.setString('bookId', widget.mBookId );
    prefs.setBool('boolVal',pressed );
    print('page marked method run and saved');
  }

  getBookmark() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    widget.bookMark = prefs.getString('pageBookmark');
    widget.mBookId = prefs.getString('bookId');
     pressed = prefs.getBool('boolVal');
    print('${widget.bookMark} prefs value----> bookmark Saved');
    print('${widget.mBookId}  prefs BOOk Id ----> bookmark Saved');
    print('$pressed prefs bool value----> bookmark Saved');
  }*/


  // void _onDocumentViewCreated(DocumentViewController controller) async {
  //   Config config = new Config();
  //
  //   var leadingNavCancel = startLeadingNavButtonPressedListener(() {
  //     // Uncomment this to quit the viewer when leading navigation button is pressed
  //     this.setState(() {
  //       _showViewer = !_showViewer;
  //     });
  //
  //     // Show a dialog when leading navigation button is pressed
  //     _showMyDialog();
  //   });
  //
  //   controller.openDocument(fullFilePath, config: config);
  // }
  Future<void> _showMyDialog() async {
    print('hello');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog'),
          content: SingleChildScrollView(
            child: Text('Leading navigation button has been pressed.'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _resumeDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void _retryDownload(_TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  // ignore: missing_return
  Future<bool> _openDownloadedFile(String filePath) async {
    setState(() {
      fullFilePath = filePath;
      print("$filePath  THE SELECTED FILE  PATH******************");
    });

    if (!widget.isPDFFile) {
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
      EpubViewer.open(Platform.isAndroid ? filePath : filePath,
          lastLocation: epubLocator);

      EpubViewer.locatorStream.listen((locator) {
        setString('locator', locator);
      });
      Navigator.of(context).pop();
    }
  }

// open in 3rd app by me

/*  Future<void> openFile(String openResult) async {
    // Dio dio = Dio();
    final filePath1 = '/sdcard/';
    // final filePath = '/Users/chendong/Downloads/S91010-16435053-221705-o_1dmqeua2a2v2o0u126l1baqqc21e-uid-1817947@1080x2160.jpg';
    // await dio.download("https://imgsa.baidu.com/exp/w=500/sign=9d6f3ebe35d3d539c13d0fc30a86e927/7aec54e736d12f2eedbdb0204cc2d56285356831.jpg", filePath);

    final result = await OpenFile.open(filePath1);

    setState(() {
      openResult = "type=${result.type}  message=${result.message}";
    });

  }*/

  Future<String> getTaskId(id) async {
    int userId = await getInt(USER_ID, defaultValue: 0);
    printLogs(userId.toString() + "_" + id);
    return userId.toString() + "_" + id;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();
    _tasks = _TaskInfo(
        name: widget.downloads.name,
        link: widget.downloads.file,
        taskId: await getTaskId(widget.downloads.id));
    tasks?.forEach((task) {
      if (_tasks.link == task.url) {
        _tasks.taskId = task.taskId;
        _tasks.status = task.status;
        _tasks.progress = task.progress;
      }
    });
    var fileName = await getBookFileName(widget.mBookId, _tasks.link);
    String filePath = await getBookFilePath(widget.mBookId, _tasks.link);
    String path = await localPath;
    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }

    if (_tasks.status == DownloadTaskStatus.complete) {
      FlutterDownloader.remove(
          taskId: _tasks.taskId, shouldDeleteContent: false);
      insertIntoDb(filePath);
      _openDownloadedFile(filePath);
      print('delete one $filePath');
      setState(() {
        isDownloadFile = true;
      });
    } else if (_tasks.status == DownloadTaskStatus.paused) {
      _resumeDownload(_tasks);
    } else if (_tasks.status == DownloadTaskStatus.undefined) {
      _tasks.taskId = await FlutterDownloader.enqueue(
          url: _tasks.link,
          fileName: fileName,
          savedDir: path,
          showNotification: true,
          openFileFromNotification: false);
    } else if (_tasks.status == DownloadTaskStatus.failed) {
      _retryDownload(_tasks);
    }
  }

 /*
    ------------------
*/
  void insertIntoDb(filePath) async {
    /**
     * Store data to db for offline usage
     */
    DownloadedBook _download = DownloadedBook();
    _download.bookId = widget.mBookId;
    _download.bookName = widget.mBookName;
    _download.frontCover = widget.mBookImage;
    _download.fileType = widget.isPDFFile ? "PDF File" : "EPub File";
    _download.filePath = filePath;
    _download.userId = userId.toString();
    _download.fileName = widget.downloads.name;
    await dbHelper.insert(_download);
  }
}

class _TaskInfo {
  final String name;
  final String link;
  String taskId;

  int progress = 0;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link, this.taskId});
}
