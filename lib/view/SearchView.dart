import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/activity/BookDetails.dart';
import 'package:flutterapp/activity/ErrorView.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/adapterView/BookList.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/AllBookListResponse.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class SearchView extends StatefulWidget {
  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  var searchByBook = TextEditingController();
  bool mIsLoading = false;
  bool isNoSearchResultFound = false;
  int pageNumber = 1;
  int totalPages = 1;
  var mBookList = List<BookInfoDetails>();
  bool isLastPage = false;
  var scrollController = new ScrollController();
  String mSearchText = "";
  var searchHistory = List<String>();

  @override
  void initState() {
    super.initState();
    getSearchHistory();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  getSearchHistory() async {
    searchHistory = await getSearchValue();
    setState(() {});
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      pageNumber++;
      if (totalPages >= pageNumber) {
        getViewAllBookData(mSearchText);
      }
    }
  }

  Future getViewAllBookData(searchText, {bool isNewSearch = false}) async {
    if (isNewSearch) {
      mBookList.clear();
      pageNumber = 1;
    }
    this.mSearchText = searchText;
    setState(() {
      mIsLoading = true;
    });

    var request = {
      'text': searchText.toString(),
      'product_per_page': books_per_page,
    };

    request.addAll({"page": pageNumber});

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAllBookRestApi(request).then((res) {
          AllBookListResponse response = AllBookListResponse.fromJson(res);
          if (response.data.length > 0) {
            isNoSearchResultFound = false;
            mBookList.addAll(response.data);
            totalPages = response.numOfPages;
          }
          setState(() {
            if (mBookList.length == 0 && response.data.length < 1) {
              isNoSearchResultFound = true;
            }
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
    }).catchError((error) {
      if (!mounted) return;
      setState(() {
        isLastPage = true;
        setState(() {
          mIsLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget blankView = Container(
      child: Container(
        height: 300,
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
                    keyString(context, "lbl_no_book_found"),
                    style: TextStyle(
                      fontSize: fontSizeLarge,
                      color: appStore.appTextPrimaryColor,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Widget bookView = Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: new GridView.builder(
            itemCount: mBookList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: getChildAspectRatio(),
              crossAxisCount: getCrossAxisCount(),
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                child: BookItem(mBookList[index]),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetails(
                      mBookList[index].id.toString(),
                    ),
                  ),
                ),
              );
            },
          ),
        ).visible(mBookList.length > 0),
        blankView.visible(isNoSearchResultFound),
      ],
    );

    Widget search() {
      return Container(
        margin: EdgeInsets.only(top: 8),
        alignment: Alignment.center,
        decoration: boxDecoration(
            showShadow: true, radius: 10, bgColor: appStore.editTextBackColor),
        width: double.infinity,
        child: TextFormField(
            controller: searchByBook,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 18,
              color: appStore.appTextPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: keyString(context, "lbl_search_for_books"),
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
            onFieldSubmitted: (term) {
              hideKeyboard(context);
              addToSearchArray(searchByBook.text);
              getSearchHistory();
              getViewAllBookData(searchByBook.text, isNewSearch: true);
            }).paddingOnly(left: 4, right: 4),
      );
    }

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      body: SingleChildScrollView(
        controller: scrollController,
        primary: false,
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 50),
          padding: EdgeInsets.only(
            top: 60,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  keyString(context, "lbl_search"),
                  style: TextStyle(
                      fontSize: font_size_36,
                      color: appStore.appTextPrimaryColor,
                      fontWeight: FontWeight.normal),
                ),
              ),
              search(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.70 - 40,
                    child: Text(
                      keyString(context, "lbl_recent_search"),
                      style: TextStyle(
                          fontSize: fontSizeLarge,
                          color: appStore.appTextPrimaryColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * 0.35 - 40,
                      child: Text(
                        keyString(context, "lbl_clear_all"),
                        style: TextStyle(
                          fontSize: fontSizeMedium,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ),
                    onTap: () {
                      clearSearchHistory();
                      getSearchHistory();
                    },
                  ),
                ],
              ).visible(searchHistory.length > 0),
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 1.0, // gap between lines
                children: searchHistory
                    .map(
                      (item) => GestureDetector(
                        child: Chip(
                          backgroundColor: appStore.appColorPrimaryLightColor,
                          label: Text(
                            item,
                            style: TextStyle(
                                color: primaryColor, fontSize: fontSizeMedium),
                          ),
                        ),
                        onTap: () {
                          hideKeyboard(context);
                          getViewAllBookData(item, isNewSearch: true);
                        },
                      ),
                    )
                    .toList()
                    .cast<Widget>(),
              ).visible(searchHistory.length > 0),
              Padding(
                padding: const EdgeInsets.only(top: spacing_standard_new),
                child: Text(
                  keyString(context, "lbl_search_result_from") +
                      " \"" +
                      mSearchText +
                      "\"",
                  style: TextStyle(
                      fontSize: fontSizeLarge,
                      color: appStore.appTextPrimaryColor,
                      fontWeight: FontWeight.bold),
                ).visible(mSearchText.length > 0),
              ).visible(!mIsLoading),
              Container(
                child: bookView,
              ).visible(mBookList.isNotEmpty),
              (mBookList.isNotEmpty)
                  ? Center(child: viewMoreDataLoader.visible(mIsLoading))
                  : CircularProgressIndicator().center().visible(mIsLoading)
            ],
          ),
        ),
      ),
    );
  }
}
