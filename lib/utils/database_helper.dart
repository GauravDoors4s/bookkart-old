import 'dart:io';

import 'package:flutterapp/model/OfflineBookList.dart';
import 'package:flutterapp/model/downloaded_book.dart';
import 'package:flutterapp/utils/utils.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2;
  static const String TABLE_NAME = "downloaded_book_table";
  static const String COLUMN_NAME_ID = "id";
  static const String COLUMN_NAME_BOOK_ID = "book_id";
  static const String COLUMN_NAME_BOOK_NAME = "book_name";
  static const String COLUMN_NAME_USER_ID = "user_id";
  static const String COLUMN_NAME_FILE_PATH = "file_path";
  static const String COLUMN_NAME_FILE_NAME = "file_Name";
  static const String COLUMN_NAME_FRONT_COVER = "front_cover";
  static const String COLUMN_NAME_FILE_TYPE = "file_type";
  static const String SQL_CREATE_ENTRIES = "CREATE TABLE IF NOT EXISTS " +
      TABLE_NAME +
      " (" +
      COLUMN_NAME_ID +
      " INTEGER PRIMARY KEY," +
      COLUMN_NAME_BOOK_ID +
      " TEXT, " +
      COLUMN_NAME_FILE_NAME +
      " TEXT, " +
      COLUMN_NAME_BOOK_NAME +
      " TEXT, " +
      COLUMN_NAME_USER_ID +
      " TEXT, " +
      COLUMN_NAME_FILE_PATH +
      " TEXT, " +
      COLUMN_NAME_FRONT_COVER +
      " TEXT, " +
      COLUMN_NAME_FILE_TYPE +
      " TEXT " +
      ")";

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      printLogs('Update DB Version');
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(SQL_CREATE_ENTRIES);
  }

  Future<int> insert(DownloadedBook book) async {
    Database db = await instance.database;
    printLogs('insert data' + book.toJson().toString());
    return await db.insert(TABLE_NAME, book.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<OfflineBookList>> queryAllRows(userId) async {
    Database db = await instance.database;
    var list = await db.query(
      TABLE_NAME,
      where: "$COLUMN_NAME_USER_ID = ?",
      whereArgs: [userId.toString()],
      orderBy: COLUMN_NAME_BOOK_NAME + " ASC",
    );
    List<DownloadedBook> bookList = list.map((i) => DownloadedBook.fromJson(i)).toList();
    List<OfflineBookList> newList;

    bookList.forEach((element) async {
      var book = OfflineBookList();
      book.bookId = element.bookId;
      book.id = element.id;
      book.bookName = element.bookName;
      book.frontCover = element.frontCover;

      var bookFile = OfflineBook();
      bookFile.fileName = element.fileName;
      bookFile.filePath = element.filePath;
      bookFile.fileType = element.fileType;

      if (newList != null) {
        bool isExistData = false;
        newList.forEach((newElement) async {
          if (newElement.bookId == element.bookId) {
            isExistData = true;
            newElement.offlineBook.add(bookFile);
          }
        });
        if (!isExistData) {
          book.offlineBook.add(bookFile);
          newList.add(book);
        }
      } else {
        newList = List<OfflineBookList>();
        book.offlineBook.add(bookFile);
        newList.add(book);
      }
    });
    newList.forEach((newElement) async {
      newElement.offlineBook.forEach((bookData) async {});
    });

    return newList;
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $TABLE_NAME'));
  }

  Future<List<DownloadedBook>> queryRowBook(bookId) async {
    Database db = await instance.database;
    var list = await db.rawQuery("SELECT DISTINCT * FROM " + TABLE_NAME, null);
    return list.map((i) => DownloadedBook.fromJson(i)).toList();
  }

  Future<int> update(DownloadedBook book) async {
    Database db = await instance.database;
    int id = book.id;
    return await db.update(TABLE_NAME, book.toJson(),
        where: '$COLUMN_NAME_ID = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db
        .delete(TABLE_NAME, where: '$COLUMN_NAME_ID = ?', whereArgs: [id]);
  }
}
