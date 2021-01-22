import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterapp/activity/ReviewScreen.dart';
import 'package:flutterapp/adapterView/DownloadFilesView.dart';
import 'package:flutterapp/adapterView/Review.dart';
import 'package:flutterapp/adapterView/UpsellBookList.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/confi/application.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/model/AddtoBookmarkResponse.dart';
import 'package:flutterapp/model/CheckoutResponse.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/OrderResponse.dart';
import 'package:flutterapp/model/PaidBookResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/AppPermissionHandler.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'AuthorDetails.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';
import 'SignInScreen.dart';
import 'ViewAllBooks.dart';
import 'WebViewScreen.dart';
// import 'package:admob_flutter/admob_flutter.dart';

// ignore: must_be_immutable
class BookDetails extends StatefulWidget {
  var mBookId = "0";

  BookDetails(this.mBookId);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  var platform;
  bool mIsLoading = false;
  bool mReviewIsLoading = false;
  bool mFetchingFile = false;
  bool mIsFreeBook = false;
  var mBookDetailsList = List<BookInfoDetails>();
  var mBookDetailsData;
  var mSampleFile = "";
  var mCurrencySymbol = "";
  var mDownloadFileArray = List<Downloads>();
  var mDownloadPaidFileArray = List<Downloads>();
  bool isLoginIn = false;

/*  AdmobInterstitial interstitialAd;*/
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  @override
  void initState() {
    super.initState();
    getBookDetails();

    /*  init();*/
  }

/*  init() async {
    isLoginIn = await getBool(IS_LOGGED_IN);
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.opened || event == AdmobAdEvent.completed)
          interstitialAd.dispose();
        handleEvent(event, args, 'Interstitial');
      },
    );
    isAdsLoading ? interstitialAd.load() : SizedBox();
    setState(() {});
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
        showDialog(
          context: scaffoldState.currentContext,
          builder: (BuildContext context) {
            return WillPopScope(
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Reward callback fired. Thanks Andrew!'),
                    Text('Type: ${args['type']}'),
                    Text('Amount: ${args['amount']}'),
                  ],
                ),
              ),
              onWillPop: () async {
                scaffoldState.currentState.hideCurrentSnackBar();
                return true;
              },
            );
          },
        );
        break;
      default:
    }
  }*/

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

/*  @override
  void dispose() async {
    if (await interstitialAd.isLoaded) {
      interstitialAd.show();
    }
    super.dispose();
  }*/

