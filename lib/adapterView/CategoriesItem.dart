import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutterapp/model/CategoriesListResponse.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';

import '../main.dart';

// ignore: must_be_immutable
class CategoriesItem extends StatefulWidget {
  CategoriesListResponse categoriesListResponse;

  CategoriesItem(this.categoriesListResponse);

  @override
  _CategoriesItemState createState() => _CategoriesItemState();
}

class _CategoriesItemState extends State<CategoriesItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing_standard_new),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Html(
            data: widget.categoriesListResponse.name,
            defaultTextStyle: TextStyle(
              fontSize: fontSizeLarge,
              color: appStore.appTextPrimaryColor,
            ),
          ),
          SizedBox(
            height: spacing_standard_new,
          ),
          Container(
              color: lightGrayColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 1,
              ))
        ],
      ),
    );
  }
}
