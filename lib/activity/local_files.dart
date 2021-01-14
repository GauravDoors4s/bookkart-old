import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AudioBookPlayer.dart';
// import 'AudioBookPlayer.dart';

// ignore: must_be_immutable
class LocalFiles extends StatefulWidget {
  LocalFiles({Key key, this.title}) : super(key: key);

  String title;
  @override
  _LocalFilesState createState() => _LocalFilesState();
}

class _LocalFilesState extends State<LocalFiles> with WidgetsBindingObserver {
  static const platform = const MethodChannel('openFiles');

  String openFileUrl;

  @override
  void initState() {
    super.initState();
    getOpenFileUrl();
    // Listen to lifecycle events.
    WidgetsBinding.instance.addObserver(this);
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
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.yellow,
        child: Text("Audio file: " + (openFileUrl != null ? openFileUrl : "Nothing!")),
      ),
    );
  }

  void getOpenFileUrl() async {
    dynamic url = await platform.invokeMethod("getOpenFileUrl");
    print(getOpenFileUrl);
    print('here is the url of the file manager FILE-------- ${openFileUrl} ------------');
    if (url != null && url != openFileUrl) {
/*      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioBookPlayer(
            url: openFileUrl,
            bookImage: null,
            bookName: null,
          ),
        ),
      );*/
      setState(() {
        openFileUrl = url;
      });
    }
  }
}