  Future deleteOrder(orderId) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      mFetchingFile = true;
    });
    await isNetworkAvailable().then(
      (bool) async {
        if (bool) {
          await deleteOrderRestApi(orderId).then((res) async {
            setState(() {
              mFetchingFile = false;
            });
          }).catchError((onError) {
            setState(() {
              mFetchingFile = false;
            });
            printLogs(onError.toString());
            ErrorView(
              message: onError.toString(),
            ).launch(context);
          });
        } else {
          setState(() {
            mFetchingFile = false;
          });
          NoInternetConnection().launch(context);
        }
      },
    );
  }

  Future placeOrder() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    int userId = await getInt(USER_ID);
    String currency = await getString(CURRENCY_NAME);

    var request = {
      'currency': currency,
      'customer_id': userId,
      'payment_method': "cod",
      'set_paid': false,
      'status': "pending",
      'transaction_id': "",
      'line_items': [
        {
          'product_id': widget.mBookId,
          'quantity': "1",
        }
      ],
    };

    setState(() {
      mFetchingFile = true;
    });
    await isNetworkAvailable().then(
      (bool) async {
        if (bool) {
          await bookOrderRestApi(request).then((res) async {
            OrderResponse orderResponse = OrderResponse.fromJson(res);
            printLogs(orderResponse.toString());
            var requestCheckout = {
              'order_id': orderResponse.id,
            };

            await checkoutURLRestApi(requestCheckout).then((res) async {
              setState(() {
                mFetchingFile = false;
              });
              CheckoutResponse checkoutResponse =
                  CheckoutResponse.fromJson(res);
              printLogs(checkoutResponse.toString());

              Map results = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                    checkoutResponse.checkoutUrl.toString(),
                    "Payment",
                    orderId: orderResponse.id.toString(),
                  ),
                ),
              );
              if (results != null && results.containsKey('orderCompleted')) {
                getBookDetails(afterPayment: true);
              } else {
                toast(keyString(context, "lbl_payment_cancelled"));
                deleteOrder(orderResponse.id.toString());
              }
            });
          }).catchError((onError) {
            setState(() {
              mFetchingFile = false;
            });
            printLogs(onError.toString());
            ErrorView(
              message: onError.toString(),
            ).launch(context);
          });
        } else {
          setState(() {
            mFetchingFile = false;
          });
          NoInternetConnection().launch(context);
        }
      },
    );
  }


  Future postPlaceOrder() async {
    if (platform == TargetPlatform.android) {
 ApplicationGlobal.requestPermission(() { placeOrder(); });
    }

  }

  Future postReviewApi(review, rating) async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    String firstName =
        await getString(FIRST_NAME) + " " + await getString(LAST_NAME);
    int userId = await getInt(USER_ID);
    String emailId = await getString(USER_EMAIL);
    var request = {
      'product_id': widget.mBookId,
      'reviewer': firstName,
      'user_id': userId,
      'reviewer_email': emailId,
      'review': review,
      'rating': rating
    };
    mReviewIsLoading = true;
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await bookReviewRestApi(request).then((res) async {
          mReviewIsLoading = false;
          getBookDetails();
        }).catchError((onError) {
          setState(() {
            mReviewIsLoading = false;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          mReviewIsLoading = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  Future getBookDetails({afterPayment = false}) async {
    if (afterPayment) {
      setState(() {
        mFetchingFile = true;
      });
    } else {
      mIsLoading = true;
    }

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        var request = {
          'product_id': widget.mBookId,
        };
        await getBookDetailsRestApi(request).then((res) async {
          if (afterPayment) {
            mFetchingFile = false;
          } else {
            mIsLoading = false;
          }
          Iterable mCategory = res;
          mBookDetailsList.clear();
          mBookDetailsList = mCategory
              .map((model) => BookInfoDetails.fromJson(model))
              .toList();
          mBookDetailsData = mBookDetailsList[0];

          if (mBookDetailsData.type == "variable" ||
              mBookDetailsData.type == "grouped" ||
              mBookDetailsData.type == "external") {
            toastLong("Book type not supported");
            Navigator.of(context).pop();
          }

          if (mBookDetailsData.price == "" &&
              mBookDetailsData.salePrice == "" &&
              mBookDetailsData.regularPrice == "") {
            mIsFreeBook = true;
          } else {
            mIsFreeBook = false;
          }

          getBookPrice();

          // Get sample files url
          mDownloadFileArray.clear();
          mSampleFile = "";
          for (var i = 0; i < mBookDetailsData.attributes.length; i++) {
            if (mBookDetailsData.attributes[i].name == SAMPLE_FILE) {
              if (mBookDetailsData.attributes[i].options.length > 0) {
                mSampleFile = "ContainsDownloadFiles";
                var dv = Downloads();
                dv.id = "1";
                dv.name = "Sample File";
                dv.file = mBookDetailsData.attributes[i].options[0].toString();
                mDownloadFileArray.add(dv);
              }
            }
          }
          setState(() {});
        }).catchError((onError) {
          setState(() {
            if (afterPayment) {
              mFetchingFile = false;
            } else {
              mIsLoading = false;
            }
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          if (afterPayment) {
            mFetchingFile = false;
          } else {
            mIsLoading = false;
          }
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  Future removeFromBookmark() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      mBookDetailsData.isAddedWishlist = false;
    });
    var request = {'pro_id': widget.mBookId};
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getRemoveFromBookmarkRestApi(request).then((res) async {
          AddToBookmarkResponse response = AddToBookmarkResponse.fromJson(res);
          if (response.code == "success") {
            setState(() {
              mBookDetailsData.isAddedWishlist = false;
            });
          }
        }).catchError((onError) {
          setState(() {
            mBookDetailsData.isAddedWishlist = false;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          mBookDetailsData.isAddedWishlist = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }
// bookmark
  Future addToBookmark() async {
    if (!await isLoggedIn()) {
      SignInScreen().launch(context);
      return;
    }
    setState(() {
      mBookDetailsData.isAddedWishlist = true;
    });
    var request = {'pro_id': widget.mBookId};
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAddToBookmarkRestApi(request).then((res) async {
          AddToBookmarkResponse response = AddToBookmarkResponse.fromJson(res);
          if (response.code == "success") {
            setState(() {
              mBookDetailsData.isAddedWishlist = true;
            });
          }
        }).catchError((onError) {
          setState(() {
            mBookDetailsData.isAddedWishlist = true;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          mBookDetailsData.isAddedWishlist = true;
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  Future getPaidFileDetails() async {
    setState(() {
      mFetchingFile = true;
    });

    await isNetworkAvailable().then((bool) async {
      if (bool) {
        String time = await getTime();
        var request = {
          'book_id': widget.mBookId,
          'time': time,
          'secret_salt': await getKey(time)
        };
        await getPaidBookFileListRestApi(request).then((res) async {
          setState(() {
            mFetchingFile = false;
          });
          PaidBookResponse paidBookDetails = PaidBookResponse.fromJson(res);

          mDownloadPaidFileArray.clear();
          for (var i = 0; i < paidBookDetails.data.length; i++) {
            printLogs(paidBookDetails.data[i].file.toString());
            var dv = Downloads();
            dv.id = paidBookDetails.data[i].id;
            dv.name = paidBookDetails.data[i].name;
            dv.file = paidBookDetails.data[i].file;
            mDownloadPaidFileArray.add(dv);
          }
          _settingModalBottomSheet(context, mDownloadPaidFileArray);
        }).catchError((onError) {
          setState(() {
            mFetchingFile = false;
          });
          printLogs(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          mFetchingFile = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    platform = Theme.of(context).platform;
    // Set additional information
    Widget getAttribute() {
      return ListView.builder(
        itemCount: mBookDetailsData.attributes.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, i) {
          return Container(
            child: (mBookDetailsData.attributes[i].name != SAMPLE_FILE)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mBookDetailsData.attributes[i].name + " : ",
                        style: TextStyle(
                            fontSize: fontSizeMedium,
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Expanded(
                        child: Text(
                          getAllAttribute(mBookDetailsData.attributes[i]),
                          style: TextStyle(
                              fontSize: fontSizeMedium,
                              color: textSecondaryColor),
                        ),
                      )
                    ],
                  )
                : SizedBox(),
          );
        },
      );
    }

    Widget categoriesList() {
      return Wrap(
        spacing: 4.0, // gap between adjacent chips
        runSpacing: 0.5, // gap between lines
        children: mBookDetailsData.categories
            .map(
              (item) => GestureDetector(
                child: Chip(
                  backgroundColor: Color(0xffF0F4FF),
                  label: DefaultTextStyle.merge(
                    style:
                        TextStyle(color: primaryColor, fontSize: fontSizeSmall),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      children: HtmlParser(width: null).parse(item.name),
                    ),
                  ),
                ),
                onTap: () {
                  ViewAllBooks(
                    isCategoryBook: true,
                    categoryId: item.id.toString(),
                    categoryName: item.name,
                  ).launch(context);
                },
              ),
            )
            .toList()
            .cast<Widget>(),
      );
    }

    Widget mainView = SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              backIcons(context),

              //Bookmark
              Align(
                alignment:
                    appStore.isRTL ? Alignment.topLeft : Alignment.topRight,
                child: GestureDetector(
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: (mBookDetailsData != null)
                          ? (mBookDetailsData.isAddedWishlist)
                              ? Icon(
                                  Icons.bookmark,
                                  color: appStore.iconColor,
                                  size: 30,
                                )
                              : Icon(
                                  Icons.bookmark_border,
                                  color: appStore.iconColor,
                                  size: 30,
                                )
                          : SizedBox()),
                  onTap: () {
                    (mBookDetailsData.isAddedWishlist)
                        ? removeFromBookmark()
                        : addToBookmark();
                  },
                ),
              ),
              (mBookDetailsData != null)
                  ? Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 25),
                          width: bookWidthDetails,
                          height: bookHeightDetails,
                          child: Stack(
                            children: <Widget>[
                              Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Center(
                                    child: Container(
                                        width: bookWidthDetails,
                                        height: bookHeightDetails,
                                        child: bookLoaderWidget),
                                  ),
                                  imageUrl: mBookDetailsData.images[0].src,
                                  fit: BoxFit.fill,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                elevation: 5,
                                margin: EdgeInsets.all(10),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: spacing_standard_new,
                          ),
                          padding: EdgeInsets.only(
                              left: spacing_standard, right: spacing_standard),
                          child: Text(
                            mBookDetailsData.name,
                            style: TextStyle(
                              fontSize: fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: appStore.appTextPrimaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        //View files
                        GestureDetector(
                          onTap: () {
                            (mBookDetailsData.isPurchased || mIsFreeBook)
                                ? getPaidFileList(context)
                                : buyBookBottomSheet(context);
                          },
                          child: Container(
                            margin:
                                EdgeInsets.only(top: 20, left: 20, right: 20),
                            width: MediaQuery.of(context).size.width - 40,
                            height: 50.0001220703125,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                // Shadow Color design
                                Positioned(
                                  top: 29.0001220703125,
                                  left: 26,
                                  child: Container(
                                    width: 250,
                                    height: 21,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color:
                                                Color.fromRGBO(66, 103, 205, 1),
                                            offset: Offset(0, 1),
                                            blurRadius: 40)
                                      ],
                                      color: Color.fromRGBO(255, 210, 111, 1),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0.0001220703125,
                                  left: 0,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                      color: Color.fromRGBO(65, 102, 205, 1),
                                    ),
                                  ),
                                ),
                                (mBookDetailsData.isPurchased || mIsFreeBook)
                                    ? Positioned(
                                        child: Text(
                                          keyString(context, "lbl_view_files"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: font_size_xlarge,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.normal,
                                              height: 1),
                                        ),
                                      )
                                    : Center(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 70),
                                          child: Text(
                                            keyString(context, "lbl_buy_now"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize: font_size_xlarge,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.normal,
                                                height: 1),
                                          ),
                                        ),
                                      ),
                                (mBookDetailsData.isPurchased || mIsFreeBook)
                                    ? SizedBox()
                                    : Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          width: 113.06591796875,
                                          height: 50.0001220703125,
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned(
                                                  top: 0,
                                                  left: 58,
                                                  child: Image.asset(
                                                      "vector8.png")),
                                              Positioned(
                                                  child: Image.asset("bg.png")),
                                              Positioned(
                                                top: 0.0001220703125,
                                                left: 0,
                                                child: Image.asset(
                                                    "intersect.png"),
                                              ),
                                              Positioned(
                                                top: 17,
                                                left: 17,
                                                child: Text(
                                                  mCurrencySymbol,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          255, 255, 255, 1),
                                                      fontSize:
                                                          font_size_xlarge,
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      height: 1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        (mSampleFile.length > 0)
                            ? Container(
                                height: authorImageSize / 2,
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 30),
                                child: GestureDetector(
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          "sunglasses.png",
                                          width: 26,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          keyString(context, "lbl_free_trial"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: fontSizeMedium,
                                            color: appStore.appTextPrimaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    _settingModalBottomSheet(
                                        context, mDownloadFileArray,
                                        isSampleFile: true);
                                  },
                                ),
                              )
                            : SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(32),
                                    topLeft: Radius.circular(32)),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  top: 25,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      keyString(context, "lbl_intro"),
                                      style: TextStyle(
                                          fontSize: fontSizeLarge,
                                          color: appStore.appTextPrimaryColor,
                                          fontWeight: FontWeight.bold),
                                    ).paddingOnly(left: 16, right: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: spacing_standard,
                                          left: 16,
                                          right: 16),
                                      child: Html(
                                        data: mBookDetailsData.description,
                                        defaultTextStyle: TextStyle(
                                          fontSize: fontSizeMedium,
                                          color: appStore.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      keyString(context,
                                          "lbl_additional_information"),
                                      style: TextStyle(
                                          fontSize: fontSizeLarge,
                                          color: appStore.appTextPrimaryColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                        .visible(isSingleSampleFile(
                                            mBookDetailsData.attributes.length))
                                        .paddingOnly(left: 16, right: 16),
                                    getAttribute()
                                        .visible(isSingleSampleFile(
                                            mBookDetailsData.attributes.length))
                                        .paddingOnly(left: 16, right: 16),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 16, right: 16),
                                      child: Text(
                                        keyString(context, "lbl_categories"),
                                        style: TextStyle(
                                            fontSize: fontSizeLarge,
                                            color: appStore.appTextPrimaryColor,
                                            fontWeight: FontWeight.bold),
                                      ).visible(
                                          mBookDetailsData.categories.length >
                                              0),
                                    ),
                                    categoriesList()
                                        .visible(
                                            mBookDetailsData.categories.length >
                                                0)
                                        .paddingOnly(left: 16, right: 16),
                                    GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            left: 16,
                                            right: 16,
                                            top: spacing_standard_new),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                new Container(
                                                  width: authorImageSize,
                                                  height: authorImageSize,
                                                  decoration: new BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: new DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: new NetworkImage(
                                                          mBookDetailsData
                                                              .store.image),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: spacing_standard),
                                                  height: authorImageSize,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        mBookDetailsData
                                                            .store.name
                                                            .toString()
                                                            .trim(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        softWrap: false,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              fontSizeMedium,
                                                          color: appStore
                                                              .appTextPrimaryColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        keyString(context,
                                                            "lbl_tap_to_see_author_details"),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontSize:
                                                              fontSizeSmall,
                                                          color: appStore
                                                              .textSecondaryColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              height: 65,
                                              child: Icon(
                                                Icons.chevron_right,
                                                color:
                                                    appStore.iconSecondaryColor,
                                                size: 32.0,
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
                                            builder: (context) => AuthorDetails(
                                                mBookDetailsData.store,
                                                mBookDetailsData.store.image,
                                                mBookDetailsData.store.name),
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: spacing_standard_30),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            keyString(
                                                context, "lbl_high_recommend"),
                                            style: TextStyle(
                                                fontSize: fontSizeLarge,
                                                color: appStore
                                                    .appTextPrimaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          GestureDetector(
                                            child: Icon(
                                              Icons.chevron_right,
                                              color:
                                                  appStore.iconSecondaryColor,
                                              size: 30.0,
                                              textDirection: appStore.isRTL
                                                  ? TextDirection.rtl
                                                  : TextDirection.ltr,
                                            ),
                                            onTap: () {
                                              ReviewScreen(mBookDetailsData.id)
                                                  .launch(context);
                                            },
                                          )
                                        ],
                                      ),
                                    ).visible(mBookDetailsData.reviewsAllowed),
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: spacing_control_half),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                getAvgReviewCount(
                                                        mBookDetailsData
                                                            .reviews)
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: font_size_42,
                                                  color: appStore
                                                      .appTextPrimaryColor,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  RatingBar(
                                                    allowHalfRating: true,
                                                    initialRating:
                                                        getAvgReviewCount(
                                                            mBookDetailsData
                                                                .reviews),
                                                    minRating: 0,
                                                    itemSize: 15.0,
                                                    direction: Axis.horizontal,
                                                    itemCount: 5,
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate:
                                                        (double value) {},
                                                  ),
                                                  (mBookDetailsData != null)
                                                      ? Text(
                                                          "(" +
                                                              getReviewCount() +
                                                              " " +
                                                              keyString(context,
                                                                  "lbl_reviews") +
                                                              ")",
                                                          style: TextStyle(
                                                            fontSize:
                                                                fontSizeSmall,
                                                            color: appStore
                                                                .textSecondaryColor,
                                                          ),
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                          RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            color: primaryColor,
                                            onPressed: () =>
                                                {showDialog1(context)},
                                            child: Text(
                                              keyString(context, "lbl_review"),
                                              style:
                                                  TextStyle(color: whileColor),
                                            ),
                                          ).visible(isLoginIn &&
                                              (mBookDetailsData.isPurchased ||
                                                  mIsFreeBook)),
                                        ],
                                      ),
                                    ).visible(mBookDetailsData.reviewsAllowed),
                                    (mBookDetailsData.reviewsAllowed)
                                        ? Container(
                                            height: 185,
                                            child: ListView.builder(
                                              padding: EdgeInsets.only(
                                                  left: 16, right: 16),
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return new GestureDetector(
                                                  child: Review(mBookDetailsData
                                                      .reviews[index]),
                                                );
                                              },
                                              itemCount: mBookDetailsData
                                                  .reviews?.length,
                                              shrinkWrap: true,
                                            ),
                                          ).visible(
                                            mBookDetailsData.reviews.length > 0)
                                        : Container(
                                            height: 100,
                                            child: Center(
                                              child: Text(
                                                keyString(context,
                                                    "lbl_no_review_found"),
                                                style: TextStyle(
                                                  fontSize: fontSizeSmall,
                                                  color: appStore
                                                      .textSecondaryColor,
                                                ),
                                              ),
                                            ),
                                          ).visible(
                                            mBookDetailsData.reviewsAllowed),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: spacing_standard_new),
                                      child: Text(
                                        keyString(context,
                                            "lbl_more_books_from_author"),
                                        style: TextStyle(
                                            fontSize: fontSizeLarge,
                                            color: appStore.appTextPrimaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ).visible(
                                        mBookDetailsData.upsellId.length > 0),
                                    (mBookDetailsData.upsellId.length > 0)
                                        ? Container(
                                            height: bookViewHeight,
                                            margin: EdgeInsets.only(bottom: 40),
                                            child: ListView.builder(
                                              padding:
                                                  EdgeInsets.only(right: 25),
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                return new GestureDetector(
                                                  child: UpsellBookList(
                                                      mBookDetailsData
                                                          .upsellId[index]),
                                                );
                                              },
                                              itemCount: mBookDetailsData
                                                  .upsellId.length,
                                              shrinkWrap: true,
                                            ),
                                          ).visible(
                                            mBookDetailsData.upsellId.length >
                                                0)
                                        : SizedBox(
                                            height: 10,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(
                      child: appLoaderWidget.center().visible(mIsLoading),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    )
            ],
          ),
        ],
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.scaffoldBackground,
        body: Stack(
          children: [
            mainView,
            mReviewIsLoading
                ? Container(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  )
                : SizedBox(),
            if (mFetchingFile)
              Center(
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  elevation: 10,
                  margin: EdgeInsets.all(30),
                ),
              )
          ],
        ),
        /*    bottomNavigationBar: Container(
          width: context.width(),
          color: white,
          child: AdmobBanner(
            adUnitId: getBannerAdUnitId(),
            adSize: AdmobBannerSize.BANNER,
          ).visible(isAdsLoading == true),
        ),*/
      ),
    );
  }

  // get Additional Information
  String getAllAttribute(Attributes attribute) {
    String attributes = "";
    for (var i = 0; i < attribute.options.length; i++) {
      attributes = attributes + attribute.options[i];
      if (i < attribute.options.length - 1) {
        attributes = attributes + ", ";
      }
    }
    return attributes;
  }

  String getReviewCount() {
    if (mBookDetailsData.reviews != null) {
      return mBookDetailsData.reviews.length.toString();
    } else {
      return "0";
    }
  }

  bool isSingleSampleFile(int count) {
    if (count == 0) {
      return false;
    } else if (count == 1 && mSampleFile.length > 0) {
      return false;
    }
    return true;
  }

  Future<void> getBookPrice() async {
    mCurrencySymbol = "";
    if (is_Currency_Name) {
      mCurrencySymbol = await getString(CURRENCY_NAME);
      mCurrencySymbol = mCurrencySymbol + " ";
    } else {
      var symbolSign = await getString(CURRENCY_SYMBOL);
      printLogs(symbolSign);
      mCurrencySymbol = symbolSign;
    }
    if (mBookDetailsData.onSale) {
      mCurrencySymbol = mCurrencySymbol + mBookDetailsData.salePrice;
    } else {
      mCurrencySymbol = mCurrencySymbol + mBookDetailsData.regularPrice;
    }
  }

  double getAvgReviewCount(List<Reviews> reviews) {
    double totalReview = 0.0;
    for (var i = 0; i < reviews.length; i++) {
      if (reviews[i].ratingNum != "")
        totalReview = totalReview + double.parse(reviews[i].ratingNum);
    }
    if (totalReview == 0.0)
      return 0.0;
    else
      return double.parse((totalReview / reviews.length).toStringAsFixed(2));
  }

  void getPaidFileList(context) {
    if (mDownloadPaidFileArray.length > 0) {
      _settingModalBottomSheet(context, mDownloadPaidFileArray);
    } else {
      getPaidFileDetails();
    }
  }

  void _settingModalBottomSheet(context, List<Downloads> viewFiles,
      {isSampleFile = false}) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          primary: false,
          child: Container(
            // color: Colors.red,
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              children: <Widget>[
                // title and close
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //lebel
                    Container(
                      margin: EdgeInsets.only(
                        top: spacing_standard_new,
                      ),
                      padding: EdgeInsets.only(right: spacing_standard),
                      child: Text(
                        keyString(context, "lbl_all_files"),
                        style: TextStyle(
                          fontSize: fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: appStore.appTextPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                   // close icon
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: appStore.iconColor,
                        size: 30,
                      ),
                      onTap: () => {Navigator.of(context).pop()},
                    )
                  ],
                ),
                // divider
                Container(
                  margin: EdgeInsets.only(top: spacing_standard_new),
                  height: 2,
                  color: lightGrayColor,
                ),
                // file context
                Container(
                  // color: Colors.green,
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return DownloadFilesView(
                        widget.mBookId,
                        viewFiles[index],
                        mBookDetailsData.images[0].src,
                        mBookDetailsData.name,
                        isSampleFile: isSampleFile,
                      );
                    },
                    itemCount: viewFiles.length,
                    shrinkWrap: true,
                  ),
                ).visible(viewFiles.isNotEmpty),
              ],
            ),
          ),
        );
      },
    );
  }

  Future showDialog1(BuildContext context) async {
    var ratings = 0.0;
    var reviewCont = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: appStore.scaffoldBackground,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      child: Text(
                        keyString(context, "lbl_how_much_do_you_love"),
                        style: TextStyle(
                            fontSize: fontSize25,
                            color: appStore.appTextPrimaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        keyString(context, "lbl_more_than_i_can_say"),
                        style: TextStyle(
                          fontSize: fontSizeNormal,
                          color: appStore.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                  8.height,
                  Center(
                    child: Container(
                      child: RatingBar(
                        allowHalfRating: true,
                        initialRating: 0,
                        minRating: 1,
                        itemSize: 30.0,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        unratedColor: Colors.amber.withOpacity(0.3),
                        onRatingUpdate: (double value) {
                          ratings = value;
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 18,
                        color: appStore.appTextPrimaryColor,
                      ),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
                        hintText: keyString(context, "lbl_write_review"),
                        filled: true,
                        hintStyle:
                            TextStyle(color: appStore.textSecondaryColor),
                        fillColor: appStore.editTextBackColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: appStore.editTextBackColor, width: 0.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: appStore.editTextBackColor, width: 0.0),
                        ),
                      ),
                      controller: reviewCont,
                      maxLines: 3,
                      minLines: 3,
                    ),
                  ),
                  16.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      OutlineButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: primaryColor,
                        borderSide: BorderSide(color: primaryColor),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          keyString(context, "lbl_cancel"),
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                      20.width,
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: primaryColor,
                        onPressed: () {
                          hideKeyboard(context);
                          Navigator.of(context).pop();
                          postReviewApi(reviewCont.text, ratings);
                        },
                        child: Text(
                          keyString(context, "lbl_submit"),
                          style: TextStyle(color: whileColor),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void buyBookBottomSheet(context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          primary: false,
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
            child: Column(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 70,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Center(
                            child: bookLoaderWidget,
                          ),
                          imageUrl: mBookDetailsData.images[0].src,
                          fit: BoxFit.fill,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        elevation: 5,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            mBookDetailsData.name,
                            style: TextStyle(
                              fontSize: fontSizeLarge,
                              fontWeight: FontWeight.bold,
                              color: appStore.appTextPrimaryColor,
                            ),
                          ),
                        ),
                        Text(
                          mCurrencySymbol,
                          style: TextStyle(
                            fontSize: fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: appStore.appTextPrimaryColor,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              /*  FittedBox(
                  child: AppButton(
                    value: keyString(context, "lbl_buy_now"),
                    onPressed: () {
                      Navigator.pop(context);
                      postPlaceOrder();
                    },
                  ).paddingOnly(top: 16, bottom: 16),
                )*/
              ],
            ),
          ),
        );
      },
    );
  }
}
