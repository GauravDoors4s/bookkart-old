import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/WalkThrough.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

import '../main.dart';
import 'DashboardActivity.dart';
import 'Libaryscreen.dart';
import 'NoInternetConnection.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with AfterLayoutMixin<SplashScreen> {
  bool isWasConnectionLoss = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  void checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isWasConnectionLoss = true;
      });
    } else {
      isWasConnectionLoss = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: appStore.scaffoldBackground,
        body: CustomTheme(
          child: SplashScreenView(
            home: SizedBox(),
            duration: 5000,
            imageSize: 200,
            imageSrc: "main_logo.png",
            text: keyString(context, "app_name"),
            textType: TextType.ColorizeAnimationText,
            textStyle: TextStyle(fontSize: 50.0, fontWeight: FontWeight.bold),
            colors: [
              Color(0xff4268cd),
              Color(0xfff49b4d),
              Color(0xff4268cd),
              Color(0xfff49b4d),
              Color(0xff4268cd),
              Color(0xfff49b4d),
            ],
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  Future checkFirstSeen() async {
    appConfiguration(context);
    bool isFirstTime = await getBool(IS_FIRST_TIME, defaultValue: true);
    bool isLoginIn = await getBool(IS_LOGGED_IN);
    await Future.delayed(Duration(seconds: 3));
    if (isFirstTime) {
      AppWalkThrough().launch(context, isNewTask: true);
    } else {
      if (isWasConnectionLoss==true) {
        if (isLoginIn) {
          OfflineScreen(
            isPopOperation: true,
          ).launch(context, isNewTask: true);
        } else {
          NoInternetConnection(isCloseApp: true,).launch(context, isNewTask: true);
        }
      } else {
        DashboardActivity().launch(context, isNewTask: true);
      }
    }
  }
}
