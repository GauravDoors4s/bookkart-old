class OfflineBookList {
  int id;
  String bookId;
  String bookName;
  String frontCover;
  List<OfflineBook> offlineBook = List<OfflineBook>();

  OfflineBookList({
    this.id,
    this.bookId,
    this.bookName,
    this.frontCover,
  });

  factory OfflineBookList.fromJson(Map<String, dynamic> json) {
    return OfflineBookList(
      id: json['id'],
      bookId: json['book_id'],
      bookName: json['book_name'],
      frontCover: json['front_cover'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['book_id'] = this.bookId;
    data['book_name'] = this.bookName;
    data['front_cover'] = this.frontCover;
    return data;
  }
}

class OfflineBook {
  String fileType;
  String fileName;
  String filePath;

  OfflineBook({this.filePath, this.fileName, this.fileType});

  factory OfflineBook.fromJson(Map<String, dynamic> json) {
    return OfflineBook(
      fileName: json['file_Name'],
      filePath: json['file_path'],
      fileType: json['file_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['file_Name'] = this.fileName;
    data['file_path'] = this.filePath;
    data['file_type'] = this.fileType;
    return data;
  }
}
