import 'package:flutter/material.dart';
import 'dart:async';
import 'package:epub_viewer/epub_viewer.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class External extends StatefulWidget {
  @override
  _ExternalState createState() => _ExternalState();
}

class _ExternalState extends State<External> {
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  @override
  void initState() {
    super.initState();

    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        print("Shared:" + (_sharedFiles?.map((f) => f.path)?.join(",") ?? ""));
        _sharedFiles = value;
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
    });
    print(_sharedText);
    getOpenFileUrl();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  void getOpenFileUrl() async {
// for epub

    EpubViewer.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "iosBook",
        scrollDirection: EpubScrollDirection.VERTICAL,
        allowSharing: true,
        enableTts: true,
        nightMode: false);
    EpubViewer.open(
      _sharedText,
    );
    print('****** $_sharedText  *******  IN EPUBVIEWER');

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
      } */
  }

  @override
  Widget build(BuildContext context) {
    const textStyleBold = const TextStyle(fontWeight: FontWeight.bold);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('files'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Text("Shared files:", style: textStyleBold),
              Text(_sharedFiles?.map((f) => f.path)?.join(",") ?? ""),
              SizedBox(height: 100),
              Text("Shared urls/text:", style: textStyleBold),
              Text(_sharedText ?? "")
            ],
          ),
        ),
      ),
    );
  }
}
