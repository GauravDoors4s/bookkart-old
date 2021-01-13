import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutterapp/activity/BookDetails.dart';
import 'package:flutterapp/activity/ErrorView.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/activity/ViewAllBooks.dart';
import 'package:flutterapp/adapterView/BookList.dart';
import 'package:flutterapp/adapterView/HeaderView.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/HeaderModel.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:html/parser.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_state.dart';

class BookStoreView extends StatefulWidget {
  static String tag = '/BookStoreView';

  @override
  _BookStoreViewState createState() => _BookStoreViewState();
}

class _BookStoreViewState extends State<BookStoreView> {
  var mNewestBookModel = List<BookInfoDetails>();
  var mFeaturedBookModel = List<BookInfoDetails>();
  var mSuggestedBooksModel = List<BookInfoDetails>();
  var mYouMayLikeBooksModel = List<BookInfoDetails>();
  var mCategoryList = List<Category>();
  var mHeaderModel = List<HeaderModel>();
  bool mIsLoading = false;
  String firstName = "";
  SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getDashboardData();
  }

  Future getUserDetails() async {
    firstName = "Hello, " + await getString(FIRST_NAME, defaultValue: "Guest");
  }

  String parseHtmlString(String htmlString) {
    return parse(parse(htmlString).body.text).documentElement.text;
  }

  /// Get Dashboard data from server
  Future getDashboardData() async {
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        setState(() {
          mIsLoading = true;
        });
        await getDashboardDataRestApi().then((res) {
          DashboardResponse dashboardResponse = DashboardResponse.fromJson(res);

          if (res['social_link'] != null) {
            getSharedPref().then((pref) {
              pref.setString(WHATSAPP, res['social_link']['whatsapp']);
              pref.setString(FACEBOOK, res['social_link']['facebook']);
              pref.setString(TWITTER, res['social_link']['twitter']);
              pref.setString(INSTAGRAM, res['social_link']['instagram']);
              pref.setString(CONTACT, res['social_link']['contact']);
              pref.setString(
                  PRIVACY_POLICY, res['social_link']['privacy_policy']);
              pref.setString(
                  TERMS_AND_CONDITIONS, res['social_link']['term_condition']);
              pref.setString(
                  COPYRIGHT_TEXT, res['social_link']['copyright_text']);
            });
          }

          setString(CURRENCY_SYMBOL,
              parseHtmlString(dashboardResponse.currencySymbol.currencySymbol));
          setString(CURRENCY_NAME, dashboardResponse.currencySymbol.currency);
          setString(LANGUAGE, dashboardResponse.appLang);
          Provider.of<AppState>(context, listen: false)
              .changeLanguageCode(dashboardResponse.appLang);

          appStore.checkRTL(value: dashboardResponse.appLang);
          mNewestBookModel.clear();
          mFeaturedBookModel.clear();
          mSuggestedBooksModel.clear();
          mYouMayLikeBooksModel.clear();
          mHeaderModel.clear();
          mCategoryList.clear();
          mNewestBookModel.addAll(dashboardResponse.newest);
          mFeaturedBookModel.addAll(dashboardResponse.featured);
          mSuggestedBooksModel.addAll(dashboardResponse.suggestedForYou);
          mYouMayLikeBooksModel.addAll(dashboardResponse.youMayLike);

          for (var i = 0; i < dashboardResponse.category.length; i++) {
            if (dashboardResponse.category[i].product.length > 0) {
              mCategoryList.add(dashboardResponse.category[i]);
            }
          }

          createHeaderData(
              mNewestBookModel,
              keyString(context, "header_newest_book_title"),
              keyString(context, "header_newest_book_message"),
              BOOK_TYPE_NEW);
          createHeaderData(
              mFeaturedBookModel,
              keyString(context, "header_featured_book_title"),
              keyString(context, "header_featured_book_message"),
              BOOK_TYPE_FEATURED);
          createHeaderData(
              mSuggestedBooksModel,
              keyString(context, "header_for_you_book_title"),
              keyString(context, "header_for_you_book_message"),
              BOOK_TYPE_SUGGESTION);
          createHeaderData(
              mYouMayLikeBooksModel,
              keyString(context, "header_like_book_title"),
              keyString(context, "header_like_book_message"),
              BOOK_TYPE_LIKE);

          setState(() {
            mIsLoading = false;
          });
        }).catchError((onError) {
          setState(() {
            mIsLoading = false;
          });
          print(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        NoInternetConnection(
          isCloseApp: true,
        ).launch(context);
      }
    });
  }

  createHeaderData(bookModel, title, message, type) async {
    if (bookModel.length > 0) {
      String image1 = "";
      String image2 = "";
      if (bookModel[0].images != null) {
        image1 = bookModel[0].images[0].src.toString();
      }
      if (bookModel.length > 1) {
        if (bookModel[1].images != null) {
          image2 = bookModel[1].images[0].src.toString();
        } else {
          image2 = image1;
        }
      } else {
        image2 = image1;
      }
      mHeaderModel.add(HeaderModel(title, message, image1, image2, type));
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget staticData = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 50, bottom: 20),
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
            ).visible(mNewestBookModel.isNotEmpty).paddingOnly(
                  left: 16,
                  right: 16,
                ),
            Text(
              keyString(context, "book_store_desc"),
              style: TextStyle(
                  fontSize: fontSizeXxxlarge,
                  color: appStore.textSecondaryColor,
                  fontWeight: FontWeight.bold),
            ).visible(mNewestBookModel.isNotEmpty).paddingOnly(
                  left: 16,
                  right: 16,
                ),
            Container(
              height: MediaQuery.of(context).size.width * 0.80,
              child: ListView.builder(
                padding: EdgeInsets.only(right: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: HeaderView(mHeaderModel[index]),
                    onTap: () {
                      if (mHeaderModel[index].type == BOOK_TYPE_NEW) {
                        ViewAllBooks(
                                title: keyString(context, "newest_books"),
                                newestBook: true)
                            .launch(context);
                      } else if (mHeaderModel[index].type ==
                          BOOK_TYPE_FEATURED) {
                        ViewAllBooks(
                                title: keyString(context, "featured_books"),
                                futureBook: true)
                            .launch(context);
                      } else if (mHeaderModel[index].type ==
                          BOOK_TYPE_SUGGESTION) {
                        ViewAllBooks(
                                title: keyString(context, "books_for_you"),
                                suggestionBook: true)
                            .launch(context);
                      } else if (mHeaderModel[index].type == BOOK_TYPE_LIKE) {
                        ViewAllBooks(
                                title: keyString(context, "you_may_like"),
                                youMayLikeBook: true)
                            .launch(context);
                      }
                    },
                  );
                },
                itemCount: mHeaderModel.length,
                shrinkWrap: true,
              ),
            ).visible(mHeaderModel.isNotEmpty),
            Container(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.80,
                                height: 40,
                                child: Center(
                                  child: Html(
                                    data: mCategoryList[index].name,
                                    defaultTextStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSizeLarge,
                                        color: appStore.appTextPrimaryColor),
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: appStore.iconColor,
                                  size: 30.0,
                                  textDirection: appStore.isRTL
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ).paddingOnly(
                          left: 16,
                          right: 8,
                        ),
                        onTap: () {
                          ViewAllBooks(
                            isCategoryBook: true,
                            categoryId: mCategoryList[index].catID.toString(),
                            categoryName: mCategoryList[index].name,
                          ).launch(context);
                        },
                      ),
                      Container(
                        height: bookViewHeight,
                        child: ListView.builder(
                          padding: EdgeInsets.only(right: 8),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, ind) {
                            return new GestureDetector(
                              child: new BookItem(
                                mCategoryList[index].product[ind],
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetails(
                                    mCategoryList[index]
                                        .product[ind]
                                        .id
                                        .toString(),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: mCategoryList[index].product.length,
                          shrinkWrap: true,
                        ),
                      )
                    ],
                  );
                },
                itemCount: mCategoryList.length,
                shrinkWrap: true,
              ),
            ).visible(mCategoryList.isNotEmpty),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.only(
                  top: spacing_standard_new,
                  left: 16,
                  right: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: 40,
                      child: Center(
                        child: Text(
                          keyString(context, "header_newest_book_title"),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeLarge,
                              color: appStore.appTextPrimaryColor),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      child: Icon(
                        Icons.chevron_right,
                        color: appStore.iconColor,
                        size: 30.0,
                        textDirection: appStore.isRTL
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                ViewAllBooks(
                        title: keyString(context, "newest_books"),
                        newestBook: true)
                    .launch(context);
              },
            ).visible(mNewestBookModel.isNotEmpty),
            Container(
              height: bookViewHeight,
              child: ListView.builder(
                padding: EdgeInsets.only(right: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: new BookItem(
                      mNewestBookModel[index],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookDetails(
                              mNewestBookModel[index].id.toString())),
                    ),
                  );
                },
                itemCount: mNewestBookModel.length,
                shrinkWrap: true,
              ),
            ).visible(mNewestBookModel.isNotEmpty),
            GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(
                    top: spacing_standard_new,
                    left: 16,
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            keyString(context, "featured_books"),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeLarge,
                                color: appStore.appTextPrimaryColor),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        child: Icon(
                          Icons.chevron_right,
                          color: appStore.iconColor,
                          size: 30.0,
                          textDirection: appStore.isRTL
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  ViewAllBooks(
                          title: keyString(context, "featured_books"),
                          futureBook: true)
                      .launch(context);
                }).visible(mFeaturedBookModel.isNotEmpty),
            Container(
              height: bookViewHeight,
              child: ListView.builder(
                padding: EdgeInsets.only(right: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: new BookItem(mFeaturedBookModel[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookDetails(
                              mFeaturedBookModel[index].id.toString())),
                    ),
                  );
                },
                itemCount: mFeaturedBookModel.length,
                shrinkWrap: true,
              ),
            ).visible(mFeaturedBookModel.isNotEmpty),
            GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(
                    top: spacing_standard_new,
                    left: 16,
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            keyString(context, "books_for_you"),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeLarge,
                                color: appStore.appTextPrimaryColor),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        child: Icon(
                          Icons.chevron_right,
                          color: appStore.iconColor,
                          size: 30.0,
                          textDirection: appStore.isRTL
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAllBooks(
                        title: keyString(context, "books_for_you"),
                        suggestionBook: true,
                      ),
                    ),
                  );
                }).visible(mSuggestedBooksModel.isNotEmpty),
            Container(
              height: bookViewHeight,
              child: ListView.builder(
                padding: EdgeInsets.only(right: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: BookItem(mSuggestedBooksModel[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookDetails(
                              mSuggestedBooksModel[index].id.toString())),
                    ),
                  );
                },
                itemCount: mSuggestedBooksModel.length,
                shrinkWrap: true,
              ),
            ).visible(mSuggestedBooksModel.isNotEmpty),
            GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(
                    top: spacing_standard_new,
                    left: 16,
                    right: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 40,
                        child: Center(
                          child: Text(
                            keyString(context, "you_may_like"),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeLarge,
                                color: appStore.appTextPrimaryColor),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        child: Icon(
                          Icons.chevron_right,
                          color: appStore.iconColor,
                          size: 30.0,
                          textDirection: appStore.isRTL
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewAllBooks(
                        title: keyString(context, "you_may_like"),
                        youMayLikeBook: true,
                      ),
                    ),
                  );
                }).visible(mYouMayLikeBooksModel.isNotEmpty),
            Container(
              height: bookViewHeight,
              margin: EdgeInsets.only(bottom: 50),
              child: ListView.builder(
                padding: EdgeInsets.only(right: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return new GestureDetector(
                    child: BookItem(mYouMayLikeBooksModel[index]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookDetails(
                              mYouMayLikeBooksModel[index].id.toString())),
                    ),
                  );
                },
                itemCount: mYouMayLikeBooksModel.length,
                shrinkWrap: true,
              ),
            ).visible(mYouMayLikeBooksModel.isNotEmpty),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: () {
          return getDashboardData();
        },
        child: Stack(alignment: Alignment.center, children: [
          (mNewestBookModel.isNotEmpty)
              ? staticData
              : appLoaderWidget.center().visible(mIsLoading),
        ]),
      ),
    );
  }
}
