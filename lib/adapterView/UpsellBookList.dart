import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/DashboardResponse.dart';

import 'BookDesign.dart';

// ignore: must_be_immutable
class UpsellBookList extends StatefulWidget {
  var bookData = UpsellId();

  UpsellBookList(this.bookData);

  @override
  _UpsellBookListState createState() => _UpsellBookListState();
}

class _UpsellBookListState extends State<UpsellBookList> {
  @override
  Widget build(BuildContext context) {
    return BookDesign(widget.bookData.name, widget.bookData.images[0].src);
  }
}
