import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/AboutUs.dart';
import 'package:flutterapp/activity/AuthorList.dart';
import 'package:flutterapp/activity/CategoriesList.dart';
import 'package:flutterapp/activity/ChangePasswordScreen.dart';
import 'package:flutterapp/activity/EditProfileScreen.dart';
import 'package:flutterapp/activity/MyBookMarkScreen.dart';
import 'package:flutterapp/activity/SignInScreen.dart';
import 'package:flutterapp/activity/WebViewScreen.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isLoginIn = false;
  String firstName = "";
  String userImage = "";
  String mProfileImage = "";

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    isLoginIn = await getBool(IS_LOGGED_IN);
    firstName = await getString(FIRST_NAME);
    mProfileImage = await getString(PROFILE_IMAGE);
    String mAvatar = await getString(AVATAR);

    print("ProfileImage" + mProfileImage);
    print("Avatar" + mAvatar);
    if (mProfileImage.isNotEmpty) {
      userImage = mProfileImage;
    } else {
      userImage = mAvatar;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 25.0;
    Widget mOption(icon, text) {
      return Row(
        children: [
          Image.asset(
            icon,
            width: imageSize,
            height: imageSize,
            color: appStore.iconColor,
          ),
          16.width,
          Text(
            keyString(context, text),
            style: primaryTextStyle(
              size: 24,
            ),
          ).expand(),
        ],
      ).paddingOnly(top: 8, left: 20, right: 20, bottom: 8);
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.scaffoldBackground,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //User information
              Row(
                children: <Widget>[
                  CircleAvatar(
                      backgroundImage: NetworkImage(userImage),
                      radius: context.width() * 0.06),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    firstName,
                    style: TextStyle(
                        fontSize: font_size_36,
                        color: appStore.appTextPrimaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ).paddingOnly(left: 20, right: 20, top: 20).visible(isLoginIn),
              10.height,
              // Account funtion
              mOption(
                "edit.png",
                "lbl_edit_profile",
              ).onTap(() {
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) => EditProfileScreen())).whenComplete(getUserDetails);
              }).visible(isLoginIn),
              mOption("user.png", "lbl_author").onTap(() {
                AuthorList().launch(context);
              }),
              mOption("menu.png", "lbl_categories").onTap(() {
                CategoriesList().launch(context);
              }),
              /*Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                  ),

                  16.width,
                  Text(
                    keyString(context, "My Favorite Books"),
                    style: primaryTextStyle(
                      size: 24,
                    ),
                  ).expand(),
                ],
              ).paddingOnly(top: 8, left: 20, right: 20, bottom: 8).onTap((){ MyFavBookScreen().launch(context);}).visible(isLoginIn),*/
                  mOption("bookmark.png", "lbl_my_bookmark").onTap(() {
                MyFavBookScreen().launch(context);
              }).visible(isLoginIn),
              mOption("info.png", "lbl_about").onTap(() {
                AboutUs().launch(context);
              }),
              mOption("padlock.png", "lbl_change_pwd").onTap(() {
                ChangePasswordScreen().launch(context);
              }).visible(isLoginIn),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "ic_mode.png",
                        width: imageSize,
                        height: imageSize,
                        color: appStore.iconColor,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        keyString(context, "lbl_mode"),
                        style: TextStyle(
                          fontSize: fontSize25,
                          color: appStore.appTextPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: appStore.isDarkModeOn,
                    onChanged: (s) {
                      appStore.toggleDarkMode(value: s);
                      setState(() {});
                    },
                  ).withHeight(24)
                ],
              ).paddingOnly(top: 10, right: 20, left: 20, bottom: 10),
              mOption("verified.png", "lbl_term_privacy").onTap(() {
                WebViewScreen(
                        TEARM_PRIVACY, keyString(context, "lbl_term_privacy"))
                    .launch(context);
              }),
              GestureDetector(
                child: Row(
                  children: [
                    Image.asset(
                      "logout.png",
                      width: imageSize,
                      height: imageSize,
                      color: appStore.iconColor,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      keyString(context, "lbl_logout"),
                      style: TextStyle(
                        fontSize: fontSize25,
                        color: appStore.appTextPrimaryColor,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  logout(context);
                },
              ).paddingOnly(top: 10, right: 20, left: 20).visible(isLoginIn),
              mOption("login.png", "lbl_sign_in").onTap(() {
                SignInScreen().launch(context);
              }).visible(!isLoginIn),
            ],
          ),
        ),
      ),
    );
  }
}
