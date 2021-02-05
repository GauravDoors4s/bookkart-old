import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/model/pdfBookMark.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/pref.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/database_helper.dart';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';

// ignore: must_be_immutable
class ViewEPubFileNew extends StatefulWidget {
  Downloads downloads;
  static String tag = '/EpubFiles';
  String mBookId, mBookName, mBookImage;
  final TargetPlatform platform;
  bool isPDFFile = false;
  bool _isFileExist = false;
  String pageMark;

  ViewEPubFileNew(this.mBookId, this.mBookName, this.mBookImage, this.downloads,
      this.platform, this.isPDFFile, this._isFileExist);

  @override
  ViewEPubFileNewState createState() => ViewEPubFileNewState();
}

class ViewEPubFileNewState extends State<ViewEPubFileNew> {
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
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
  int pages = 0;
  bool isReady = false;
  String errorMessage = '';
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getSaveSharedData();
    initialDownload();
  }

  Future getSaveSharedData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _loadData();
  }

  // ignore: missing_return
  Future initialDownload() async {
    if (widget._isFileExist) {
      String filePath =
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
/*    var mCurrentPAgeData = await getInt(PAGE_NUMBER + widget.mBookId);
    print("Page" + mCurrentPAgeData.toString());
    if (mCurrentPAgeData != null && mCurrentPAgeData.toString().isNotEmpty) {
      currentPage = mCurrentPAgeData;
    } else {
      currentPage = 0;
    }*/

    if( widget.mBookId == pageMarksList[0].id){
      _loadData();
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

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  List<PdfBookMark> pageMarksList = List<PdfBookMark>();
  List<int> localMarksList = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: widget.downloads.name, actions: <Widget>[
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
            _loadData();
          },
        ),
      ]),
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
            : !widget.isPDFFile
                ? SizedBox()
                : Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: PDFView(
                      filePath: fullFilePath,
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
                        /*    setInt(PAGE_NUMBER + widget.mBookId.toString(), page);*/
                        setState(() {
                          currentPage = page;
                        });
                      },
                      defaultPage: currentPage,
                    ),
                  ),
      ),
      floatingActionButton: GestureDetector(
          onTap: () async {
            if (pageMarksList.length < 1) {
/*              marksList.insert(0, currentPage);
              pageMarksList.insert(
                  0, PdfBookMark(id: widget.mBookId, marksList: marksList));*/

              _saveData();
              flushBar("Bookmark Added");
              print('bookmark in null condition');
            } else if (!pageMarksList.contains(currentPage)) {
              /*          marksList.insert(0, currentPage);
              pageMarksList.insert(
                  0, PdfBookMark(id: widget.mBookId, marksList: marksList));*/
              _saveData();
              flushBar("Bookmark Added");
              print('bookmark in 2 condition');
            } else {
              flushBar("Bookmark Already Exists");
              print('bookmark in 3 condition');
            }
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
                        child: (pageMarksList.length > 0)
                            ? FutureBuilder<PDFViewController>(
                                future: _controller.future,
                                builder: (context,
                                    AsyncSnapshot<PDFViewController> snapshot) {
                                  if (snapshot.hasData) {
                                    return ListView.builder(
                                      itemCount: pageMarksList.length,
                                      itemBuilder: (context, int index) {
                                        return ListTile(
                                          dense: false,
                                          onTap: () async {
                                            await snapshot.data.setPage(
                                                pageMarksList[index]
                                                    .marksList[index]);
                                            Navigator.pop(context);
                                            print(snapshot);
                                            print(
                                                'PageMarked @ $index, ${localMarksList[index]}');
                                          },
                                          title: Text(
                                              'Page No ${pageMarksList[index].marksList[index].toString()}'),
                                          trailing: GestureDetector(
                                              onTap: () {
                                                print(
                                                    'delete clicked in bottom sheet');
                                                state(() {
                                                  Pref().deleteValueByKey(
                                                      "eventKey");
                                                  /*    events.bookMark[index].marksList
                                                      .removeAt(index);*/
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
        }
      } on Exception catch (e) {
        epubLocator = EpubLocator();
        await removeKey('locator');
      }

      EpubViewer.open(Platform.isAndroid ? filePath : filePath,
          lastLocation: epubLocator);

      EpubViewer.locatorStream.listen((locator) {
        var epubMark = locator;
        setString('locator', locator);
        print(epubMark);
      });
      Navigator.of(context).pop();
    }
  }

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

  void flushBar(String content) {
    Flushbar(
      message: content,
      duration: Duration(seconds: 2),
    )..show(context);
  }

  _loadData() {
    List<String> dataLoad = sharedPreferences.getStringList('key');
    if (dataLoad != null) {
      pageMarksList = dataLoad.map((e) => jsonDecode(e)).toList().toSet().toList();
      setState(() {});
    }
    print('in load $dataLoad');
    print('in load pageMarklist $pageMarksList');
  }
  List<String> dataSave = [];
  _saveData() async {
    localMarksList.insert(0, currentPage);
    pageMarksList.insert(0, PdfBookMark(id: widget.mBookId, marksList: localMarksList));
    dataSave = pageMarksList.map((e) => jsonEncode(e)).toSet().toList();
    await sharedPreferences.setStringList('key', dataSave);
    print('in save $dataSave');
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
