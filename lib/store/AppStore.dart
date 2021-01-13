import 'package:flutter/material.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'AppStore.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  bool isDarkModeOn = false;

  @observable
  Color scaffoldBackground;

  @observable
  Color backgroundColor;

  @observable
  Color backgroundSecondaryColor;

  @observable
  Color appTextPrimaryColor;

  @observable
  Color editTextBackColor;

  @observable
  Color appColorPrimaryLightColor;

  @observable
  Color textSecondaryColor;

  @observable
  Color appBarColor;

  @observable
  Color iconColor;

  @observable
  Color iconSecondaryColor;

  @observable
  String selectedLanguage = 'en';

  @observable
  var selectedDrawerItem = 0;

  @observable
  List<String> languageCode = ['ar'];

  @observable
  bool isRTL = false;

  @action
  Future<void> toggleDarkMode({bool value}) async {
    isDarkModeOn = value ?? !isDarkModeOn;

    if (isDarkModeOn) {
      scaffoldBackground = appBackgroundColorDark;
      appBarColor = appBackgroundColorDark;
      backgroundColor = Colors.white;
      backgroundSecondaryColor = Colors.white;
      appColorPrimaryLightColor = cardBackgroundBlackDark;
      iconColor = iconColorPrimary;
      iconSecondaryColor = iconColorSecondary;
      appTextPrimaryColor = whiteColor;
      textSecondaryColor = Colors.white54;
      editTextBackColor = cardBackgroundBlackDark;
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = Colors.white54;
      shadowColorGlobal = appShadowColorDark;
    } else {
      scaffoldBackground = screenBackgroundColor;
      appBarColor = screenBackgroundColor;
      backgroundColor = Colors.black;
      backgroundSecondaryColor = appSecondaryBackgroundColor;
      appColorPrimaryLightColor = appColorPrimaryLight;
      iconColor = iconColorPrimaryDark;
      iconSecondaryColor = iconColorSecondaryDark;
      appTextPrimaryColor = TextPrimaryColor;
      textSecondaryColor = appTextSecondaryColor;
      editTextBackColor = whileColor;
      textPrimaryColorGlobal = TextPrimaryColor;
      textSecondaryColorGlobal = appTextSecondaryColor;
      shadowColorGlobal = shadow_color;
    }

    await setBool(isDarkModeOnPref, isDarkModeOn);
  }

  @action
  void setLanguage(String aLanguage) => selectedLanguage = aLanguage;

  @action
  void setDrawerItemIndex(int aIndex) => selectedDrawerItem = aIndex;

  @action
  Future<void> checkRTL({String value}) async {
    log("Language" + LANGUAGE);
    languageCode.forEach((element) {
      if (element.contains(value)) {
        isRTL = true;
        log("RTL"+value.toString());
      } else {
        isRTL = false;
        log("LTR"+value.toString());
      }
    });
  }
}
