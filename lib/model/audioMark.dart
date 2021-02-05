class AudioMark {
  List<Mark> mark;

  AudioMark({this.mark});

  AudioMark.fromJson(Map<String, dynamic> json) {
    if (json['mark'] != null) {
      mark = new List<Mark>();
      json['mark'].forEach((v) {
        mark.add(new Mark.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mark != null) {
      data['mark'] = this.mark.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Mark {
  String audioId;
  List<int> marksList;

  Mark({this.audioId, this.marksList});

  Mark.fromJson(Map<String, dynamic> json) {
    audioId = json['audioId'];
    marksList = json['marksList'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['audioId'] = this.audioId;
    data['marksList'] = this.marksList;
    return data;
  }
}