import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterapp/model/BookPurchaseResponse.dart';

import 'BookDesign.dart';

// ignore: must_be_immutable
class PurchasedBookList extends StatelessWidget {
  var bookData = LineItems();

  PurchasedBookList(this.bookData);

  @override
  Widget build(BuildContext context) {
    return BookDesign(bookData.name, bookData.productImages[0].src);

  }
}
