class Customer {
  var id;
  var dateCreated;
  var dateCreatedGmt;
  var dateModified;
  var dateModifiedGmt;
  var email;
  var firstName;
  var lastName;
  var role;
  var username;
  Billing billing;
  Shipping shipping;
  var isPayingCustomer;
  var avatarUrl;
  List<MetaDataResponse> metaData;
  Links lLinks;

  Customer(
      {this.id,
      this.dateCreated,
      this.dateCreatedGmt,
      this.dateModified,
      this.dateModifiedGmt,
      this.email,
      this.firstName,
      this.lastName,
      this.role,
      this.username,
      this.billing,
      this.shipping,
      this.isPayingCustomer,
      this.avatarUrl,
      this.metaData,
      this.lLinks});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateCreated = json['date_created'];
    dateCreatedGmt = json['date_created_gmt'];
    dateModified = json['date_modified'];
    dateModifiedGmt = json['date_modified_gmt'];
    email = json['email'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    role = json['role'];
    username = json['username'];
    billing =
        json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
    shipping = json['shipping'] != null
        ? new Shipping.fromJson(json['shipping'])
        : null;
    isPayingCustomer = json['is_paying_customer'];
    avatarUrl = json['avatar_url'];
    if (json['meta_data'] != null) {
      metaData = new List<MetaDataResponse>();
      json['meta_data'].forEach((v) {
        metaData.add(new MetaDataResponse.fromJson(v));
      });
    }
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date_created'] = this.dateCreated;
    data['date_created_gmt'] = this.dateCreatedGmt;
    data['date_modified'] = this.dateModified;
    data['date_modified_gmt'] = this.dateModifiedGmt;
    data['email'] = this.email;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['role'] = this.role;
    data['username'] = this.username;
    if (this.billing != null) {
      data['billing'] = this.billing.toJson();
    }
    if (this.shipping != null) {
      data['shipping'] = this.shipping.toJson();
    }
    data['is_paying_customer'] = this.isPayingCustomer;
    data['avatar_url'] = this.avatarUrl;
    if (this.metaData != null) {
      data['meta_data'] = this.metaData.map((v) => v.toJson()).toList();
    }
    if (this.lLinks != null) {
      data['_links'] = this.lLinks.toJson();
    }
    return data;
  }
}

class Billing {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postcode;
  String country;
  String state;
  String email;
  String phone;

  Billing(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.postcode,
      this.country,
      this.state,
      this.email,
      this.phone});

  Billing.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postcode = json['postcode'];
    country = json['country'];
    state = json['state'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company'] = this.company;
    data['address_1'] = this.address1;
    data['address_2'] = this.address2;
    data['city'] = this.city;
    data['postcode'] = this.postcode;
    data['country'] = this.country;
    data['state'] = this.state;
    data['email'] = this.email;
    data['phone'] = this.phone;
    return data;
  }
}

class Shipping {
  String firstName;
  String lastName;
  String company;
  String address1;
  String address2;
  String city;
  String postcode;
  String country;
  String state;

  Shipping(
      {this.firstName,
      this.lastName,
      this.company,
      this.address1,
      this.address2,
      this.city,
      this.postcode,
      this.country,
      this.state});

  Shipping.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    company = json['company'];
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    postcode = json['postcode'];
    country = json['country'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company'] = this.company;
    data['address_1'] = this.address1;
    data['address_2'] = this.address2;
    data['city'] = this.city;
    data['postcode'] = this.postcode;
    data['country'] = this.country;
    data['state'] = this.state;
    return data;
  }
}

class MetaDataResponse {
  int id;
  String key;
  String value;

  MetaDataResponse({this.id, this.key, this.value});

  MetaDataResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class Links {
  List<Self> self;

  Links.fromJson(Map<String, dynamic> json) {
    if (json['self'] != null) {
      self = new List<Self>();
      json['self'].forEach((v) {
        self.add(new Self.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.self != null) {
      data['self'] = this.self.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Self {
  String href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}
