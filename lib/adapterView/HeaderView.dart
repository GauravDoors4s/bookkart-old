import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/HeaderModel.dart';
import 'package:flutterapp/utils/Colors.dart';
import 'package:flutterapp/utils/Constant.dart';
import 'package:flutterapp/utils/app_widget.dart';

import '../main.dart';

// ignore: must_be_immutable
class HeaderView extends StatefulWidget {
  HeaderModel model;

  HeaderView(this.model);

  @override
  _HeaderViewState createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: boxColor,
        margin: EdgeInsets.only(top: spacing_standard_new),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.80,
          height: MediaQuery.of(context).size.width * 0.80,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  height: MediaQuery.of(context).size.width * 0.80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment(6.123234262925839e-17, 1),
                      end: Alignment(-1, 6.123234262925839e-17),
                      colors: [
                        Color.fromRGBO(185, 205, 254, 1),
                        Color.fromRGBO(182, 178, 255, 1)
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 23,
                left: 20,
                child: Text(
                  widget.model.title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: whileColor,
                    fontSize: fontSizeMicro,
                    letterSpacing: 4,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 20,
                child: AutoSizeText(
                  widget.model.message,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: whileColor,
                      fontSize: fontSize25,
                      letterSpacing: 1,
                      fontWeight: FontWeight.normal,
                      height: 1),
                  maxLines: 1,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.35,
                left: MediaQuery.of(context).size.width * 0.10,
                child: RotationTransition(
                  turns: new AlwaysStoppedAnimation(-15 / 360),
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        Center(child: bookLoaderWidget),
                    imageUrl: widget.model.image2,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width * 0.30,
                    height: MediaQuery.of(context).size.width * 0.45,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.30,
                left: MediaQuery.of(context).size.width * 0.35,
                child: RotationTransition(
                  turns: new AlwaysStoppedAnimation(10 / 360),
                  child: CachedNetworkImage(
                    placeholder: (context, url) =>
                        Center(child: bookLoaderWidget),
                    imageUrl: widget.model.image1,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: MediaQuery.of(context).size.width * 0.50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
