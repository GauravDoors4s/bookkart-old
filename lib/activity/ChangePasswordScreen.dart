import 'package:flutter/material.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'ErrorView.dart';

class ChangePasswordScreen extends StatefulWidget {
  static String tag = '/ChangePasswordScreen';

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var mOldPasswordCont = TextEditingController();
  var mNewPasswordCont = TextEditingController();
  var mConfirmPasswordCont = TextEditingController();
  bool isLoading = false;
  var userName = '';
  final _formKey = GlobalKey<FormState>();
  var autoValidate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    userName = await getString(USER_EMAIL);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: appStore.scaffoldBackground,
        appBar: appBar(context, title: keyString(context, "lbl_change_pwd")),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: _formKey,
                autovalidate: autoValidate,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    EditText(
                      hintText: keyString(context, "hint_enter_old_pwd"),
                      isPassword: true,
                      mController: mOldPasswordCont,
                      isSecure: true,
                      validator: (String s) {
                        if (s.trim().isEmpty)
                          return keyString(context, "lbl_old_pwd") +
                              " " +
                              keyString(context, "lbl_field_required");
                        if (s.length <= 5)
                          return keyString(context, "error_pwd_length");
                        return null;
                      },
                    ),
                    16.height,
                    EditText(
                      hintText: keyString(context, "hint_enter_new_pwd"),
                      isPassword: true,
                      mController: mNewPasswordCont,
                      isSecure: true,
                      validator: (String s) {
                        if (s.trim().isEmpty)
                          return keyString(context, "lbl_new_pwd") +
                              " " +
                              keyString(context, "lbl_field_required");
                        if (s.length <= 5)
                          return keyString(context, "error_pwd_length");
                        return null;
                      },
                    ),
                    16.height,
                    EditText(
                      hintText: keyString(context, "hint_enter_confirm_pwd"),
                      isPassword: true,
                      mController: mConfirmPasswordCont,
                      isSecure: true,
                      validator: (String s) {
                        if (s.trim().isEmpty)
                          return keyString(context, "lbl_confirm_pwd") +
                              " " +
                              keyString(context, "lbl_field_required");
                        if (mNewPasswordCont.text != mConfirmPasswordCont.text)
                          return keyString(context, "lbl_pwd_not_match");
                        return null;
                      },
                    ),
                    16.height,
                    Center(
                      child: AppButton(
                        value: keyString(context, "lbl_submit"),
                        onPressed: () {
                          hideKeyboard(context);
                          if (!mounted) return;
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              changePwdAPI();
                            } else {
                              setState(() {
                                isLoading = false;
                                autoValidate = true;
                              });
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            isLoading
                ? Container(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<void> changePwdAPI() async {
    var request = {
      'password': mOldPasswordCont.text,
      'new_password': mNewPasswordCont.text,
      'username': userName
    };
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        setState(() {
          isLoading = true;
        });
        changePassword(request).then((res) {
          setState(() {
            isLoading = false;
          });
          toast(res["message"]);
          finish(context);
        }).catchError((onError) {
          setState(() {
            isLoading = false;
          });
          print("Data" + onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        setState(() {
          isLoading = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }
}
