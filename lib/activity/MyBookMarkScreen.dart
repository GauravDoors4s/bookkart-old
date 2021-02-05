import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/activity/BookDetails.dart';
import 'package:flutterapp/activity/DashboardActivity.dart';
import 'package:flutterapp/adapterView/BookmarkBookList.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/BookmarkResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';

class MyFavBookScreen extends StatefulWidget {
  static var tag = "/MyBookMarkScreen";

  @override
  _MyFavBookScreenState createState() => _MyFavBookScreenState();
}

class _MyFavBookScreenState extends State<MyFavBookScreen> {
  bool mIsLoading = false;
  var mBookList = List<BookmarkResponse>();
  String firstName = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getBookmarkBooks();
  }

  Future getUserDetails() async {
    firstName = "Hello, " + await getString(FIRST_NAME);
  }

  Future getBookmarkBooks() async {
    setState(() {
      mIsLoading = true;
    });

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getBookmarkRestApi().then((res) async {
          Iterable mCategory = res;
          mBookList.clear();
          mBookList = mCategory
              .map((model) => BookmarkResponse.fromJson(model))
              .toList();
          setState(() {
            mIsLoading = false;
          });
        }).catchError((onError) {
          setState(() {
            mIsLoading = false;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          mIsLoading = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget blankView() {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(spacing_standard_30),
                        child: Image.asset(
                          "logo.png",
                          width: 150,
                        )),
                    Text(
                      keyString(context, "lbl_you_don_t_have_a_bookmark"),
                      style: TextStyle(
                          fontSize: fontSizeLarge,
                          color: appStore.appTextPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    FittedBox(
                      child: AppButton(
                        value: keyString(context, "lbl_bookmark_now"),
                        onPressed: () {
                          DashboardActivity().launch(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget mainView = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 50, left: 8, right: 8, bottom: 50),
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (mBookList.length < 1)
                ? blankView()
                : Container(
                    padding: EdgeInsets.only(top: 10, left: 8, right: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          firstName,
                          style: TextStyle(
                            fontSize: fontSizeMedium,
                            color: appStore.appTextPrimaryColor,
                          ),
                        ),
                        Text(
                          keyString(context, "lbl_your_bookmark_library"),
                          style: TextStyle(
                              fontSize: fontSizeXxxlarge,
                              color: appStore.textSecondaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          child: new GridView.builder(
                            itemCount: mBookList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: getChildAspectRatio(),
                              crossAxisCount: getCrossAxisCount(),
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                child: BookmarkBookList(mBookList[index]),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetails(
                                      mBookList[index].proId.toString(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, showTitle: false),
      body: Stack(alignment: Alignment.center, children: [
        (!mIsLoading) ? mainView : appLoaderWidget.center().visible(mIsLoading),
      ]),
    );
  }
}
