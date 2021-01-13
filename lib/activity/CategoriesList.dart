import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/adapterView/CategoriesItem.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/CategoriesListResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';
import 'ViewAllBooks.dart';

// ignore: must_be_immutable
class CategoriesList extends StatefulWidget {
  static var tag = "/CategoriesList";
  bool _isShowBack = true;

  CategoriesList({isShowBack = true}) {
    _isShowBack = isShowBack;
  }

  @override
  _CategoriesListState createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  bool mIsLoading = false;
  var mCategoriesList = List<CategoriesListResponse>();
  int page = 1;
  int mPerPage = 20;
  bool isLastPage = false;
  var scrollController = new ScrollController();
  var mSearchCont = TextEditingController();
  String mSearchText = "";
  List<CategoriesListResponse> mSearchList = List();

  @override
  void initState() {
    super.initState();
    getCategoriesList(page);
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
    mSearchCont.dispose();
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      page++;
      getCategoriesList(page);
    }
  }

  Future getCategoriesList(page) async {
    setState(() {
      mIsLoading = true;
    });

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getCatListRestApi(page, mPerPage).then((res) async {
          setState(() {
            Iterable mCategory = res;
            mIsLoading = false;
            mCategoriesList.addAll(mCategory
                .map((model) => CategoriesListResponse.fromJson(model))
                .toList());
            isLastPage = false;
            mSearchList = mCategoriesList;
          });
        }).catchError((onError) {
          setState(() {
            isLastPage = true;
            mIsLoading = false;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          isLastPage = true;
          mIsLoading = false;
        });
        NoInternetConnection().launch(context);
      }
    }).catchError((error) {
      setState(() {
        isLastPage = true;
        mIsLoading = false;
      });
      printLogs(error.toString());
      ErrorView(
        message: error.toString(),
      ).launch(context);
    });
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
            mSearchList = mCategoriesList
                .where((u) =>
                    (u.name.toLowerCase().contains(string.toLowerCase()) ||
                        u.name.toLowerCase().contains(string.toLowerCase())))
                .toList();
          });
        },
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 18,
          color: appStore.appTextPrimaryColor,
        ),
        decoration: InputDecoration(
          hintText: keyString(context, "lbl_search_by_categories"),
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
      controller: scrollController,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            10.height,
            mSearch().visible(mCategoriesList.isNotEmpty),
            Text(
              keyString(context, "lbl_no_data_found"),
              style: boldTextStyle(size: 18),
            ).paddingOnly(top: 20).visible(mSearchList.isEmpty),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: CategoriesItem(mSearchList[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAllBooks(
                          isCategoryBook: true,
                          categoryId: mSearchList[index].id.toString(),
                          categoryName: mSearchList[index].name,
                        ),
                      ),
                    ),
                  );
                },
                itemCount: mSearchList.length,
                shrinkWrap: true,
              ),
            ).visible(mSearchList.isNotEmpty),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: appBar(context,
          title: keyString(context, "lbl_categories"),
          showBack: widget._isShowBack),
      backgroundColor: appStore.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: () {
          page = 1;
          mCategoriesList.clear();
          return getCategoriesList(page);
        },
        child: ListView(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.85,
              child: mainView,
            ).visible(mCategoriesList.isNotEmpty),
            (mCategoriesList.isNotEmpty)
                ? viewMoreDataLoader.visible(mIsLoading)
                : appLoaderWidget.center().visible(mIsLoading),
          ],
        ),
      ),
    );
  }
}
