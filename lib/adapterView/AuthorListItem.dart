import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/AuthorListResponse.dart';
import 'package:flutterapp/utils/Constant.dart';

import '../main.dart';

// ignore: must_be_immutable
class AuthorListItem extends StatelessWidget {
  AuthorListResponse authorDetails;

  AuthorListItem(this.authorDetails);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: spacing_standard_new),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: [
              Container(
                width: authorImageSize,
                height: authorImageSize,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  image: new DecorationImage(
                    fit: BoxFit.fill,
                    image: new NetworkImage(authorDetails.gravatar),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: spacing_standard),
                height: authorImageSize,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      authorDetails.firstName.toLowerCase() + " " + authorDetails.lastName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeLarge,
                        color: appStore.appTextPrimaryColor,
                      ),
                    ),
                    Text(
                      authorDetails.storeName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: appStore.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Container(
            height: 65,
            width: MediaQuery.of(context).size.width * 0.13,
            child: Icon(
              Icons.chevron_right,
              color: appStore.iconSecondaryColor,
              size: 32.0,
              textDirection: appStore.isRTL? TextDirection.rtl:TextDirection.ltr,
            ),
          ),
        ],
      ),
    );
  }
}
