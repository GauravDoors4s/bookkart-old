import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutterapp/model/DashboardResponse.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';

import '../main.dart';

// ignore: must_be_immutable
class Review extends StatefulWidget {
  Reviews reviews;

  Review(this.reviews);

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        color: appStore.scaffoldBackground,
      ),
      margin: EdgeInsets.only(
        top: spacing_standard,
        right: 16,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.65,
            height: 143,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      widget.reviews.commentAuthor.toUpperCase(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: appStore.appTextPrimaryColor,
                          fontSize: fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          height: 1),
                    ),

                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),

                Positioned(
                  top: 24,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 80,
                          height: 13.31399917602539,
                          child: RatingBar(
                            allowHalfRating: true,
                            initialRating: (widget.reviews.ratingNum == "")
                                ? 00.00
                                : double.parse(widget.reviews.ratingNum),
                            minRating: 1,
                            itemSize: 15.0,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ), onRatingUpdate: (double value) {  },
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          reviewConvertDate(widget.reviews.commentDate),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: appStore.textSecondaryColor,
                              fontSize: fontSizeSmall,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                        /* Text(
                          'It was amazing',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: appTextSecondaryColor,
                              fontSize: fontSizeSmall,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),*/
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 47,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: new Text(
                      widget.reviews.commentContent,
                      textAlign: TextAlign.justify,
                      maxLines: 6,
                      style: TextStyle(
                        color: appStore.textSecondaryColor,
                        fontSize: fontSizeSmall,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
