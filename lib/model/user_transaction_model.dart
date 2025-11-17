class UserTransactionModel {
  bool? status;
  String? message;
  int? total;
  List<Data>? data;

  UserTransactionModel({this.status, this.message, this.total, this.data});

  UserTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? platformFee;
  String? totalAmount;
  String? amount;
  int? paymentGatewayStatus;
  String? orderId;
  String? createdAt;
  int? paymetBy;
  int? userid;
  int? subType;

  Data(
      {this.id,
        this.platformFee,
        this.totalAmount,
        this.amount,
        this.paymentGatewayStatus,
        this.orderId,
        this.createdAt,
        this.paymetBy,
        this.userid,
        this.subType});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    platformFee = json['platform_fee'];
    totalAmount = json['total_amount'];
    amount = json['amount'];
    paymentGatewayStatus = json['payment_gateway_status'];
    orderId = json['order_id'];
    createdAt = json['created_at'];
    paymetBy = json['paymet_by'];
    userid = json['userid'];
    subType = json['sub_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['platform_fee'] = platformFee;
    data['total_amount'] = totalAmount;
    data['amount'] = amount;
    data['payment_gateway_status'] = paymentGatewayStatus;
    data['order_id'] = orderId;
    data['created_at'] = createdAt;
    data['paymet_by'] = paymetBy;
    data['userid'] = userid;
    data['sub_type'] = subType;
    return data;
  }
}
