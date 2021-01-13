import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../app_localizations.dart';

// ignore: must_be_immutable
class ErrorView extends StatelessWidget {
  bool _isCloseApp = false;
  String _message;

  ErrorView({isCloseApp = false, message = ""}) {
    _isCloseApp = isCloseApp;
    _message = message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'error.png',
            height: 250,
            width: 250,
            fit: BoxFit.cover,
          ),
          30.height,
          Text(
            "Oops! " + _message,
            style: boldTextStyle(
              size: 24,
            ),
            textAlign: TextAlign.center,
          ),
          10.height,
          Text(
            keyString(context, "lbl_error"),
            style: secondaryTextStyle(
              size: 14,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(left: 20, right: 20),
          AppButton(
            value: keyString(context, "lbl_try_again"),
            onPressed: () {
              if (_isCloseApp) {
                SystemNavigator.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ).paddingAll(16)
        ],
      ),
    );
  }
}
