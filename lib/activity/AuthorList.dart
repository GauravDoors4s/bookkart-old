import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/adapterView/AuthorListItem.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/AuthorListResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:admob_flutter/admob_flutter.dart';
import '../main.dart';
import 'AuthorDetails.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';

class AuthorList extends StatefulWidget {
  static var tag = "/AuthorList";

  @override
  _AuthorListState createState() => _AuthorListState();
}

class _AuthorListState extends State<AuthorList> {
  bool mIsLoading = false;
  var mAuthorList = List<AuthorListResponse>();
  var mSearchCont = TextEditingController();
  String mSearchText = "";
  List<AuthorListResponse> mSearchList = List();

  @override
  void initState() {
    super.initState();
    getAuthorList();
  }

  @override
  void dispose() {
    mSearchCont.dispose();
    super.dispose();
  }

  Future getAuthorList() async {
    mIsLoading = true;
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAuthorListRestApi().then((res) async {
          mIsLoading = false;
          Iterable mCategory = res;
          mAuthorList.clear();
          setState(() {
            mAuthorList = mCategory
                .map((model) => AuthorListResponse.fromJson(model))
                .toList();
            mSearchList = mAuthorList;
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

  String getAuthorName(authorListResponse) {
    return authorListResponse.firstName + " " + authorListResponse.lastName;
  }

  Widget mSearch() {
    return Container(
      decoration: boxDecoration(
          showShadow: true, radius: 10, bgColor: appStore.editTextBackColor),
      alignment: Alignment.center,
      width: double.infinity,
      child: TextField(
        controller: mSearchCont,
        cursorColor: primaryColor,
        maxLines: 1,
        onChanged: (string) {
          setState(() {
            mSearchList = mAuthorList
                .where((u) =>
                    (u.firstName.toLowerCase().contains(string.toLowerCase()) ||
                        u.firstName.toLowerCase().contains(string.toLowerCase())))
                .toList();
          });
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 18,
          color: appStore.appTextPrimaryColor,
        ),
        decoration: InputDecoration(
          hintText: keyString(context, "lbl_search_by_author_name"),
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: primaryTextStyle(
              color: appStore.textSecondaryColor, size: 18),
          fillColor: appStore.editTextBackColor,
          prefixIcon: Icon(
            Icons.search,
            color: appStore.iconColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainView = SingleChildScrollView(
      primary: false,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            20.height,
            mSearch(),
            Text(
              keyString(context, "lbl_no_data_found"),
              style: boldTextStyle(size: 18),
            ).paddingOnly(top: 20).visible(mSearchList.isEmpty),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: AuthorListItem(mSearchList[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AuthorDetails(
                          mSearchList[index],
                          mSearchList[index].gravatar,
                          getAuthorName(mSearchList[index]),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: mSearchList.length,
                shrinkWrap: true,
              ),
            ),
          ],
        ),
      ).visible(mAuthorList.isNotEmpty),
    );
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: keyString(context, "lbl_author")),
      body: RefreshIndicator(
        onRefresh: () {
          return getAuthorList();
        },
        child: Stack(alignment: Alignment.center, children: [
          mainView,
          appLoaderWidget.center().visible(mIsLoading),
        ]),
      ),
      bottomNavigationBar: AdmobBanner(
        adUnitId: getBannerAdUnitId(),
        adSize: AdmobBannerSize.BANNER,
      ).visible(isAdsLoading==true),
    );
  }
}
