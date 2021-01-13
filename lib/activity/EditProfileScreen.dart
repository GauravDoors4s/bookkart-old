import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterapp/activity/DashboardActivity.dart';
import 'package:flutterapp/activity/NoInternetConnection.dart';
import 'package:flutterapp/app_localizations.dart';
import 'package:flutterapp/model/CustomerResponse.dart';
import 'package:flutterapp/network/rest_api_call.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'ErrorView.dart';

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var mFirstNameCont = TextEditingController();
  var mLastNameCont = TextEditingController();
  var mEmailCont = TextEditingController();
  File mSelectedImage;
  bool mIsLoading = false, mIsNetwork = false;
  var mCustomer = List<MetaDataResponse>();
  int id;
  String mFirstName = '', mLastName = '', mEmail = '', avatar = '';
  SharedPreferences pref;
  final _formKey = GlobalKey<FormState>();
  var autoValidate = false;

  @override
  void initState() {
    super.initState();
    getCustomerData();
  }

  getCustomerData() async {
    setState(() {
      mIsLoading = true;
    });
    await isNetworkAvailable().then((bool) async {
      if (bool) {
        mIsNetwork = true;
        id = await getInt(USER_ID);
        pref = await getSharedPref();
        mFirstName = await getString(FIRST_NAME);
        mLastName = await getString(LAST_NAME);
        mEmail = await getString(USER_EMAIL);

        await getCustomer(id).then((res) {
          if (!mounted) return;
          setState(() {
            mIsLoading = false;
          });
          mFirstNameCont.text = res['first_name'];
          mLastNameCont.text = res['last_name'];
          mEmailCont.text = res['email'];
          Iterable newest = res['meta_data'];
          mCustomer =
              newest.map((model) => MetaDataResponse.fromJson(model)).toList();
          avatar =
              mCustomer.isNotEmpty ? mCustomer[0].value : res['avatar_url'];
          setString(FIRST_NAME, res['first_name']);
          setString(LAST_NAME, res['last_name']);
          if (mCustomer.isNotEmpty) {
            setString(PROFILE_IMAGE, mCustomer[0].value);
            print("ProfileImage1" + mCustomer[0].value);
          }
        }).catchError((onError) {
          setState(() {
            mIsLoading = false;
          });
          print(onError.toString());
          ErrorView(
            message: onError.toString(),
          ).launch(context);
        });
      } else {
        mIsNetwork = false;
        setState(() {
          mIsLoading = false;
        });
        NoInternetConnection().launch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    saveUser() async {
      setState(() {
        mIsLoading = true;
      });
      hideKeyboard(context);
      var request = {
        'first_name': mFirstNameCont.text,
        'last_name': mLastNameCont.text,
      };
      await isNetworkAvailable().then((bool) async {
        if (bool) {
          mIsNetwork = true;
          updateCustomer(id, request).then((res) {
            if (!mounted) return;
            setState(() {
              mIsLoading = false;
            });
            setString(FIRST_NAME, res['first_name']);
            setString(LAST_NAME, res['last_name']);
            toast(keyString(context, "lbl_profile_saved"));
            DashboardActivity().launch(context);
          }).catchError((onError) {
            setState(() {
              mIsLoading = false;
            });
            printLogs(onError.toString());
            ErrorView(
              message: onError.toString(),
            ).launch(context);
          });
        } else {
          mIsNetwork = false;
          setState(() {
            mIsLoading = false;
          });
          NoInternetConnection().launch(context);
        }
      });
    }

    pickImage() async {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);

      setState(() {
        mSelectedImage = image;
      });

      if (mSelectedImage != null) {
        ConfirmAction res = await showConfirmDialogs(
            context,
            keyString(context, "lbl_confirmation_upload_image"),
            keyString(context, "lbl_yes"),
            keyString(context, "lbl_no"));

        if (res == ConfirmAction.ACCEPT) {
          var base64Image = base64Encode(mSelectedImage.readAsBytesSync());
          var request = {'base64_img': base64Image};
          setState(() {
            mIsLoading = true;
          });
          await isNetworkAvailable().then((bool) async {
            if (bool) {
              mIsNetwork = true;
              await saveProfileImage(request).then((res) async {
                setState(() {
                  getCustomerData();
                });
              }).catchError((onError) {
                print(onError.toString());
                setState(() {
                  mIsLoading = false;
                  getCustomerData();
                });
              });
            } else {
              mIsNetwork = false;
              setState(() {
                mIsLoading = false;
              });
              NoInternetConnection().launch(context);
            }
          });
        }
      }
    }

    Widget profileImage = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: mSelectedImage == null
          ? avatar.isEmpty
              ? Image.asset(
                  "ic_profile.png",
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  avatar,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return getLoadingProgress(loadingProgress);
                  },
                )
          : Image.file(
              mSelectedImage,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
    );

    return Scaffold(
      backgroundColor: appStore.scaffoldBackground,
      appBar: appBar(context, title: keyString(context, "lbl_edit_profile")),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidate: autoValidate,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              profileImage,
                              Container(
                                height: 35,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: primaryColor, width: 1),
                                    color: whileColor),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: primaryColor,
                                ),
                              ).onTap(() {
                                pickImage();
                              })
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  16.height,
                  EditText(
                    hintText: keyString(context, "hint_enter_first_name"),
                    isPassword: false,
                    mController: mFirstNameCont,
                    mKeyboardType: TextInputType.text,
                    validator: (String s) {
                      if (s.trim().isEmpty)
                        return keyString(context, "lbl_first_name") +
                            " " +
                            keyString(context, "lbl_field_required");
                      if (s.contains(
                          RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')))
                        return keyString(context, "error_string");
                      return null;
                    },
                  ),
                  16.height,
                  EditText(
                    hintText: keyString(context, "hint_enter_last_name"),
                    isPassword: false,
                    mController: mLastNameCont,
                    mKeyboardType: TextInputType.text,
                    validator: (String s) {
                      if (s.trim().isEmpty)
                        return keyString(context, "lbl_last_name") +
                            " " +
                            keyString(context, "lbl_field_required");
                      if (s.contains(
                          RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')))
                        return keyString(context, "error_string");
                      return null;
                    },
                  ),
                  16.height,
                  EditText(
                    hintText: keyString(context, "hint_enter_email"),
                    isPassword: false,
                    mController: mEmailCont,
                    visible: true,
                  ),
                  16.height,
                  Center(
                    child: AppButton(
                      value: keyString(context, "lbl_save"),
                      onPressed: () {
                        hideKeyboard(context);
                        if (!mounted) return;
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              mIsLoading = true;
                            });
                            saveUser();
                          } else {
                            setState(() {
                              mIsLoading = false;
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
          ).visible(mIsNetwork = true),
          mIsLoading
              ? Container(
                  child: CircularProgressIndicator(),
                  alignment: Alignment.center,
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
