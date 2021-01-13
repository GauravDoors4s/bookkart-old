import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/admob_utils.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admob_flutter/admob_flutter.dart';

class AboutUs extends StatefulWidget {
  static var tag = "/AboutUs";

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  SharedPreferences pref;
  var copyrightText = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  init() async {
    pref = await getSharedPref();
    setState(() {
      if (pref.getString(COPYRIGHT_TEXT) != null) {
        copyrightText = pref.getString(COPYRIGHT_TEXT);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: appStore.scaffoldBackground,
          appBar: appBar(context, title: keyString(context, "lbl_about")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(spacing_standard.toDouble()),
                    decoration: boxDecoration(
                        radius: 10.0,
                        showShadow: true,
                        bgColor: appStore.editTextBackColor),
                    child: Image.asset(
                      'main_logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                16.height,
                Text(
                  keyString(context, "app_name"),
                  style: boldTextStyle(size: 24),
                ),
                8.height,
                Text(
                  keyString(context, "lbl_version"),
                  style: secondaryTextStyle(size: 18),
                ),
                8.height,
                Text(
                  copyrightText,
                  style: primaryTextStyle(size: 18),
                ),
                16.height,
                GestureDetector(
                  onTap: () =>
                      redirectUrl(pref.getString(TERMS_AND_CONDITIONS)),
                  child: Text(keyString(context, "lbl_terms_conditions"),
                      style: boldTextStyle(size: 20, color: primaryColor)),
                ),
                16.height,
                GestureDetector(
                  onTap: () => redirectUrl(pref.getString(PRIVACY_POLICY)),
                  child: Text(keyString(context, "llb_privacy_policy"),
                      style: boldTextStyle(size: 20, color: primaryColor)),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            width: context.width(),
            height: context.height() * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  keyString(context, 'llb_follow_us'),
                  style: boldTextStyle(size: 16),
                ).visible(pref.getString(WHATSAPP).isNotEmpty),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    16.width,
                    InkWell(
                      onTap: () => redirectUrl(
                          'https://wa.me/${pref.getString(WHATSAPP)}'),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.asset("ic_Whatsapp.png",
                            height: 35, width: 35),
                      ),
                    ).visible(pref.getString(WHATSAPP) != null),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(INSTAGRAM)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child:
                            Image.asset("ic_Inst.png", height: 35, width: 35),
                      ),
                    ).visible(pref.getString(INSTAGRAM).isNotEmpty),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(TWITTER)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.asset("ic_Twitter.png",
                            height: 35, width: 35),
                      ),
                    ).visible(pref.getString(TWITTER).isNotEmpty),
                    InkWell(
                      onTap: () => redirectUrl(pref.getString(FACEBOOK)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.asset("ic_Fb.png", height: 35, width: 35),
                      ),
                    ).visible(pref.getString(FACEBOOK).isNotEmpty),
                    InkWell(
                      onTap: () =>
                          redirectUrl('tel:${pref.getString(CONTACT)}'),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Image.asset("ic_CallRing.png",
                            height: 35, width: 35, color: primaryColor),
                      ),
                    ).visible(pref.getString(CONTACT).isNotEmpty),
                    16.width
                  ],
                ),
                AdmobBanner(
                  adUnitId: getBannerAdUnitId(),
                  adSize: AdmobBannerSize.BANNER,
                ).visible(isAdsLoading==true),
              ],
            ),
          )),
    );
  }
}
