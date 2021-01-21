import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/DashboardActivity.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/main.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Constant.dart';
import 'app_widget.dart';

Future<bool> isLoggedIn() async {
  return await getBool(IS_LOGGED_IN) ?? false;
}

Future clearSearchHistory() async {
  await setString(SEARCH_TEXT, "");
}
/*Future<bool> checkPermission(widget) async {
  if (widget.platform == TargetPlatform.android) {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.storage]);
      if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
        return true;
      }
    } else {
      return true;
    }
  } else {
    return true;
  }
  return false;
}*/

Future<String> getBookFilePath(String bookId, String url,
    {isSampleFile = false}) async {
  String path = await localPath;
  String filePath =
      path + "/" + await getBookFileName(bookId, url, isSample: isSampleFile);
  filePath = filePath.replaceAll("null/", "");
  printLogs("Full File Path: " + filePath);
  return filePath;
}

Future<String> getBookFileName(String bookId, String url,
    {isSample = false}) async {
  var name = url.split("/");
  String fileNameNew = url;
  if (name.length > 0) {
    fileNameNew = name[name.length - 1];
  }
  fileNameNew = fileNameNew.replaceAll("%", "");
  var fileName = isSample
      ? bookId + "_sample_" + fileNameNew
      : bookId + "_purchased_" + fileNameNew;
  int userId = await getInt(USER_ID, defaultValue: 0);
  printLogs("File Name: " + userId.toString() + "_" + fileName);
  return userId.toString() + "_" + fileName;
}

Future<String> get localPath async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getApplicationSupportDirectory();
  } else if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  } else {
    throw "Unsupported platform";
  }
  int userId = await getInt(USER_ID, defaultValue: 0);
  printLogs(
      "localPath: " + directory.absolute.path + "/" + userId.toString() + "");
  return directory.absolute.path + "/" + userId.toString() + "";
}

Future addToSearchArray(searchText) async {
  if (await getString(SEARCH_TEXT) != null) {
    String oldValue = await getString(SEARCH_TEXT);
    if (!oldValue.contains(searchText)) {
      await setString(SEARCH_TEXT, oldValue + searchText + ",");
    }
  } else {
    await setString(SEARCH_TEXT, searchText + ",");
  }
}

Future<List<String>> getSearchValue() async {
  var searchString = await getString(SEARCH_TEXT);
  searchString = searchString.trim();
  List<String> data = searchString.trim().split(',');
  data.removeAt(data.length - 1);
  return data;
}

Future logout(BuildContext context) async {
  ConfirmAction res = await showConfirmDialogs(
      context,
      keyString(context, "lbl_are_your_logout"),
      keyString(context, "lbl_yes"),
      keyString(context, "lbl_cancel"));
  if (res == ConfirmAction.ACCEPT) {
    var pref = await getSharedPref();
    pref.remove(TOKEN);
    pref.remove(USERNAME);
    pref.remove(FIRST_NAME);
    pref.remove(LAST_NAME);
    pref.remove(USER_DISPLAY_NAME);
    pref.remove(USER_ID);
    pref.remove(USER_EMAIL);
    pref.remove(USER_ROLE);
    pref.remove(AVATAR);
    pref.remove(PROFILE_IMAGE);
    pref.remove(IS_LOGGED_IN);
    pref.setBool(IS_LOGGED_IN, false);
    DashboardActivity().launch(context, isNewTask: true);
  }
}

Future<ConfirmAction> showConfirmDialogs(
    context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: appStore.appBarColor,
        title: Text(msg, style: TextStyle(fontSize: 16)),
        actions: <Widget>[
          FlatButton(
            child: Text(
              negativeText,
              style: primaryTextStyle(color: appStore.appTextPrimaryColor),
            ),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          FlatButton(
            child: Text(positiveText,
                style: primaryTextStyle(color: appStore.appTextPrimaryColor)),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

Future<String> getTime() async {
  DateTime currentTime = DateTime.now().toUtc();
  final f = new DateFormat('yyyy-MM-dd hh:mm');
  printLogs(f.format(currentTime).toString());
  return f.format(currentTime).toString();
}

Future<String> getKey(time) async {
  String finalString = time + SALT;
  printLogs("Final String: " + finalString);
  String md5String = md5.convert(utf8.encode(finalString)).toString();
  printLogs("MD5 String: " + md5String);
  return md5String;
}

String getFileNewName(downloads) {
  String newFilename =
      downloads.file.substring(downloads.file.lastIndexOf("/") + 1);
  newFilename = downloads.id + "_" + newFilename;
  printLogs(newFilename);
  return newFilename;
}

Future<bool> isFileExist(downloads) async {
  String bookName = getFileNewName(downloads);
  String path;
  bool isFileExist = false;

  path = (await _localFile(bookName)).path;
  if (!File(path).existsSync()) {
    printLogs("--------File Not Exist");
    isFileExist = false;
  } else {
    printLogs("--------File Exist");
    isFileExist = true;
  }

  return isFileExist;
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _localFile(bookName) async {
  final path = await _localPath;
  printLogs('$path/$bookName');
  return File('$path/$bookName');
}

Future<File> getFilePathFile(bookName) async {
  return _localFile(bookName);
}

/// Print Logs on console
printLogs(String data) {
 /* print(
      "====================\nPrint Data From App\n====================\nLog::-> " +
          data +
          "\n------------------------\n");*/
}

appConfiguration(BuildContext context) {
  var width = context.width();
  var height = context.height();
  var diagonal = sqrt((width * width) + (height * height));
  var isTab = diagonal > 1100.0;
  if (isTab) {
    printLogs("Device is Tab");
    bookViewHeight = tab_BookViewHeight;
    bookHeight = tab_bookHeight;
    bookWidth = tab_bookWidth;
    appLoaderWH = tab_appLoaderWH;
    backIconSize = tab_backIconSize;
    bookHeightDetails = tab_bookHeightDetails;
    bookWidthDetails = tab_bookWidthDetails;
    fontSizeMedium = tab_font_size_medium;
    fontSizeXxxlarge = tab_font_size_xxxlarge;
    fontSizeMicro = tab_font_size_micro;
    fontSize25 = tab_font_size_25;
    fontSizeLarge = tab_font_size_large;
    fontSizeSmall = tab_font_size_small;
    authorImageSize = tab_authorImageSize;
    fontSizeNormal = tab_font_size_normal;
  } else {
    printLogs("Device is Mobile");
    bookWidth = mobile_bookWidth;
    bookViewHeight = mobile_BookViewHeight;
    bookHeight = mobile_bookHeight;
    backIconSize = mobile_backIconSize;
    appLoaderWH = mobile_appLoaderWH;
    bookHeightDetails = mobile_bookHeightDetails;
    bookWidthDetails = mobile_bookWidthDetails;
    fontSizeMedium = mobile_font_size_medium;
    fontSizeXxxlarge = mobile_font_size_xxxlarge;
    fontSizeMicro = mobile_font_size_micro;
    fontSize25 = mobile_font_size_25;
    fontSizeLarge = mobile_font_size_large;
    fontSizeSmall = mobile_font_size_small;
    authorImageSize = mobile_authorImageSize;
    fontSizeNormal = mobile_font_size_normal;
  }
}
