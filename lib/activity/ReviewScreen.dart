import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/model/ReviewResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import 'ErrorView.dart';

// ignore: must_be_immutable
class ReviewScreen extends StatefulWidget {
  static var tag = "/ViewAllReviewScreen";

  int mBookId;

  ReviewScreen(
    this.mBookId,
  );

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<BookInfoDetails> product = List();
  var mReviewList = List<ReviewResponse>();
  bool mIsLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future fetchData() async {
    setState(() {
      mIsLoading = true;
    });
    printLogs("BookID" + widget.mBookId.toString());
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getProductReviews(widget.mBookId).then((res) {
          if (!mounted) return;
          setState(() {
            mIsLoading = false;
            Iterable list = res;
            mReviewList =
                list.map((model) => ReviewResponse.fromJson(model)).toList();
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
              keyString(context, 'lbl_no_review_found'),
              style: boldTextStyle(
                size: 20,
              ),
            ),
          ],
        ),
      );
    }

    Widget mBody() {
      return SingleChildScrollView(
        child: Column(
          children: [
            (mReviewList.length < 1)
                ? blankView()
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: mReviewList.length,
                    padding: EdgeInsets.only(bottom: 16),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          decoration: boxDecoration(
                              showShadow: true,
                              radius: 10,
                              bgColor: appStore.editTextBackColor),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(
                              top: spacing_standard, right: 10, left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                mReviewList[index].name.toUpperCase(),
                                textAlign: TextAlign.left,
                                style: boldTextStyle(),
                              ),
                              4.height,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  RatingBar(
                                    allowHalfRating: true,
                                    initialRating:
                                        (mReviewList[index].rating.toString() ==
                                                "")
                                            ? 00.00
                                            : double.parse(mReviewList[index]
                                                .rating
                                                .toString()),
                                    minRating: 1,
                                    itemSize: 15.0,
                                    direction: Axis.horizontal,
                                    itemCount: 5,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (double value) {},
                                  ),
                                  8.width,
                                  Text(
                                    reviewConvertDate(
                                        mReviewList[index].dateCreated),
                                    style: secondaryTextStyle(),
                                  ),
                                ],
                              ),
                              4.height,
                              Text(
                                mReviewList[index].review,
                                textAlign: TextAlign.justify,
                                maxLines: 6,
                                style: secondaryTextStyle(),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    shrinkWrap: true,
                  ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: keyString(context, "lbl_review")),
      body: Stack(
        alignment: Alignment.center,
        children: [
          (!mIsLoading)
              ? mBody()
              : appLoaderWidget.center().visible(mIsLoading),
        ],
      ),
    );
  }
}
