// import 'package:shared_preferences/shared_preferences.dart';

/*class AudioMarkSF {
  static final String _idPrefs = "id";
  static final String _markPrefs = "mark";

  // getting data
  static Future<String> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_idPrefs) ?? 'id';
  }

  // Setting data
  static Future<bool> setId(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_idPrefs, value);
  }

  // getting data
  static Future<String> getMark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString(_markPrefs) ?? 'mark';
  }

// Setting data
  static Future<bool> setMark(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(_markPrefs, value);
  }
}*/

class AudioMark {
   final String bookId;
   final dynamic mark;

  AudioMark({this.bookId, this.mark});

/*  AudioMark.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mark = json['mark'];
  }

  Map<String, dynamic> toJson() {
*//*    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['mark'] = this.mark;
    *//*
  return{
    'id' : id,
    'mark' : mark,
  };

  }*/
}
