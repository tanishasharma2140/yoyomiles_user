class PaytmGatewayModel {
  bool? status;
  String? message;
  Data? data;

  PaytmGatewayModel({this.status, this.message, this.data});

  PaytmGatewayModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? orderId;
  String? txnToken;
  String? amount;

  Data({this.orderId, this.txnToken, this.amount});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    txnToken = json['txnToken'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['txnToken'] = txnToken;
    data['amount'] = amount;
    return data;
  }
}
