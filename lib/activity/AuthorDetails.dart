import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/adapterView/BookList.dart';
import 'package:flutterapp/model/AuthorListResponse.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import '../app_localizations.dart';
import '../main.dart';
import 'BookDetails.dart';
import 'ErrorView.dart';
import 'NoInternetConnection.dart';
import 'package:admob_flutter/admob_flutter.dart';

// ignore: must_be_immutable
class AuthorDetails extends StatefulWidget {
  AuthorListResponse authorDetails;
  String url;
  String fullName;

  AuthorDetails(this.authorDetails, this.url, this.fullName);

  @override
  _AuthorDetailsState createState() => _AuthorDetailsState();
}

class _AuthorDetailsState extends State<AuthorDetails> {
  bool mIsLoading = false;
  List<BookInfoDetails> mAuthorBookList;

  @override
  void initState() {
    super.initState();
    getAuthorList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getAuthorList() async {
    mIsLoading = true;
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        await getAuthorBookListRestApi(widget.authorDetails.id).then(
          (res) async {
            mIsLoading = false;
            Iterable mCategory = res;
            mAuthorBookList = mCategory
                .map((model) => BookInfoDetails.fromJson(model))
                .toList();

            setState(() {});
          },
        ).catchError(
          (onError) {
            setState(() {
              mIsLoading = false;
            });
            printLogs(onError.toString());
            ErrorView(
              message: onError.toString(),
            ).launch(context);
          },
        );
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
            keyString(context, 'lbl_book_not_available'),
            style: TextStyle(
                fontSize: fontSizeLarge,
                color: appStore.appTextPrimaryColor,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appStore.appBarColor,
        elevation: 0,
        leading: backIcons(context),
        title: Row(
          children: [
            Container(
              width: authorImageSize - 20,
              height: authorImageSize - 20,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: new NetworkImage(widget.url),
                ),
              ),
            ),
            10.width,
            Text(
              widget.fullName,
              style: boldTextStyle(size: fontSizeLarge.toInt()),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (mAuthorBookList != null)
                ? Padding(
                    padding: EdgeInsets.only(left: 0, right: 0),
                    child: mAuthorBookList.isEmpty
                        ? blankView
                        : GridView.builder(
                            itemCount: mAuthorBookList.length,
                            shrinkWrap: true,
                            padding: EdgeInsets.only(top: 16),
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: getChildAspectRatio(),
                              crossAxisCount: getCrossAxisCount(),
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                child: BookItem(mAuthorBookList[index]),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetails(
                                      mAuthorBookList[index].id.toString(),
                                    ),
                                  ),
                                ),
                              );
                            }),
                  )
                : appLoaderWidget.center().visible(mIsLoading),
          ],
        ),
      ),
      bottomNavigationBar: AdmobBanner(
        adUnitId: getBannerAdUnitId(),
    adSize: AdmobBannerSize.BANNER,
    ).visible(isAdsLoading==true),
    );
  }
}
