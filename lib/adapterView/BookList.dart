import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/DashboardResponse.dart';

import 'BookDesign.dart';

// ignore: must_be_immutable
class BookItem extends StatefulWidget {
  var bookData = BookInfoDetails();

  BookItem(this.bookData);

  @override
  _BookItemState createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  @override
  Widget build(BuildContext context) {
    return BookDesign(widget.bookData.name, widget.bookData.images[0].src);
  }
}
