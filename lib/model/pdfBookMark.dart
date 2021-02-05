import 'package:json_annotation/json_annotation.dart';

part 'pdfBookMark.g.dart';

@JsonSerializable()

class PdfBookMark {
  String id;
  List<dynamic> marksList;

  PdfBookMark({this.id, this.marksList});

  factory PdfBookMark.fromJson(Map<String, dynamic> json) => _$PdfBookMarkFromJson(json);

  Map<String, dynamic>toJson() => _$PdfBookMarkToJson(this);
}
