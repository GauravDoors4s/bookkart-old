import 'OrderResponse.dart';

class OrderRequest {
  String currency;
  int customerId;
  List<LineItems> lineItems;
  String paymentMethod;
  bool setPaid;
  String status;
  String transactionId;

  OrderRequest(
      {this.currency,
      this.customerId,
      this.lineItems,
      this.paymentMethod,
      this.setPaid,
      this.status,
      this.transactionId});

  OrderRequest.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    customerId = json['customer_id'];
    if (json['line_items'] != null) {
      lineItems = new List<LineItems>();
      json['line_items'].forEach((v) {
        lineItems.add(new LineItems.fromJson(v));
      });
    }
    paymentMethod = json['payment_method'];
    setPaid = json['set_paid'];
    status = json['status'];
    transactionId = json['transaction_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['customer_id'] = this.customerId;
    if (this.lineItems != null) {
      data['line_items'] = this.lineItems.map((v) => v.toJson()).toList();
    }
    data['payment_method'] = this.paymentMethod;
    data['set_paid'] = this.setPaid;
    data['status'] = this.status;
    data['transaction_id'] = this.transactionId;
    return data;
  }
}
