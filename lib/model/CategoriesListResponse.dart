class CategoriesListResponse {
  Links _links;
  int count;
  String description;
  String display;
  int id;
  Image image;
  int menu_order;
  String name;
  int parent;
  String slug;

  CategoriesListResponse({ this.count, this.description, this.display, this.id, this.image, this.menu_order, this.name, this.parent, this.slug});

  factory CategoriesListResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesListResponse(
      count: json['count'],
      description: json['description'],
      display: json['display'],
      id: json['id'],
      image: json['image'] != null ? Image.fromJson(json['image']) : null,
      menu_order: json['menu_order'],
      name: json['name'],
      parent: json['parent'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['description'] = this.description;
    data['display'] = this.display;
    data['id'] = this.id;
    data['menu_order'] = this.menu_order;
    data['name'] = this.name;
    data['parent'] = this.parent;
    data['slug'] = this.slug;
    if (this._links != null) {
      data['_links'] = this._links.toJson();
    }
    if (this.image != null) {
      data['image'] = this.image.toJson();
    }
    return data;
  }
}

class Image {
  String alt;
  String date_created;
  String date_created_gmt;
  String date_modified;
  String date_modified_gmt;
  int id;
  String name;
  String src;

  Image({this.alt, this.date_created, this.date_created_gmt, this.date_modified, this.date_modified_gmt, this.id, this.name, this.src});

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      alt: json['alt'],
      date_created: json['date_created'],
      date_created_gmt: json['date_created_gmt'],
      date_modified: json['date_modified'],
      date_modified_gmt: json['date_modified_gmt'],
      id: json['id'],
      name: json['name'],
      src: json['src'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['alt'] = this.alt;
    data['date_created'] = this.date_created;
    data['date_created_gmt'] = this.date_created_gmt;
    data['date_modified'] = this.date_modified;
    data['date_modified_gmt'] = this.date_modified_gmt;
    data['id'] = this.id;
    data['name'] = this.name;
    data['src'] = this.src;
    return data;
  }
}

class Links {
  List<Collection> collection;
  List<Self> self;

  Links({this.collection, this.self});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      collection: json['collection'] != null ? (json['collection'] as List).map((i) => Collection.fromJson(i)).toList() : null,
      self: json['self'] != null ? (json['self'] as List).map((i) => Self.fromJson(i)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.collection != null) {
      data['collection'] = this.collection.map((v) => v.toJson()).toList();
    }
    if (this.self != null) {
      data['self'] = this.self.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Self {
  String href;

  Self({this.href});

  factory Self.fromJson(Map<String, dynamic> json) {
    return Self(
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Collection {
  String href;

  Collection({this.href});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}