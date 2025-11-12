class CouponListModel {
  int? status;
  String? message;
  List<Data>? data;

  CouponListModel({this.status, this.message, this.data});

  CouponListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? couponId;
  String? couponCode;
  String? vehicleType;
  String? offerTitle;
  String? offerName;
  String? validDate;
  int? status;
  String? amount;
  int? claimStatus;

  Data(
      {this.couponId,
        this.couponCode,
        this.vehicleType,
        this.offerTitle,
        this.offerName,
        this.validDate,
        this.status,
        this.amount,
        this.claimStatus});

  Data.fromJson(Map<String, dynamic> json) {
    couponId = json['coupon_id'];
    couponCode = json['coupon_code'];
    vehicleType = json['vehicle_type'];
    offerTitle = json['offer_title'];
    offerName = json['offer_name'];
    validDate = json['valid_date'];
    status = json['status'];
    amount = json['amount'];
    claimStatus = json['claim_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coupon_id'] = couponId;
    data['coupon_code'] = couponCode;
    data['vehicle_type'] = vehicleType;
    data['offer_title'] = offerTitle;
    data['offer_name'] = offerName;
    data['valid_date'] = validDate;
    data['status'] = status;
    data['amount'] = amount;
    data['claim_status'] = claimStatus;
    return data;
  }
}
