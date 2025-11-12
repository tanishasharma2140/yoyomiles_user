class WalletHistoryModel {
  List<Data>? data;
  bool? success;
  String? message;

  WalletHistoryModel({this.data, this.success, this.message});

  WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  int? userid;
  int? orderid;
  String? amount;
  String? redirectUrl;
  dynamic response;
  int? status;
  String? datetime;
  int? wallet;

  Data(
      {this.id,
        this.userid,
        this.orderid,
        this.amount,
        this.redirectUrl,
        this.response,
        this.status,
        this.datetime,
        this.wallet});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['userid'];
    orderid = json['orderid'];
    amount = json['amount'];
    redirectUrl = json['redirect_url'];
    response = json['response'];
    status = json['status'];
    datetime = json['datetime'];
    wallet = json['wallet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userid'] = userid;
    data['orderid'] = orderid;
    data['amount'] = amount;
    data['redirect_url'] = redirectUrl;
    data['response'] = response;
    data['status'] = status;
    data['datetime'] = datetime;
    data['wallet'] = wallet;
    return data;
  }
}
