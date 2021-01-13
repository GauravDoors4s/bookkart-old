class CheckoutResponse {
  String checkoutUrl;

  CheckoutResponse({this.checkoutUrl});

  CheckoutResponse.fromJson(Map<String, dynamic> json) {
    checkoutUrl = json['checkout_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['checkout_url'] = this.checkoutUrl;
    return data;
  }
}
