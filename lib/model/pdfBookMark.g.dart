// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdfBookMark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PdfBookMark _$PdfBookMarkFromJson(Map<String, dynamic> json) {
  return PdfBookMark(
    id: json['id'] as String,
    marksList: (json['marksList'] as List)?.map((e) => e as dynamic)?.toList(),
  );
}

Map<String, dynamic> _$PdfBookMarkToJson(PdfBookMark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'marksList': instance.marksList,
    };
