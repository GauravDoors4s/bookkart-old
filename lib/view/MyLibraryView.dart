import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/BookDetails.dart';
import 'package:flutterapp/activity/DashboardActivity.dart';
import 'package:flutterapp/activity/ErrorView.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/adapterView/PurchasedBookList.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/BookPurchaseResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class MyLibraryView extends StatefulWidget {
  @override
  _MyLibraryViewState createState() => _MyLibraryViewState();
}

class _MyLibraryViewState extends State<MyLibraryView> {
  bool mIsLoading = false;
  var mOrderList = List<BookPurchaseResponse>();
  var mBookList = List<LineItems>();
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
        await getPurchasedRestApi().then((res) async {
          printLogs(res.toString());
          Iterable order = res;
          mOrderList = order
              .map((model) => BookPurchaseResponse.fromJson(model))
              .toList();
          mBookList.clear();
          setString(LIBRARY_DATA, jsonEncode(res));
          printLogs(mOrderList.length.toString());
          for (var i = 0; i < mOrderList.length; i++) {
            printLogs(mOrderList[i].lineItems.length.toString());
            if (mOrderList[i].lineItems.length > 0) {
              mBookList.addAll(mOrderList[i].lineItems);
            }
          }
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
    Widget blankView = Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(spacing_standard_30),
            child: Image.asset(
              "logo.png",
              width: 150,
            ),
          ),
          Text(
            keyString(context, "lbl_you_don_t_have_any_purchased_book"),
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
              value: keyString(context, "lbl_purchased_now"),
              onPressed: () {
                DashboardActivity().launch(context);
              },
            ),
          )
        ],
      ),
    );

    Widget mainView = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 50),
        width: MediaQuery.of(context).size.width,
        child: (mBookList.length < 1)
            ? blankView
            : Container(
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
                      keyString(context, "lbl_your_purchased_library"),
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
                            child: PurchasedBookList(mBookList[index]),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetails(
                                  mBookList[index].productId.toString(),
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
      ),
    );

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      body: Stack(
        alignment: Alignment.center,
        children: [
          (!mIsLoading)
              ? mainView
              : appLoaderWidget.center().visible(mIsLoading),
        ],
      ),
    );
  }
}
