import 'DashboardResponse.dart';

class PaidBookResponse {
  String message;
  List<Downloads> data;

  PaidBookResponse({this.message, this.data});

  PaidBookResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = new List<Downloads>();
      json['data'].forEach((v) {
        data.add(new Downloads.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
