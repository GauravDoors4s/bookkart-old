import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:flutterapp/utils/BubbleBotoomBar.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/view/BookStoreView.dart';
import 'package:flutterapp/view/MyLibraryView.dart';
import 'package:flutterapp/view/ProfileView.dart';
import 'package:flutterapp/view/SearchView.dart';
import 'package:nb_utils/nb_utils.dart';

import 'CategoriesList.dart';
import 'Libaryscreen.dart';
import 'NoInternetConnection.dart';

class DashboardActivity extends StatefulWidget {
  @override
  _DashboardActivityState createState() => _DashboardActivityState();
}

class _DashboardActivityState extends State<DashboardActivity> {
  var currentPage = 0;
  bool isWasConnectionLoss = false;
  bool isLoginIn = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isLoginIn = await getBool(IS_LOGGED_IN);
    setState(() {
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        if (result == ConnectivityResult.none) {
          isWasConnectionLoss = true;
        } else {
          setState(() {
            isWasConnectionLoss = false;
          });
        }
      });
    });
  }

  void changePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: getView(currentPage),
        ),
      ),
      bottomNavigationBar: BubbleBottomBar(
        opacity: .2,
        currentIndex: currentPage,
        backgroundColor: appStore.appBarColor,
        elevation: 8,
        onTap: changePage,
        hasNotch: false,
        hasInk: true,
        inkColor: appStore.appColorPrimaryLightColor,
        items: <BubbleBottomBarItem>[
          tab("home-run.png", keyString(context, "title_bookStore")),
          tab(
              "librarysolid.png",
              isLoginIn
                  ? keyString(context, "title_myLibrary")
                  : keyString(context, "lbl_categories")),
          tab("search.png", keyString(context, "title_search")),
          tab("user.png", keyString(context, "title_account")),
        ],
      ),
    );
  }

  getView(int page) {
    if (isWasConnectionLoss) {
      if (isLoginIn) {
        return OfflineScreen(
          isShowBack: false,
        );
      } else {
        return NoInternetConnection(
          isCloseApp: true,
        );
      }
    } else {
      switch (page) {
        case 0:
          return BookStoreView();
        case 1:
          return isLoginIn
              ? MyLibraryView()
              : CategoriesList(
                  isShowBack: false,
                );
        case 2:
          return SearchView();
        case 3:
          return ProfileView();
        default:
          return BookStoreView();
      }
    }
  }
}
