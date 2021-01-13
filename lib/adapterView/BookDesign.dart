import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/utils/app_widget.dart';

import '../main.dart';

// ignore: must_be_immutable
class BookDesign extends StatefulWidget {
  var bookImage = "";
  var bookName = "";

  BookDesign(this.bookName, this.bookImage);

  @override
  _BookDesignState createState() => _BookDesignState();
}

class _BookDesignState extends State<BookDesign> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      width: bookWidth,
      height: bookHeight,
      child: Column(
        children: <Widget>[
          Container(
            width: bookWidth,
            height: bookHeight,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: CachedNetworkImage(
                placeholder: (context, url) => Center(
                  child: bookLoaderWidget,
                ),
                imageUrl: widget.bookImage,
                fit: BoxFit.fill,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(8),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Text(
                widget.bookName,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: appStore.textSecondaryColor,
                    fontSize: fontSizeSmall),
              ),
            ),
          )
        ],
      ),
    );
  }
}
