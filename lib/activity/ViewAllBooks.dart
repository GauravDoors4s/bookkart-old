import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/activity/BookDetails.dart';
import 'package:flutterapp/adapterView/BookList.dart';
import 'package:flutterapp/model/AllBookListResponse.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/Strings.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';

// ignore: must_be_immutable
class ViewAllBooks extends StatefulWidget {
  bool newestBook;
  bool futureBook;
  bool youMayLikeBook;
  bool suggestionBook;
  bool isCategoryBook;
  String categoryId;
  String categoryName;
  String title;

  @override
  _ViewAllBooksState createState() => _ViewAllBooksState();

  ViewAllBooks(
      {this.newestBook = false,
      this.futureBook = false,
      this.isCategoryBook = false,
      this.categoryId = "",
      this.categoryName = "",
      this.suggestionBook = false,
      this.youMayLikeBook = false,
      this.title = ""});
}

class _ViewAllBooksState extends State<ViewAllBooks> {
  bool mIsLoading = false;
  int pageNumber = 1;
  int totalPages = 1;
  String title = "";
  String description = "";
  var mBookList = List<BookInfoDetails>();
  bool isLastPage = false;
  var scrollController = new ScrollController();

  var newestBookRequest = {
    "newest": "newest",
    "product_per_page": books_per_page,
  };

  var youMayLikeBookRequest = {
    'special_product': 'you_may_like',
    'product_per_page': books_per_page,
  };

  var suggestionBookRequest = {
    'special_product': 'suggested_for_you',
    'product_per_page': books_per_page,
  };

  var futureBookRequest = {
    'featured': 'product_visibility',
    'product_per_page': books_per_page,
  };

  @override
  void initState() {
    super.initState();
    getViewAllBookData();
    scrollController.addListener(() {
      scrollHandler();
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  scrollHandler() {
    if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent &&
        !isLastPage) {
      pageNumber++;
      getViewAllBookData();
    }
  }

  Future getViewAllBookData() async {
    setState(() {
      mIsLoading = true;
    });
    var request;
    if (widget.newestBook) {
      request = newestBookRequest;
      title = newest_books;
      description = newest_books_desc;
    } else if (widget.youMayLikeBook) {
      request = youMayLikeBookRequest;
      title = you_may_like;
      description = you_may_like_desc;
    } else if (widget.suggestionBook) {
      request = suggestionBookRequest;
      title = books_for_you;
      description = book_store_desc;
    } else if (widget.futureBook) {
      request = futureBookRequest;
      title = featured_books;
      description = featured_books_desc;
    } else if (widget.isCategoryBook) {
      var catBookRequest = {
        "category": [widget.categoryId],
        'product_per_page': books_per_page,
      };
      request = catBookRequest;
      title = widget.categoryName;
      description = featured_books_desc;
    }

    request.addAll({"page": pageNumber});

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAllBookRestApi(request).then((res) {
          AllBookListResponse response = AllBookListResponse.fromJson(res);
          if (response.data.length > 0) {
            mBookList.addAll(response.data);
            isLastPage = false;
            totalPages = response.numOfPages;
          } else {
            isLastPage = true;
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
    Widget mainView = SingleChildScrollView(
      controller: scrollController,
      primary: false,
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: spacing_standard, right: spacing_standard),
              child: new GridView.builder(
                itemCount: mBookList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            )
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(
        context,
        title: widget.title == "" ? title : widget.title,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: mainView,
          ).visible(mBookList.isNotEmpty),
          (mBookList.isNotEmpty)
              ? Center(child: viewMoreDataLoader.visible(mIsLoading))
              : Center(child: appLoaderWidget.center().visible(mIsLoading))
        ],
      ),
    );
  }
}
