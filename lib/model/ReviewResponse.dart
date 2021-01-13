class ReviewResponse {
    String dateCreated;
    String email;
    int id;
    String name;
    int rating;
    String review;
    bool verified;

    ReviewResponse({ this.dateCreated, this.email, this.id, this.name, this.rating, this.review, this.verified});

    factory ReviewResponse.fromJson(Map<String, dynamic> json) {
        return ReviewResponse(
            dateCreated: json['date_created'],
            email: json['email'], 
            id: json['id'], 
            name: json['name'], 
            rating: json['rating'], 
            review: json['review'], 
            verified: json['verified'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['date_created'] = this.dateCreated;
        data['email'] = this.email;
        data['id'] = this.id;
        data['name'] = this.name;
        data['rating'] = this.rating;
        data['review'] = this.review;
        data['verified'] = this.verified;

        return data;
    }
}

class Links {
    List<Collection> collection;
    List<Self> self;
    List<Up> up;

    Links({this.collection, this.self, this.up});

    factory Links.fromJson(Map<String, dynamic> json) {
        return Links(
            collection: json['collection'] != null ? (json['collection'] as List).map((i) => Collection.fromJson(i)).toList() : null, 
            self: json['self'] != null ? (json['self'] as List).map((i) => Self.fromJson(i)).toList() : null, 
            up: json['up'] != null ? (json['up'] as List).map((i) => Up.fromJson(i)).toList() : null, 
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
        if (this.up != null) {
            data['up'] = this.up.map((v) => v.toJson()).toList();
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

class Up {
    String href;

    Up({this.href});

    factory Up.fromJson(Map<String, dynamic> json) {
        return Up(
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