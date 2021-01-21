import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutterapp/activity/external.dart';
import 'package:flutterapp/activity/local_files.dart';
import 'package:flutterapp/confi/application.dart';
import 'package:flutterapp/store/AppStore.dart';
import 'package:flutterapp/utils/AppTheme.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'activity/SplashScreen.dart';
import 'app_localizations.dart';
import 'app_state.dart';

// Default Configuration
double bookViewHeight = mobile_BookViewHeight;
double bookHeight = mobile_bookHeight;
double bookWidth = mobile_bookWidth;
double appLoaderWH = mobile_appLoaderWH;
double backIconSize = mobile_backIconSize;
double bookHeightDetails = mobile_bookWidthDetails;
double bookWidthDetails = mobile_bookHeightDetails;
double fontSizeMedium = mobile_font_size_medium;
double fontSizeXxxlarge = mobile_font_size_xxxlarge;
double fontSizeMicro = mobile_font_size_micro;
double fontSize25 = mobile_font_size_25;
double fontSizeLarge = mobile_font_size_large;
double fontSizeSmall = mobile_font_size_small;
double authorImageSize = mobile_authorImageSize;
double fontSizeNormal = mobile_font_size_normal;

AppStore appStore = AppStore();

void main() async {
  await FlutterDownloader.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  appStore.toggleDarkMode(value: await getBool(isDarkModeOnPref));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  OneSignal.shared.init(ONESIGNAL_ID, iOSSettings: {
    OSiOSSettings.autoPrompt: false,
    OSiOSSettings.inAppLaunchUrl: false
  });

  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  await OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);

  var pref = await getSharedPref();
  var language;
  try {
    if (pref.getString(LANGUAGE) == null) {
      language = DEFAULT_LANGUAGE_CODE;
    } else {
      language = pref.getString(LANGUAGE);
    }
  } catch (e) {
    language = "en";
  }
  const platform = const MethodChannel('fileUrl');
  dynamic fileUrl = await platform.invokeMethod("getOpenFileUrl");
  ApplicationGlobal.url = fileUrl;
  runApp(new MyApp(language));
}

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  var language;

  MyApp(this.language);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print('${ApplicationGlobal.url} --- global file url');
    return ApplicationGlobal.url == null
        ? ChangeNotifierProvider(
            create: (_) => AppState(widget.language),
            child: Consumer<AppState>(builder: (context, provider, builder) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                supportedLocales: [
                  Locale('af', ''),
                  Locale('de', ''),
                  Locale('en', ''),
                  Locale('es', ''),
                  Locale('fr', ''),
                  Locale('hi', ''),
                  Locale('in', ''),
                  Locale('tr', ''),
                  Locale('vi', ''),
                  Locale('ar', '')
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  return Locale(
                      Provider.of<AppState>(context).selectedLanguageCode);
                },
                locale: Provider.of<AppState>(context).locale,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate
                ],
                theme: !appStore.isDarkModeOn
                    ? AppThemeData.lightTheme
                    : AppThemeData.darkTheme,
                // SplashScreen
                home: SplashScreen(),
                routes: <String, WidgetBuilder>{
                  SplashScreen.tag: (BuildContext context) => SplashScreen(),
                },
                builder: (context, child) {
                  return ScrollConfiguration(
                    behavior: SBehavior(),
                    child: child,
                  );
                },
              );
            }),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'BookKart',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: LocalFiles(
              title: 'files',
            ),
          );
  }
}

class SBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
