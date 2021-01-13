import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/BookmarkResponse.dart';

import 'BookDesign.dart';

// ignore: must_be_immutable
class BookmarkBookList extends StatelessWidget {
  var bookData = BookmarkResponse();

  BookmarkBookList(this.bookData);

  @override
  Widget build(BuildContext context) {
    return BookDesign(bookData.name, bookData.full);
  }
}
