class AuthorListResponse {
  int id;
  String storeName;
  String firstName;
  String lastName;
  String name;
  String phone;
  String image;
  bool showEmail;
  String location;
  String banner;
  int bannerId;
  String gravatar;
  int gravatarId;
  String shopUrl;
  int productsPerPage;
  bool showMoreProductTab;
  bool tocEnabled;
  String storeToc;
  bool featured;
  Rating rating;
  bool enabled;
  String registered;
  String payment;
  bool trusted;

  AuthorListResponse({
    this.id,
    this.storeName,
    this.firstName,
    this.name,
    this.lastName,
    this.phone,
    this.showEmail,
    this.location,
    this.banner,
    this.bannerId,
    this.gravatar,
    this.gravatarId,
    this.image,
    this.shopUrl,
    this.productsPerPage,
    this.showMoreProductTab,
    this.tocEnabled,
    this.storeToc,
    this.featured,
    this.rating,
    this.enabled,
    this.registered,
    this.payment,
    this.trusted,
  });

  AuthorListResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeName = json['store_name'];
    firstName = json['first_name'];
    name = json['name'];
    lastName = json['last_name'];
    phone = json['phone'];
    showEmail = json['show_email'];
    location = json['location'];
    banner = json['banner'];
    bannerId = json['banner_id'];
    gravatar = json['gravatar'];
    gravatarId = json['gravatar_id'];
    shopUrl = json['shop_url'];
    productsPerPage = json['products_per_page'];
    showMoreProductTab = json['show_more_product_tab'];
    tocEnabled = json['toc_enabled'];
    image = json['image'];
    storeToc = json['store_toc'];
    featured = json['featured'];
    rating =
        json['rating'] != null ? new Rating.fromJson(json['rating']) : null;
    enabled = json['enabled'];
    registered = json['registered'];
    payment = json['payment'];
    trusted = json['trusted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['store_name'] = this.storeName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['show_email'] = this.showEmail;
    data['location'] = this.location;
    data['image'] = this.image;
    data['banner'] = this.banner;
    data['banner_id'] = this.bannerId;
    data['gravatar'] = this.gravatar;
    data['name'] = this.name;
    data['gravatar_id'] = this.gravatarId;
    data['shop_url'] = this.shopUrl;
    data['products_per_page'] = this.productsPerPage;
    data['show_more_product_tab'] = this.showMoreProductTab;
    data['toc_enabled'] = this.tocEnabled;
    data['store_toc'] = this.storeToc;
    data['featured'] = this.featured;
    if (this.rating != null) {
      data['rating'] = this.rating.toJson();
    }
    data['enabled'] = this.enabled;
    data['registered'] = this.registered;
    data['payment'] = this.payment;
    data['trusted'] = this.trusted;

    return data;
  }
}

class Rating {
  String rating;
  int count;

  Rating({this.rating, this.count});

  Rating.fromJson(Map<String, dynamic> json) {
    rating = json['rating'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating'] = this.rating;
    data['count'] = this.count;
    return data;
  }
}
