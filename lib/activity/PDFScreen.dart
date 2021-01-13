import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class PDFScreen extends StatefulWidget  {
  static String tag = '/PDFScreen';
  String mBookId,mBookPath,mTitle;
  PDFScreen(this.mBookId,this.mBookPath,this.mTitle);

  @override
  PDFScreenState createState() => PDFScreenState();
}

class PDFScreenState extends State<PDFScreen> {
  int currentPage = 0;
  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async{
    //
    setState(() {
      mIsLoading = true;
    });
    var mCurrentPAgeData = await getInt(PAGE_NUMBER_OFFLINE + widget.mBookId);
    print("Page" + mCurrentPAgeData.toString());
    if (mCurrentPAgeData != null && mCurrentPAgeData.toString().isNotEmpty) {
      currentPage = mCurrentPAgeData;
      setState(() {
        mIsLoading = false;
      });
    } else {
      currentPage = 0;
      setState(() {
        mIsLoading = false;
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: widget.mTitle),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.mBookPath,
            pageSnap: false,
            swipeHorizontal: false,
            onPageChanged: (int page, int total) {
              print('page change: $page/$total');
              setInt(PAGE_NUMBER_OFFLINE + widget.mBookId.toString(), page);
              setState(() {
                currentPage = page;
              });
            },
            defaultPage: currentPage,
          ).visible(!mIsLoading),
          appLoaderWidget.center().visible(mIsLoading)
        ],
      ),
    );
  }
}